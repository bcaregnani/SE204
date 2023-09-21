/**
    @brief 
    modul

    @parameters
    WIDTH: number of bits of the numbers
**/


module MED #(parameter WIDTH = 8, PIXELS = 9) (DI, DSI, BYP, CLK, DO);

    input [WIDTH-1:0] DI;
    input DSI, BYP, CLK;
    output logic [WIDTH-1:0] DO;
    
    // local variables
    logic [WIDTH-1:0] R[PIXELS-1:0];
    int i;


    // interconnections
    wire [WIDTH-1:0] MIN0, MAX0;

    // structure
    MCE inst0 (.A(DO), .B(R[PIXELS-2]), .MAX(MAX0), .MIN(MIN0));

    assign DO = R[PIXELS-1];
    

    always_ff @(posedge CLK)
    begin

        if (DSI)
        begin
            R[0] <= DI;
        end 
        else 
        begin
            R[0] <= MIN0;
        end;

        for ( i = 0 ; i < PIXELS-1 ; i++ )
        begin
            R[i+1] <= R[i];
        end;

        if (BYP)
        begin
            R[PIXELS-1] <= R[PIXELS-2];
        end 
        else 
        begin
            R[PIXELS-1] <= MAX0;
        end;

    end

endmodule