////////////////////// item_select_monitor //////////////////
// UVM Monitor class for observing item selection transactions
// Captures DUT signals through virtual interface and broadcasts transactions
class item_sel_mon extends uvm_monitor;
  `uvm_component_utils(item_sel_mon)
  
  // Transaction object to store captured data
  item_sel_trans#(32) tm;
  
  // Virtual interfaces for signal observation
  virtual item_sel_if #(32) sif;  // Item selection interface
  virtual general_if gif;         // General interface (for clock)
  
  // Analysis port for broadcasting captured transactions
  uvm_analysis_port #(item_sel_trans) item_sel_send;
  
  // Constructor
  // @param path   - Instance path name
  // @param parent - Parent component in hierarchy
  function new(string path="item_sel_mon", uvm_component parent=null);
    super.new(path, parent);
    // Create transaction object using factory
    tm = item_sel_trans#(32)::type_id::create("tm");
    // Initialize analysis port
    item_sel_send = new("item_sel_send", this);
  endfunction
  
  // Build phase - gets virtual interfaces from config DB
  // @param phase - UVM phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Get item selection interface from config DB
    if(!uvm_config_db#(virtual item_sel_if #(32))::get(this, "", "sif", sif))
      `uvm_error("ITEM_SEL_MON", "Unable to access item selection interface in config DB");
    
    // Get general interface (for clock) from config DB  
    if(!uvm_config_db#(virtual general_if)::get(this, "", "gif", gif))
      `uvm_error("ITEM_SEL_MON", "Unable to access general interface in config DB")
  endfunction
  
  // Run phase - main monitoring operation
  // Continuously samples interface signals and broadcasts transactions
  virtual task run_phase(uvm_phase phase);
    forever begin
      // Wait for 2 clock cycles between samples
      repeat(2) @(posedge gif.clk);
      
      // Capture signal values into transaction object
      tm.item_select_valid = sif.item_select_valid;
      tm.item_select       = sif.item_select;
      
      // Log captured values
      `uvm_info("ITEM_SEL_MON",
                $sformatf("Captured transaction - item_select_valid:%b || item_select:%d",
                         tm.item_select_valid,
                         tm.item_select),
                UVM_NONE)
      
      // Broadcast transaction through analysis port
      item_sel_send.write(tm);
    end
  endtask
  
endclass
