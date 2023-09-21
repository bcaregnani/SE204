/**
    @brief 
    module for sorting median of pixels

    @parameters
    WIDTH: number of bits of the numbers

    @inputs
    DI: Data in
    DSI: Data select in
    BYP: Bypass
    CLK: clock
    DO: Data out
    DSO: Data select out
**/


module MEDIAN #(parameter WIDTH = 8) (DI, DSI, nRST, CLK, DO, DSO);

    input [WIDTH-1:0] DI;
    input DSI, nRST, CLK;
    output logic [WIDTH-1:0] DO;
    output logic DSO;

    // local variables
    logic BYP;
    logic [3:0] Q;

    // Enumerate type for defining states
    typedef enum logic [2:0] {IDLE, INIT, E1, E2, E3, E4, E5} STATE;
    STATE state;
    
    // structure
    MED MED_inst (.DI(DI), .DSI(DSI), .BYP(BYP), .CLK(CLK), .DO(DO));



    // Mealy
    logic BYP_r;
    assign BYP = BYP_r | DSI;

    // Synchronous process for change of state
    always_ff @( posedge CLK or negedge nRST)
    begin

        if (!nRST)
        begin
            // write reset
            state <= IDLE ;
            BYP_r <= 0;
            Q <= 0;
        end
        else
        begin
        case (state)

            IDLE :
            begin
              BYP_r <= 0;
              if(DSI) state <= INIT;
            end

            INIT :
            begin
              BYP_r <= 0;
              if (!DSI)
              begin
                  state <= E1;
                  Q <= 0;
              end
            end

            E1 :
            begin
            Q <= Q+1;
            if (Q==7)
                BYP_r <= 1;
            if (Q==8)
            begin
                state <= E2;
                Q <= 0;
                BYP_r <= 0;
            end
            end

            E2 :
            begin
            Q <= Q+1;
            if (Q==6)
                BYP_r <= 1;
            if (Q==8)
            begin
                state <= E3;
                Q <= 0;
                BYP_r <= 0;
            end
            end

            E3 :
            begin
            Q <= Q+1;
            if (Q==5)
                BYP_r <= 1;
            if (Q==8)
            begin
                state <= E4;
                Q <= 0;
                BYP_r <= 0;
            end
            end


            E4 :
            begin
            Q <= Q+1;
            if (Q==4)
                BYP_r <= 1;
            if (Q==8)
            begin
                state <= E5;
                Q <= 0;
                BYP_r <= 0;
            end
            end


            E5 :
            begin
            Q <= Q+1;
            if (Q==4)
            begin
                state <= IDLE;
                Q <= 0;
            end
            end

            default :
                state <= IDLE;
            
        endcase
        end
    end

    // Combinatories computation of the outputs
    always_comb
        DSO = (state == E5) && (Q == 4);


endmodule
