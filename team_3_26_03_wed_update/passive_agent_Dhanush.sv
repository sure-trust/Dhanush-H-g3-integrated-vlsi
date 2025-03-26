//interface file

interface vending_machine_if #(parameter MAX_ITEMS = 32, parameter MAX_NOTE_VAL = 100) 
                             (input logic clk, input logic rstn);

  // Mode signal  
  logic cfg_mode;

  // APB Interface Signals  
  logic pclk, prstn, psel, pwrite, pready;
  logic [15:0] paddr;
  logic [31:0] pwdata, prdata;

  // Currency Input Signals  
  logic currency_valid;
  logic [$clog2(MAX_NOTE_VAL)-1:0] currency_value;  // Dynamically determined width when we parameterize

  // Item Select Signals  
  logic item_select_valid;
  logic [$clog2(MAX_ITEMS)-1:0] item_select;  // Dynamically determined width when we parameterize

  // Output Signals  
  logic item_dispense_valid;
  logic [$clog2(MAX_ITEMS)-1:0] item_dispense;  // Matches item_select width
  logic [$clog2(MAX_NOTE_VAL)-1:0] currency_change;  // Change is now dynamic based on max note value I am alloacting that much size bits

  // Clocking block for APB transactions

  clocking apb_cb @(posedge pclk);
    default input #1 output #1;
    output psel, pwrite, paddr, pwdata;
    input prdata, pready;
  endclocking

  // Clocking block for currency input

  clocking currency_cb @(posedge clk);
    default input #1 output #1;
    output currency_valid, currency_value;
  endclocking

  // Clocking block for item selection

  clocking item_select_cb @(posedge clk);
    default input #1 output #1;
    output item_select_valid, item_select;
  endclocking

  // Clocking block for output verification

  clocking output_cb @(posedge clk);
    default input #1 output #1;
    input item_dispense_valid, item_dispense, currency_change;
  endclocking

endinterface


//dispense_transaction.sv

class dispense_transaction extends uvm_sequence_item;

    `uvm_object_utils(dispense_transaction) // Register class for UVM factory

    // Declare variables to store dispense transaction details

    function new(string name = "dispense_transaction");
        super.new(name);
        // Initialize variables if needed
    endfunction

    // Function to return a formatted string representation of the transaction

endclass



//dispense_monitor.sv

class dispense_monitor extends uvm_monitor;

    `uvm_component_utils(dispense_monitor) // Register class for UVM factory

    // Declare virtual interface handle

    // Declare analysis port to send transaction data

    function new(string name = "dispense_monitor", uvm_component parent);
        super.new(name, parent);
        // Initialize analysis port
    endfunction

    // Build phase: Get interface handle from UVM config database

    // Run phase: Continuously monitor DUT signals and create transactions

endclass


