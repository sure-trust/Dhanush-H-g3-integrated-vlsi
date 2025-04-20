
// APB Monitor
class apb_monitor extends uvm_monitor;
  virtual apb_if vif;// virtual interface handle to the APB interface
  virtual general_if gif;//virtual interface handle to a general interface
  uvm_analysis_port #(apb_transaction) apb_send;//analysis port to broadcast observed transactions to scoreboard
	apb_transaction txn;//handle for transaction
  
    // Register monitor class with UVM factory 
  `uvm_component_utils(apb_monitor)
//constructor function
  function new(string name, uvm_component parent);
    super.new(name, parent);
    apb_send = new("apb_send", this);// Create the analysis port
  endfunction
  
    // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     txn = apb_transaction::type_id::create("txn");// Create a new transaction object
    // Get APB interface from the UVM config DB
    if(!uvm_config_db#(virtual apb_if)::get(this,"","vif",vif))
      `uvm_error("APB_MON","Unable to access config db");
     // Get general interface from the UVM config DB
    if(!uvm_config_db#(virtual general_if)::get(this,"","gif",gif))
      `uvm_error("APB_MON","Unable to access general intf config db");
  endfunction
  
  // Run phase
  task run_phase(uvm_phase phase);
    
   
    forever begin
      
      // Wait for both general and APB clock positive edges 
      @(posedge gif.clk);
      @(posedge vif.pclk);
       // If peripheral select (psel) is high, capture transaction
      if (vif.psel) begin
        txn.paddr = vif.paddr;// Capture address
        txn.pwrite = vif.pwrite;// Capture write/read command
        txn.pwdata = vif.pwdata;// Capture write data
        txn.pready = vif.pready; // Capture ready signal
        txn.prdata = vif.prdata;// Capture read data 
        // Log the transaction info
        `uvm_info("APB_MON", $sformatf("Transaction Generated: paddr=%0h, pwdata=%0h, pwrite=%0b,pready=%d,prdata=%d", txn.paddr, txn.pwdata, txn.pwrite,txn.pready,txn.prdata), UVM_NONE)
        apb_send.write(txn); // Send the captured transaction to connected components via analysis port
     	
      end
      
    end
  endtask
endclass
