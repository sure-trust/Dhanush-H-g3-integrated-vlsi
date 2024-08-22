`timescale 1ns / 1ps

module TB_for_4_bit_Even_Parity_Encoder;

    reg  [3:0] data;  
    wire [4:0] encode;  
    
// Instantiate the design module (by port name)
_4_bit_Even_Parity_Encoder dut (.data(data),.encode(encode));

initial begin

data = 4'b0000;  // Parity should be 0
#10;             // Wait for 10 ns

data = 4'b0001;  // Parity should be 1
#10;

data = 4'b0010;  // Parity should be 1
#10;

data = 4'b0011;  // Parity should be 0
#10;

data = 4'b0100;  // Parity should be 1
#10;

data = 4'b0101;  // Parity should be 0
#10;

data = 4'b0110;  // Parity should be 0
#10;

data = 4'b0111;  // Parity should be 1
#10;

data = 4'b1000;  // Parity should be 1
#10;

data = 4'b1001;  // Parity should be 0
#10;

data = 4'b1010;  // Parity should be 0
#10;

data = 4'b1011;  // Parity should be 1
#10;

data = 4'b1100;  // Parity should be 0
#10;

data = 4'b1101;  // Parity should be 1
#10;

data = 4'b1110;  // Parity should be 1
#10;

data = 4'b1111;  // Parity should be 0
#10;

  $finish;
end

initial begin
    $monitor("At time %t: data = %b, encode = %b", $time, data, encode);
end

endmodule
