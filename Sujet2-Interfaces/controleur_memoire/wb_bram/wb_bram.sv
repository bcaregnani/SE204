//-----------------------------------------------------------------
// Wishbone BlockRAM
//-----------------------------------------------------------------
//
// Le paramètre mem_adr_width doit permettre de déterminer le nombre 
// de mots de la mémoire : (2048 pour mem_adr_width=11)


module wb_bram #(parameter mem_adr_width = 11) (
      // Wishbone interface
      wshb_if.slave wb_s
      );

      // Memory block
      logic [3:0][7:0] mem [0:2**mem_adr_width-1];

      wire [mem_adr_width-1:0] address_ind = wb_s.adr[mem_adr_width+1:2];

      // Managing reading and writing in memory
      always_ff @( posedge wb_s.clk )
      begin

            if (wb_s.sel[3]) 
            begin
                  mem[address_ind][3] <= wb_s.dat_ms[31:24];
                  wb_s.dat_sm[31:24] <= mem[address_ind][3];
            end;

            if (wb_s.sel[2]) 
            begin
                  mem[address_ind][2] <= wb_s.dat_ms[23:16];
                  wb_s.dat_sm[23:16] <= mem[address_ind][2];
            end;

            if (wb_s.sel[1]) 
            begin
                  mem[address_ind][1] <= wb_s.dat_ms[15:8];
                  wb_s.dat_sm[15:8] <= mem[address_ind][1];
            end

            if (wb_s.sel[0]) 
            begin
                  mem[address_ind][0] <= wb_s.dat_ms[7:0];
                  wb_s.dat_sm[7:0] <= mem[address_ind][0];
            end

      end


      // Control block read acknowledge
      logic ack_w, ack_r;

      always_ff @( posedge wb_s.clk or posedge wb_s.rst)
      begin
            if (wb_s.rst) 
            begin
                  ack_r <= 0;
            end
            else
            begin
                  ack_r <= 0;
                  if (wb_s.cyc && wb_s.stb && !wb_s.we)
                        begin
                        ack_r <= 1;
                        if (ack_r) ack_r <= 0;
                        end
            end
      end

      // ack for writing
      assign ack_w = (wb_s.we & wb_s.stb);

      //ACK
      assign wb_s.ack = ack_w | ack_r;


      // No implementation yet for this signals
      assign wb_s.err = 0;
      assign wb_s.rty = 0;




endmodule