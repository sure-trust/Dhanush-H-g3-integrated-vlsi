`timescale 1ns / 1ps
module _4_bit_Sequence_detector_non_overlapping(
    input clk,rst,din, // (din)Input bit stream
    output reg out     // Output signal (high when "1011" is detected)
);

    // State encoding
    parameter Sin   = 3'b000;  // Initial state (waiting for '1')  
    parameter S1    = 3'b001;  // Detected '1'                     
    parameter S10   = 3'b010;  // Detected '10'                    
    parameter S101  = 3'b011;  // Detected '101'                   
    parameter S1011 = 3'b100;  // Detected '1011'                  

    reg [2:0] current_state, next_state;  // State registers

    // State transition block (sequential)
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= Sin;  // On reset, go to initial state
        else
            current_state <= next_state;  // Update to the next state
    end

    // Next state logic (combinational)
    always @(*) begin
        case (current_state)
            Sin: begin
                if (din==1)
                    next_state = S1;  // Move to state S1 if '1' is detected
                else
                    next_state = Sin;  // Stay in state Sin if '0'
            end
            S1: begin
                if (din==0)
                    next_state = S10;  // Move to state S10 if '0' follows '1'
                else
                    next_state = S1;  // Stay in state S1 if '1'
            end
            S10: begin
                if (din==1)
                    next_state = S101;  // Move to state S101 if '1' follows '10'
                else
                    next_state = Sin;  // Reset to Sin if '0' follows '10'
            end
            S101: begin
                if (din==1)
                    next_state = S1011;  // Move to state S1011 if '1' follows '101'
                else
                    next_state = S10;  // Move to S10 if '0' follows '101'
            end
            S1011: begin
                next_state = Sin;  // Return to initial state after detecting '1011'
            end
            default: next_state = Sin;  // Default case
        endcase
    end

    // Output logic (Moore machine: output depends only on current state)
    always @(*) begin
        case (current_state)
            S1011:   out = 1'b1;  // Output high when in state S1011 (sequence detected)
            default: out = 1'b0;  // Output low in all other states
        endcase
    end

endmodule
