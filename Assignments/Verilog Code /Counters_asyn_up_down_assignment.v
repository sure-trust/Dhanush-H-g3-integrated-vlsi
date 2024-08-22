`timescale 1us / 1ns

module Counters_asyn_up_down_assignment(
    input clk,rst,
    output reg [3:0] counter_a,  // 4-bit Counter A
    output reg [3:0] counter_b   // 4-bit Counter B
);

    // Initialize both counters at T=0
    initial 
    begin
        counter_a = 4'b0000;  // Counter A starts at 0000 (decimal 0)
        counter_b = 4'b1111;  // Counter B starts at 1111 (decimal 15)
    end

    always @(posedge clk or posedge rst) 
    begin
        if (rst) 
        begin
            counter_a <= 4'b0000; // up counter initial
            counter_b <= 4'b1111; // down counter initial
        end 
        else 
        begin
            counter_a <= counter_a + 1;// Increment Counter A
            
            // If Counter A reaches 12 (1100 in binary), decrement Counter B
            if (counter_a == 4'b1100) begin
                counter_b <= counter_b - 1;
            end
        end
    end

endmodule


/*
2. Decimal Values at T = 0.2 ms:
   Clock cycles=0.0002×1,000,000=200 cycles
   200/16 = 12.5 (12 times it goes from 0 - 15)
   16*200 = 192 remaing is 8 so at 200 counter A is 8
   Counter A: 8
   In 200 cycles, Counter A reaches 12 a total of 12 times.
   Counter B would decrement by 12.
   Initial value of Counter B = 15, so at T = 0.2 ms, Counter B = 15 - 12 = 3.
   Counter B: 3

3. Frequency of B0: 62.5 kHz
   If Counter B is decremented every 16 clock cycles, it means the frequency at which 
   Counter B toggles is clk freq / no.of.cycles
   With a clock frequency of 1 MHz and toggling every 16 cycles
   Frequency of B0= 1 MHz / 16 = 62.5 kHz
*/

