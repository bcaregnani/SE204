`default_nettype none

`ifdef SIMULATION
  localparam hcmpt1=50 ;
  localparam hcmpt2=50 ;
`else
  localparam hcmpt1=100000000 ; // for led1
  localparam hcmpt2=32000000 ; // for led2
`endif

module Top #(parameter HDISP = 800, VDISP = 480) (
    // Les signaux externes de la partie FPGA
	input  wire         FPGA_CLK1_50,
	input  wire  [1:0]	KEY,
	output logic [7:0]	LED,
	input  wire	 [3:0]	SW,
    // Les signaux du support matériel son regroupés dans une interface
    hws_if.master       hws_ifm,
    // Video interface
    video_if.master     video_ifm
);

//====================================
//  Déclarations des signaux internes
//====================================
  wire        sys_rst;   // Le signal de reset du système
  wire        sys_clk;   // L'horloge système a 100Mhz
  wire        pixel_clk; // L'horloge de la video 32 Mhz

//=======================================================
//  La PLL pour la génération des horloges
//=======================================================

sys_pll  sys_pll_inst(
		   .refclk(FPGA_CLK1_50),   // refclk.clk
		   .rst(1'b0),              // pas de reset
		   .outclk_0(pixel_clk),    // horloge pixels a 32 Mhz
		   .outclk_1(sys_clk)       // horloge systeme a 100MHz
);

//=============================
//  Les bus Wishbone internes
//=============================
wshb_if #( .DATA_BYTES(4)) wshb_if_sdram  (sys_clk, sys_rst);
wshb_if #( .DATA_BYTES(4)) wshb_if_stream (sys_clk, sys_rst);

// Stage 4 wishone interfaces internes
wshb_if #( .DATA_BYTES(4)) wshb_ifs_vga  (sys_clk, sys_rst);
// wshb_if #( .DATA_BYTES(4)) wshb_ifs_mire  (sys_clk, sys_rst);



//=============================
//  Le support matériel
//=============================
hw_support hw_support_inst (
    .wshb_ifs (wshb_if_sdram),
    .wshb_ifm (wshb_if_stream),
    .hws_ifm  (hws_ifm),
	.sys_rst  (sys_rst), // output
    .SW_0     ( SW[0] ),
    .KEY      ( KEY )
 );

//=============================
// On neutralise l'interface
// du flux video pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
//assign wshb_if_stream.ack = 1'b1;
//assign wshb_if_stream.dat_sm = '0 ;
//assign wshb_if_stream.err =  1'b0 ;
//assign wshb_if_stream.rty =  1'b0 ;

//=============================
// On neutralise l'interface SDRAM
// pour l'instant
// A SUPPRIMER PLUS TARD
//=============================
//assign wshb_if_sdram.stb  = 1'b0;
//assign wshb_if_sdram.cyc  = 1'b0;
//assign wshb_if_sdram.we   = 1'b0;
//assign wshb_if_sdram.adr  = '0  ;
//assign wshb_if_sdram.dat_ms = '0 ;
//assign wshb_if_sdram.sel = '0 ;
//assign wshb_if_sdram.cti = '0 ;
//assign wshb_if_sdram.bte = '0 ;

//--------------------------
//------- Code Eleves ------
//--------------------------


//Etape 1: 4)
assign LED[0] = KEY[0];

logic [26:0] count;

// flash led1 with frequency 1Hz
always_ff @( posedge sys_clk or posedge sys_rst )
begin
    if (sys_rst)
    begin
        LED[1] <= 0;
        count <= 0;
    end
    else
    begin
        count <= count + 1;
        if (count == hcmpt1)
        begin
            if (LED[1])
                LED[1] <= 0;
            else
                LED[1] <= 1;
            count <= 0;
        end
    end
end

//Etape 1: 7)

logic pixel_rst, Q0;
wire D0 = 0;

// reset for LCD screen
always_ff @(posedge pixel_clk or posedge sys_rst )
begin
    if (sys_rst)
    begin
        Q0 <= 1;
        pixel_rst <= 1;
    end
    else
    begin
        Q0 <= D0;
        pixel_rst <= Q0;
    end
end


logic [24:0] count1;

// flash led2 with frequency 1Hz
always_ff @( posedge pixel_clk or posedge pixel_rst)
begin
    if (pixel_rst)
    begin
        LED[2] <= 0;
        count1 <= 0;
    end
    else
    begin
        count1 <= count1 + 1;
        if (count1 == hcmpt2)
        begin
            if (LED[2])
                LED[2] <= 0;
            else
                LED[2] <= 1;
            count1 <= 0;
        end
    end
end



/**
*
*   Stage 2: 5)
*
*   vga module instanciation
**/

vga #(.HDISP(HDISP), .VDISP(VDISP)) vga_inst (.pixel_clk(pixel_clk), .pixel_rst(pixel_rst),
    .video_ifm(video_ifm), .wshb_ifm(wshb_ifs_vga));



// mire module instanciation
// mire #(.HDISP(HDISP), .VDISP(VDISP)) mire_inst ( .wshb_ifs_mire(wshb_ifs_mire) );

// wshb_intercon instanciation
wshb_intercon wshb_intercon_inst (.wshb_ifm(wshb_if_sdram), .wshb_ifs_mire(wshb_if_stream), .wshb_ifs_vga(wshb_ifs_vga));


endmodule
