//APB Driver Class
class apb_driver extends uvm_driver #(apb_transaction);
  virtual apb_if vif; //virtual interface handle to the APB interface
  virtual general_if gif;//irtual interface handle to a general-purpose interface
  
  //driver class with UVM factory
  `uvm_component_utils(apb_driver)

  //constructor function
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

   // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    //fetch the APB virtual interface from UVM config database
    if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",vif))
      `uvm_error("APB_DRV","Unable to access apb intf  config db");
    //fetch the general interface from UVM config database
     if(!uvm_config_db#(virtual general_if)::get(this,"","gif",gif))
       `uvm_error("APB_DRV","Unable to access general intf config db");
  endfunction
  // Task to reset the DUT using the general interface signals
  task rst_dut();
    gif.rstn<=1'b0;//Drive reset low
    gif.cfg_mode<=0;// Disable config mode
    @(posedge gif.clk);// Wait for a clock edge
    
    gif.rstn<=1;// Deassert reset
    gif.cfg_mode<=1;// Enable config mode
    //Print a UVM info message
    `uvm_info("[APB_DRV]","rst done",UVM_NONE)
    
  endtask
  
  // Run phase
  task run_phase(uvm_phase phase);
    apb_transaction txn;//handle for transaction object
    
    forever begin
      
      seq_item_port.get_next_item(txn);// Fetch the next item from the sequencer
      // If config mode is enabled, drive the APB signals
      if(gif.cfg_mode) begin
      vif.paddr <= txn.paddr;//Drive address
      vif.pwrite <= txn.pwrite;// Drive write enable
      vif.pwdata <= txn.pwdata;// Drive write data
      vif.psel <= 1;// Assert select signal
      end
      @(posedge gif.clk);
      @(posedge vif.pclk);
      while (!vif.pready);// Wait for pready to be asserted (wait until slave is ready)
      
      // If it's a read transaction, capture the read data
      if (!txn.pwrite)
        txn.prdata = vif.prdata;

      vif.psel <= 0;// Deassert psel after transaction
      
      // Print transaction info
      `uvm_info("APB_DRV", $sformatf("Transaction Generated: paddr=%0h, pwdata=%0h, pwrite=%0b", txn.paddr, txn.pwdata, txn.pwrite), UVM_NONE)
     
      seq_item_port.item_done();//transaction is complete
     
    end
  endtask
endclass


