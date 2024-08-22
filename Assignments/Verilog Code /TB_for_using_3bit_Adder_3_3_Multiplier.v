`timescale 1ns / 1ps

module TB_for_using_3bit_Adder_3_3_Multiplier;

    reg [2:0] A;
    reg [2:0] B;
    wire [5:0] P;

// Instantiate the design module (by port name)

Using_3bit_Adder_3_3_Multiplier dut (.A(A),.B(B),.P(P));    

initial begin

A[0]=1'b1 ; A[1]=1'b1 ; A[2]=1'b1 ; 
B[0]=1'b1 ; B[1]=1'b1 ; B[2]=1'b1 ;

#10;

A[0]=1'b0 ; A[1]=1'b1 ; A[2]=1'b0 ; 
B[0]=1'b0 ; B[1]=1'b1 ; B[2]=1'b0 ;

#10;

$finish;

end
endmodule
