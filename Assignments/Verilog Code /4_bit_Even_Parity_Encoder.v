`timescale 1ns / 1ps

module _4_bit_Even_Parity_Encoder(
    input   [3:0] data,   // 4-bit input
    output  [4:0] encode  // 5-bit output (4 data bits + parity bit)
);

    // Calculate parity bit: XOR (inequality operator odd '1s' out '1s' even '1s' out '0s')of all input bits
    assign encode[0]   = data[0] ^ data[1] ^ data[2] ^ data[3]; // Parity bit
    assign encode[4:1] = data;  // Data bits
    
endmodule


/*
Output Assignment:

code[3:0] directly takes the 4-bit input data.
code[4] is the parity bit.

*/
