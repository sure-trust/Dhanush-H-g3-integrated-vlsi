Created by Tarak Patel
///Design code
module vending_machine_tb;
  reg clk, rstn;
  reg item_select_valid;
  reg [$clog2(MAX_ITEMS)-1 : 0] item_select;
  reg currency_valid;
  reg [$clog2(MAX_NOTE_VAL)-1 : 0] currency_value;
  wire item_dispense_valid;
  wire [$clog2(MAX_ITEMS)-1 : 0] item_dispense;
  
  // Instantiate DUT
  vending_machine #(32, 100) dut (
    .clk(clk),
    .rstn(rstn),
    .item_select_valid(item_select_valid),
    .item_select(item_select),
    .currency_valid(currency_valid),
    .currency_value(currency_value),
    .item_dispense_valid(item_dispense_valid),
    .item_dispense(item_dispense)
  );
  
  // Clock generation
  always #5 clk = ~clk;
  
  // Test Sequence
  initial begin
    clk = 0;
    rstn = 0;
    item_select_valid = 0;
    item_select = 0;
    currency_valid = 0;
    currency_value = 0;
    
    // Reset
    #10 rstn = 1;
    
    // Insert currency and select an item
    #10 currency_valid = 1; currency_value = 20;
    #10 currency_valid = 0;
    
    #10 item_select_valid = 1; item_select = 3;
    #10 item_select_valid = 0;
    
    #50 $finish;
  end
  
  initial begin
    $dumpfile("vending_machine_tb.vcd");
    $dumpvars(0, vending_machine_tb);
  end
endmodule
