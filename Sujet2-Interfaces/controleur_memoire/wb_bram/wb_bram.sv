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

      // 4 bytes, 32 bits
      logic [3:0][7:0] mem [0:2**mem_adr_width-1];

      logic ack_w, ack_r;

      wire [mem_adr_width-1:0] address_ind = wb_s.adr[mem_adr_width+1:2];

      assign wb_s.err = 0;
      assign wb_s.rty = 0;

      always_ff @( posedge wb_s.clk )
      begin

            case (wb_s.sel)

                  4'b0000 :
                  begin
                        if (wb_s.we)
                        begin
                              mem[address_ind] <= wb_s.dat_ms & 32'h00000000;
                        end;

                        wb_s.dat_sm <= mem[address_ind] & 32'h00000000;
                  end

                  4'b0001 :
                  begin
                        if (wb_s.we)
                        begin
                              mem[address_ind] <= wb_s.dat_ms & 32'h000000ff;
                        end;

                        wb_s.dat_sm <= mem[address_ind] & 32'h000000ff;
                  end

                  4'b0010 :
                  begin
                        if (wb_s.we)
                        begin
                              mem[address_ind] <= wb_s.dat_ms & 32'h0000ff00;
                        end;

                        wb_s.dat_sm <= mem[address_ind] & 32'h0000ff00;
                  end

                  4'b0100 :
                  begin
                        if (wb_s.we)
                        begin
                              mem[address_ind] <= wb_s.dat_ms & 32'h00ff0000;
                        end;

                        wb_s.dat_sm <= mem[address_ind] & 32'h00ff0000;
                  end

                  4'b1000 :
                  begin
                        if (wb_s.we)
                        begin
                              mem[address_ind] <= wb_s.dat_ms & 32'hff000000;
                        end;

                        wb_s.dat_sm <= mem[address_ind] & 32'hff000000;
                  end

                  4'b0011 :
                  begin
                        if (wb_s.we)
                        begin
                              mem[address_ind] <= wb_s.dat_ms & 32'h0000ffff;
                        end;

                        wb_s.dat_sm <= mem[address_ind] & 32'h0000ffff;
                  end

                  4'b1100 :
                  begin
                        if (wb_s.we)
                        begin
                              mem[address_ind] <= wb_s.dat_ms & 32'hffff0000;
                        end;

                        wb_s.dat_sm <= mem[address_ind] & 32'hffff0000;
                  end

                  default:
                  begin
                        if (wb_s.we)
                        begin
                              mem[address_ind] <= wb_s.dat_ms;
                        end;

                        wb_s.dat_sm <= mem[address_ind];
                  end
            endcase


      end

      // Control block read acknowledge
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

      assign ack_w = wb_s.we & wb_s.stb;

      assign wb_s.ack = ack_w | ack_r;




endmodule