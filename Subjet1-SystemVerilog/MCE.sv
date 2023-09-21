/**
    @brief 
    module that gives the max and min between two numbers

    @parameters
    WIDTH: number of bits of the numbers
**/


module MCE #(parameter WIDTH = 8) (A, B, MAX, MIN);

    input [WIDTH-1:0] A, B;
    output logic [WIDTH-1:0] MAX, MIN;
    
    assign MAX = (A>B)? A : B;
    assign MIN = (A>B)? B : A;

endmodule