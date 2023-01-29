

/**
* Module for managing and signal selection, communicating via 3 interfaces one with mire, one with vga and one with sdram
**/


module wshb_intercon (wshb_if.slave wshb_ifs_mire, wshb_if.slave wshb_ifs_vga, wshb_if.master wshb_ifm );


// token for knowing what module is executing
// 0 for mire
// 1 for vga
logic token; 

always_ff @( posedge wshb_ifm.clk or posedge wshb_ifm.rst )
begin
    if (wshb_ifm.rst) token <= 0;
    else
    begin
        if ( (token == 0) & (wshb_ifs_mire.cyc == 0) ) token <= 1;
        else if ( (token == 1) & (wshb_ifs_vga.cyc == 0) ) token <=0 ;
    end
end


assign wshb_ifm.cyc = (!token) ? wshb_ifs_mire.cyc : wshb_ifs_vga.cyc;
assign wshb_ifm.stb = (!token) ? wshb_ifs_mire.stb : wshb_ifs_vga.stb;
assign wshb_ifm.adr = (!token) ? wshb_ifs_mire.adr : wshb_ifs_vga.adr;
assign wshb_ifm.we  = (!token) ? wshb_ifs_mire.we : wshb_ifs_vga.we;
assign wshb_ifm.dat_ms = (!token) ? wshb_ifs_mire.dat_ms : wshb_ifs_vga.dat_ms;
assign wshb_ifm.sel = (!token) ? wshb_ifs_mire.sel : wshb_ifs_vga.sel;
assign wshb_ifm.cti = (!token) ? wshb_ifs_mire.cti : wshb_ifs_vga.cti;
assign wshb_ifm.bte = (!token) ? wshb_ifs_mire.bte : wshb_ifs_vga.bte;


assign wshb_ifs_vga.ack = (token) ? wshb_ifm.ack : 0;
assign wshb_ifs_vga.dat_sm = wshb_ifm.dat_sm;
assign wshb_ifs_vga.err = '0;
assign wshb_ifs_vga.rty = '0;

assign wshb_ifs_mire.ack = (!token) ? wshb_ifm.ack : 0;
assign wshb_ifs_mire.err = '0;
assign wshb_ifs_mire.rty = '0;




endmodule