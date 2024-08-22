`timescale 1ns / 1ps

module Using_3bit_Adder_3_3_Multiplier(
    input [2:0] A,
    input [2:0] B,
    output [5:0] P
    );
    wire [10:0] W;
    
    assign P[0]= A[0] & B[0];
    assign W[0]= A[1] & B[0];
    assign W[1]= A[2] & B[0];
    assign W[2]= A[0] & B[1];
    assign W[3]= A[1] & B[1];
    assign W[4]= A[2] & B[1];
    assign W[8]= A[0] & B[2];
    assign W[9]= A[1] & B[2];
    assign W[10]= A[2] & B[2];
    
    _3_Bit_Adder A1 (
    .A({W[4], W[3], W[2]}),   // Pass bits W[4], W[3], W[2] to A[2:0]
    .B({1'b0, W[1], W[0]}),   // Pass bits W[1], W[0], and tie LSB of B to 0
    .Sum({W[6], W[5], P[1]}), // Pass bits W[7], W[6], W[5] to Sum[2:0]
    .Carry(W[7])              // Carry will receive the carry out
    );
    
    _3_Bit_Adder A2 (
    .A({W[10], W[9], W[8]}),  
    .B({W[7], W[6], W[5]}),  
    .Sum({P[4], P[3], P[2]}),               
    .Carry(P[5])            
    );
    
endmodule


/*

`timescale 1ns / 1ps
module _3_Bit_Adder(
    input [2:0] A,
    input [2:0] B,
    output [2:0] Sum,
    output Carry
    );
    wire [1:0] C;
    FA FA_1 (A[0],B[0],1'b0,Sum[0],C[0]);
    FA FA_2 (A[1],B[1],C[0],Sum[1],C[1]);
    FA FA_3 (A[2],B[2],C[1],Sum[2],Carry);
endmodule


`timescale 1ns / 1ps
module FA(
    input A,
    input B,
    input C,
    output Sum,
    output Carry
    );
    assign Sum=A^B^C;
    assign Carry=(A&B) | (B&C) | (C&A);
endmodule

*/
