


module vga #(parameter HDISP = 800, VDISP = 480) (

//Inputs
input wire pixel_clk,
input wire pixel_rst,

//Video interface
video_if.master video_ifm,

//Wishbone interface
wshb_if.master wshb_ifm
);


localparam HFP = 40;
localparam HPULSE = 48;
localparam HBP = 40;
localparam VFP = 13;
localparam VPULSE = 3;
localparam VBP = 29;
localparam H_MAX = HFP + HPULSE + HBP + HDISP;
localparam V_MAX = VFP + VPULSE + VBP + VDISP;

// Counters
logic [$clog2(H_MAX)-1:0] pixel_count;
logic [$clog2(V_MAX)-1:0] lines_count;



// Counters logic
always_ff @( posedge pixel_clk or posedge pixel_rst )
begin
    if (pixel_rst)
    begin
        pixel_count <= 0;
        lines_count <= 0;
    end
    else
    begin
        pixel_count <= pixel_count + 1;
        if (pixel_count == H_MAX -1)
        begin
            pixel_count <= 0;
            lines_count <= lines_count + 1;
            if (lines_count == V_MAX -1)
                lines_count <= 0;
        end

    end
end



// Logic for the synchronization signals
assign video_ifm.CLK = pixel_clk;
assign video_ifm.HS = !(pixel_count >= HFP && pixel_count < HFP+HPULSE);
assign video_ifm.VS = !(lines_count >= VFP && lines_count < VFP+VPULSE);
assign video_ifm.BLANK = (pixel_count >= HFP+HPULSE+HBP) & (lines_count >= VFP+VPULSE+VBP);

// Making a grid
//assign video_ifm.RGB = !( (pixel_count - (H_MAX - HDISP)) % 16 ) | !( (lines_count - (V_MAX - VDISP) ) % 16 ) ? 24'hFFFFFF : 24'h000000;



// Wishbone interface first adaptation
//assign wshb_ifm.dat_ms = 32'hBABECAFE;
//assign wshb_ifm.adr = '0;
//assign wshb_ifm.cyc = 1'b1;
assign wshb_ifm.sel = 4'b1111;
assign wshb_ifm.we = 1'b0;
assign wshb_ifm.cti = '0;
assign wshb_ifm.bte = '0;



//Read in SDRAM

logic [$clog2(H_MAX)-1:0]x = 0;
logic [$clog2(V_MAX)-1:0]y = 0;

assign wshb_ifm.adr = 4*(HDISP*y +x);

always_ff @( posedge wshb_ifm.clk or posedge wshb_ifm.rst )
begin
    if (wshb_ifm.rst)
    begin
        x <= 0;
        y <= 0;
    end
    else
    begin
        if (wshb_ifm.ack)
        begin
            if (x == HDISP-1)
            begin
                x <= 0;
                if (y == VDISP -1)
                    y <= 0;
                else
                    y <= y + 1;
            end
            else
                x <= x + 1;
        end
    end
    
end

localparam DATA_WIDTH = 32;
localparam DEPTH_WIDTH = 8;
localparam ALMOST_FULL_THRESHOLD = 224;
logic rst;
logic rclk;
logic read;
logic [DATA_WIDTH-1:0] rdata;
logic rempty;
logic wclk;
logic [DATA_WIDTH-1:0] wdata;
logic write;
logic wfull;
logic walmost_full;

assign rst = wshb_ifm.rst;
assign rclk = pixel_clk;
assign video_ifm.RGB = rdata[23:0];
assign wclk = wshb_ifm.clk;
assign wdata = wshb_ifm.dat_sm;
assign write = wshb_ifm.ack;




async_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH_WIDTH(DEPTH_WIDTH), .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD)) 
    async_fifo_inst (.rst(rst), .rclk(rclk), .read(read), .rdata(rdata), .rempty(rempty), .wclk(wclk), 
    .wdata(wdata), .write(write), .wfull(wfull), .walmost_full(walmost_full) );



// For stopping the writing in FIFO because it is full
// assign wshb_ifm.cyc = !wfull;
assign wshb_ifm.stb = wshb_ifm.cyc;

// Signal cyc modification for stage 5
logic cyc_val;

always_ff @( posedge wshb_ifm.clk or posedge wshb_ifm.rst )
begin

    if (wshb_ifm.rst) cyc_val <= '0;
    else
    begin
    if (!walmost_full) cyc_val <= '1;
    end

end

assign wshb_ifm.cyc = cyc_val & !wfull;



// Change clock domain for signal wfull
logic waitfull1, waitfull2;

always_ff @( posedge pixel_clk or posedge pixel_rst )
begin
    if (pixel_rst)
    begin
        waitfull1 <= '0;
        waitfull2 <= '0;
    end
    else
    begin
        waitfull1 <= wfull;
        waitfull2 <= waitfull1;
    end
end



// Waiting untill FIFO full before reading from it
logic fifo_full;

always_ff @( posedge pixel_clk or posedge pixel_rst )
begin
    if (pixel_rst) fifo_full <= 0;
    else if (waitfull2 & !video_ifm.VS & !video_ifm.HS) fifo_full <= 1;   //
end

assign read = video_ifm.BLANK & fifo_full & !rempty;

endmodule