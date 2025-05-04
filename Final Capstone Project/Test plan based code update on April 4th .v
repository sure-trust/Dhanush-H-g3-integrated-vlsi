/*
This is my link of EDA playground

https://edaplayground.com/x/UtJc

*/

/*  My Testbench code  */

/*-- TB TOP --*/

module tb_top;

  reg        clk;  // System clock (100 MHz)
  reg       rstn;  // System reset (active low)
  
  // APB interface
  
  reg         pclk;  // APB clock (100 MHz)
  reg         prstn; // APB reset (active low)
  reg         cfg_mode;
  reg  [15:0] paddr;
  reg         psel;
  reg         pwrite;
  reg  [31:0] pwdata;
  wire [31:0] prdata;
  wire        pready;

  // Currency interface
  
  reg                           currency_clk;  // Currency clock (5 MHz)
  reg                          currency_valid;
  reg [$clog2(MAX_NOTE_VAL):0] currency_value;

  // Item selection interface
  
  reg                          item_select_valid;
  reg [$clog2(MAX_ITEMS)-1:0]        item_select; 

  // Item dispense output signal interface

  wire                           item_dispense_valid;
  wire [$clog2(MAX_ITEMS)-1 : 0]       item_dispense;
  wire [15:0]                        currency_change;

  /*-- PARAMETER DECLARATION --*/
  
  parameter  SYSTEM_CLOCK_PERIOD = 10;  // 100 MHz
  parameter  APB_CLOCK_PERIOD    = 100; // 10  MHz
  parameter  CURR_CLOCK_PERIOD   = 200; // 5   MHz
  localparam MAX_ITEMS           = 32;
  localparam MAX_NOTE_VAL        = 100;  
  
  reg [31:0] rd_data; // to store read data 

  logic [$clog2(MAX_ITEMS)-1:0] expected_item;

  logic [$clog2(MAX_NOTE_VAL):0] expected_change;

  /*-- DUT INSTANTIATION --*/
  
  vending_machine #(.MAX_ITEMS(32), .MAX_NOTE_VAL(100)) dut (
    .clk(clk),
    .rstn(rstn),
    .cfg_mode(cfg_mode),
    .pclk(pclk),
    .prstn(prstn),
    .paddr(paddr),
    .psel(psel),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready),
    .currency_valid(currency_valid),
    .currency_value(currency_value),
    .item_select_valid(item_select_valid),
    .item_select(item_select),
    .item_dispense_valid(item_dispense_valid),
    .item_dispense(item_dispense),
    .currency_change(currency_change)
  );  
  
   /*-- SYSTEM_CLOCK_GENERATION --*/
  
  task SYSTEM_CLOCK_GENERATION();
    $display("System Clock is successfully generated");
    clk = 1'b0;
    forever begin
      #(SYSTEM_CLOCK_PERIOD / 2) clk = ~clk;
    end
  endtask : SYSTEM_CLOCK_GENERATION
  
  /*-- APB_CLOCK_GENERATION --*/
  
  task APB_CLOCK_GENERATION();
    $display("APB Clock is successfully generated");
    pclk = 1'b0;
    forever begin
      #(APB_CLOCK_PERIOD / 2) pclk = ~pclk;
    end
  endtask : APB_CLOCK_GENERATION
  
  /*-- CURRENCY_CLOCK_GENERATION --*/
  
  task CURRENCY_CLOCK_GENERATION();
    $display("Currency Clock is successfully generated");
    currency_clk = 1'b0;
    forever begin
      #(CURR_CLOCK_PERIOD / 2) currency_clk = ~currency_clk;
    end
  endtask : CURRENCY_CLOCK_GENERATION
  
  /*-- SYSTEM_RESET_GENERATION--*/
  
  task SYSTEM_RESET_GENERATION();
    rstn = 1'b1;
    repeat(2)
      begin
        @(posedge clk);
      end
    rstn = 1'b0;
    $display("System Negedge reset is successfully generated");
    @(posedge clk);
    rstn = 1'b1;
  endtask : SYSTEM_RESET_GENERATION
  
  /*-- SYSTEM_RESET_GENERATION--*/
  
  task APB_RESET_GENERATION();
    prstn = 1'b1;
    repeat(2)
      begin
        @(posedge pclk);
      end
    prstn = 1'b0;
    $display("APB Negedge reset is successfully generated");
    @(posedge pclk);
    prstn = 1'b1;
  endtask : APB_RESET_GENERATION
  
  initial SYSTEM_CLOCK_GENERATION();

  initial SYSTEM_RESET_GENERATION();
  
  initial APB_CLOCK_GENERATION();

  initial APB_RESET_GENERATION();
  
  initial CURRENCY_CLOCK_GENERATION();

  /*-- Simulated APB pready --*/

  // pready is not driven by DUT, so we drive it in TB

  reg pready_reg;

  assign pready = pready_reg;

  // Simulate APB slave always ready after one cycle

  always @(posedge pclk or negedge prstn) begin
    if (!prstn)
      pready_reg <= 0;
    else if (psel)
      pready_reg <= 1;  // Simulate slave ready
    else
      pready_reg <= 0;  // Idle when psel is low
  end

  /*-- Item dispense valid part --*/

  

  always @(posedge clk) begin

    if (item_dispense_valid) begin

      $display("Output: Item Dispensed Item_no: %0d, Change: %0d", item_dispense, currency_change);
  
      if (item_dispense !== expected_item || currency_change !== expected_change) begin
    
        $display("ERROR: Unexpected dispense or change! Expected item: %0d, change: %0d", expected_item, expected_change);
  
      end 

      else begin

        if (item_dispense == 10 && expected_item == 10)

           $display("INFO: No stock left — out-of-stock indication shown (item_dispense = 10)");
       
        else
      
          $display("SUCCESS: Correct item dispensed with correct change");
  
      end
    
    end
    
  end

  /*-- APB write: simulates a one-cycle handshake with pready driven by TB --*/

  task apb_write(input [15:0] addr, input [31:0] data);
  begin

    // Reset signals before starting transaction

    @(posedge pclk);
    paddr   = 'h0;
    psel    = 1'b0;
    pwrite  = 1'b0;
    pwdata  = 'h0;

    // Setup phase

    @(posedge pclk);
    paddr  = addr;
    psel   = 1'b1;
    pwrite = 1'b1;
    pwdata = data;
  
    // Wait for the slave to be ready (pready = 1)
    
    wait(pready == 1); // slave says "I'm done" after completing the operation

    $display("Writing addr = %0x with data = %0x", paddr, pwdata);

    // Cleanup → end transaction, reset bus to idle

    @(posedge pclk);
    paddr  = 'h0;
    psel   = 1'b0;
    pwrite = 1'b0;
    pwdata = 'h0;
    @(posedge pclk);

  end
  endtask

   /*-- APB Read --*/

  task apb_read(input [15:0] addr, output [31:0] rd_data);
  begin
    
    // Reset signals before starting
    
    @(posedge pclk);
    paddr    = 'h0;
    psel     = 1'b0;
    pwrite   = 1'b0;
    pwdata   = 'h0;

    // Setup phase

    @(posedge pclk);

    paddr    = addr;
    psel     = 1'b1;
    pwrite   = 1'b0;
    pwdata   = 'h0;

    // Wait for slave to respond
 
    wait (pready == 1);
    rd_data = prdata;

    $display("APB READ: addr = %0x, data = %0x", addr, prdata);
 
    // Cleanup → end transaction, reset bus to idle

    @(posedge pclk);
    paddr  = 'h0;
    psel   = 1'b0;
    pwrite = 1'b0;
    pwdata = 'h0;
    @(posedge pclk);
    
   end
  endtask

  /*-- Insert currency on currency_clk domain --*/

  task insert_currency(input [15:0] val);
    begin
      @(posedge currency_clk);

      currency_valid  = 1;
      currency_value  = val;

      @(posedge currency_clk);

      currency_valid  = 0;
    end
  endtask

  /*-- Select item on clk domain --*/

  task select_item(input [$clog2(MAX_ITEMS)-1 : 0] item_id);
    begin
      @(posedge clk);

      item_select_valid = 1;
      item_select       = item_id;

      @(posedge clk);

      item_select_valid = 0;
    end
  endtask

  /*-- TEST CASES  --*/

  initial begin
    // Initialize all signals
    rstn = 1;
    prstn = 1;
    cfg_mode = 0;
    psel = 0;
    pwrite = 0;
    pwdata = 0;
    paddr = 0;
    currency_valid = 0;
    currency_value = 0;
    item_select_valid = 0;
    item_select = 0;
    pready_reg = 0;
    rd_data = 0;

    #100;

    // Test Case 1: Configuration Mode (only item 5 and 8 used)

    cfg_mode = 1;

    apb_write(16'h0005, 32'h0002000F); // Set cost of item 5 = 15 and inventory of item 5 = 2
    apb_write(16'h0008, 32'h0003000A); // Set cost of item 8 = 10 and inventory of item 8 = 3
    
    repeat(3) @(posedge pclk); // wait a few cycles

    cfg_mode = 0;

    #100;

    // Test Case 2: Read Back Configured Values

    apb_read(16'h0005, rd_data); // Read back item 5 config

    if (rd_data !== 32'h0002000F)
      $display("ERROR: Item 5 config mismatch! Expected 0x0002000F, Got 0x%08X", rd_data);
    else
      $display("SUCCESS: Item 5 config correct");

    #100;    

    apb_read(16'h0008, rd_data); // Read back item 8 config

    if (rd_data !== 32'h0003000A)
      $display("ERROR: Item 8 config mismatch! Expected 0x0003000A, Got 0x%08X", rd_data);
    else
      $display("SUCCESS: Item 8 config correct");

    #100;
       
    // Test Case 2: Exact payment for item 8

    expected_item = 8;
    expected_change = 0;  // 10 - 10 = 0
    insert_currency(8'd10);
    select_item(8'd8); // item should dispense

    #500; 
 
    // Test Case 3: Insufficient payment for item 5

    expected_item = 5;
    expected_change = 5;  //  currency_value <= item_price (5 <= 10)
    insert_currency(8'd10);
    select_item(8'd5);  // Should not dispense 
           
    #500;

    // Test Case 4: Overpayment for item 8 (should return change)

    expected_item = 8;
    expected_change = 10;  // 20 - 10 = 10
    insert_currency(8'd20);
    select_item(8'd8);  // Expect change = currency value (20) - item value (10) = 10

    #500;

    // Test Case 5: Invalid item selection (e.g., 12 not configured)

    select_item(8'd12); // Should be ignored or flagged

    #500;

    // Test Case 6: Deplete item 5 inventory

    repeat (2) begin
      expected_item = 5;
      expected_change = 0;  // 15 - 15 = 0
      insert_currency(8'd15);
      select_item(8'd5); // Should dispense
    end

    // One more request after stock is over as left over 2 is dispensed now 0 items is there
    
    expected_item = 4'd10;       // Indicates out of stock
    expected_change = 8'd15;     // Full refund since no item was dispensed
    insert_currency(8'd15);
    select_item(8'd5); // Should not dispense

    #1000;


    $display("Simulation complete.");

    $finish;

  end

  initial begin
    $dumpfile("file.vcd"); 
    $dumpvars;
  end   
  
endmodule
