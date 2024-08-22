`timescale 1ns / 1ps

module TB_for_4_bit_Sequence_detector_non_overlapping;

    reg   clk,rst,din; 
    wire  out;
    
    // Instantiate the design module (by port name)
     _4_bit_Sequence_detector_non_overlapping dut (.clk(clk),.rst(rst),.din(din),.out(out));

    // Generate clock signal
    always #5 clk = ~clk; // 10ns clock period
    
    initial begin
        // Initialize inputs
        clk = 1;
        rst = 1;
        din = 0;
        
        // Applying reset
        #10;
        rst = 0;
        
        // Applying test vectors
        
        // Sequence: 1011
        din = 1; #10;   // Applying 1
        din = 0; #10;   // Applying 0
        din = 1; #10;   // Applying 1
        din = 1; #10;   // Applying 1 -> out = 1

        // Next Sequence: 110110 (non-overlapping)
        din = 1; #10;   // Applying 1
        din = 1; #10;   // Applying 1
        din = 0; #10;   // Applying 0
        din = 1; #10;   // Applying 1
        din = 1; #10;   // Applying 1 -> out = 1
        din = 0; #10;   // Applying 0
        
        #20;
        $finish;
    end

endmodule
