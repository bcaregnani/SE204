
/**
* Module for generating a pattern comunicating via an wishbone interface with module wshb_intercon
**/


module mire #(parameter HDISP = 800, VDISP = 480) (wshb_if.master wshb_ifs_mire );





assign wshb_ifs_mire.we = '1;
assign wshb_ifs_mire.sel = 4'b0111;  //because RGB takes 3 bytes (LSB)
assign wshb_ifs_mire.cti = '0; // classic bus
assign wshb_ifs_mire.bte = '0;




// Modified counters from module vga for making a grid
logic [$clog2(HDISP)-1:0] pixel_count;
logic [$clog2(VDISP)-1:0] lines_count;

// Modified counters logic from module vga
always_ff @( posedge wshb_ifs_mire.clk or posedge wshb_ifs_mire.rst )
begin
    if (wshb_ifs_mire.rst)
    begin
        pixel_count <= 0;
        lines_count <= 0;
    end
    else if (wshb_ifs_mire.ack)
    begin
        pixel_count <= pixel_count + 1;
        if (pixel_count == HDISP -1)
        begin
            pixel_count <= 0;
            lines_count <= lines_count + 1;
            if (lines_count == VDISP -1)
                lines_count <= 0;
        end

    end
end



// Making a grid
assign wshb_ifs_mire.dat_ms = ( !(pixel_count % 16 ) | !( lines_count % 16 ) ) ? 32'h00FFFFFF : 32'h00000000 ;




// Write in SDRAM
// Adaptation from module vga

always_ff @( posedge wshb_ifs_mire.clk or posedge wshb_ifs_mire.rst )
begin
    
    if (wshb_ifs_mire.rst) wshb_ifs_mire.adr <= 0;
    else if (wshb_ifs_mire.ack)
            if (wshb_ifs_mire.adr == 4*(HDISP*VDISP -1)) wshb_ifs_mire.adr <=0;
            else wshb_ifs_mire.adr <= wshb_ifs_mire.adr + 4;
    
end



// "fair play" for letting vga communicate with module wshb_intercon, 1 empty cycle in cyc and stb every 64 cycles
// Implementing fair play

logic [5:0]fair_counter;

always_ff @( posedge wshb_ifs_mire.clk or posedge wshb_ifs_mire.rst )
begin
    if (wshb_ifs_mire.rst) fair_counter <= 0;
    else
    begin
        if (fair_counter == 63) fair_counter <= 0;
        else if (wshb_ifs_mire.ack) fair_counter <= fair_counter + 1;
    end
end


assign wshb_ifs_mire.cyc = !(fair_counter == 63);
assign wshb_ifs_mire.stb = !(fair_counter == 63);




endmodule