////////////////////// item_select_driver //////////////////
// UVM Driver class for item selection interface
// Receives transactions from sequence and drives them to DUT via virtual interface
class item_sel_drv extends uvm_driver#(item_sel_trans);
  `uvm_component_utils(item_sel_drv)
  
  // Transaction object to hold items from sequence
  item_sel_trans#(32) td;
  
  // Virtual interfaces for driving signals and clock control
  virtual item_sel_if#(32) sif;  // Item selection specific interface
  virtual general_if gif;         // General purpose interface (for clock)
  
  // Constructor
  // @param name  - Instance name of driver
  // @param parent - Parent component in hierarchy
  function new(string name="item_sel_drv", uvm_component parent=null);
    super.new(name, parent);
    // Create transaction object using factory
    td = item_sel_trans#(32)::type_id::create("td");
  endfunction
  
  // Build phase - gets virtual interfaces from config DB
  // @param phase - UVM phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Get item selection interface from config DB
    if(!uvm_config_db#(virtual item_sel_if#(32))::get(this, "", "sif", sif))
      `uvm_error("ITEM_SEL_DRV", "Unable to access item selection interface in config DB")
    
    // Get general interface (for clock) from config DB  
    if(!uvm_config_db#(virtual general_if)::get(this, "", "gif", gif))
      `uvm_error("ITEM_SEL_DRV", "Unable to access general interface in config DB")
  endfunction
      
  // Run phase - main driver operation
  // Continuously gets transactions and drives them to DUT
  virtual task run_phase(uvm_phase phase);
    forever begin
      // Get next transaction from sequencer
      seq_item_port.get_next_item(td);
      
      // Drive transaction values to interface signals
      sif.item_select_valid <= td.item_select_valid;
      sif.item_select       <= td.item_select;
      
      // Log driven values
      `uvm_info("ITEM_SEL_DRV", 
                $sformatf("Driving transaction - item_select_valid:%b || item_select:%d",
                         td.item_select_valid, 
                         td.item_select), 
                UVM_NONE)
      
      // Wait for 2 clock cycles before completing transaction
      repeat(2) @(posedge gif.clk);
      
      // Signal completion to sequencer
      seq_item_port.item_done();
    end
  endtask
  
endclass
