`timescale 1us / 1ns

module TB_for_Counters_asyn_up_down_assignment;
    
    reg clk;
    reg rst;
    wire [3:0] counter_a;  
    wire [3:0] counter_b;
    
Counters_asyn_up_down_assignment dut (
     .clk(clk),
     .rst(rst),
     .counter_a(counter_a),  
     .counter_b(counter_b)   
);

initial begin
    clk = 1;
    forever #0.5 clk = ~clk; // 1us clock period
    end
    
    initial begin
        rst = 1;
        #1;    
        rst = 0;
        
        #1000; // Wait for 1000 us
        
        $finish;
    end

endmodule
