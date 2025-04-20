////////////////////// item_select_agent //////////////////
// UVM Agent class that encapsulates Driver, Monitor and Sequencer
// Coordinates the transaction flow between environment components
class item_sel_agent extends uvm_agent;
  `uvm_component_utils(item_sel_agent)
  
  // Component handles:
  item_sel_drv d;                          // Driver instance
  item_sel_mon m;                          // Monitor instance
  uvm_sequencer#(item_sel_trans) item_sel_seqr;  // Sequencer instance
  
  // Constructor
  // @param path   - Hierarchical path name
  // @param parent - Parent component in UVM hierarchy
  function new(string path = "item_sel_agent", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Build Phase - creates and constructs sub-components
  // @param phase - UVM phase object
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Create driver instance using factory
    d = item_sel_drv::type_id::create("d", this);
    
    // Create monitor instance using factory
    m = item_sel_mon::type_id::create("m", this);
    
    // Create sequencer instance using factory
    item_sel_seqr = uvm_sequencer#(item_sel_trans)::type_id::create("item_sel_seqr", this);
  endfunction
  
  // Connect Phase - establishes TLM connections between components
  // @param phase - UVM phase object
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // Connect driver's sequence item port to sequencer's export
    d.seq_item_port.connect(item_sel_seqr.seq_item_export);
  endfunction
  
endclass
