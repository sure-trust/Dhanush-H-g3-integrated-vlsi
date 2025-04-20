//APB sequencer

class apb_sequencer extends uvm_sequencer #(apb_transaction);
  //Register sequencer class with UVM factory
  `uvm_component_utils(apb_sequencer)
//constructor function
  function new(string name = "apb_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass


// APB Agent
class apb_agent extends uvm_agent;
  // Declare the agent components: driver, monitor, and sequencer
  apb_driver drv;
  apb_monitor mon;
  apb_sequencer seqr;
 // Register agent class with the UVM factory
  `uvm_component_utils(apb_agent)
//constructor function
  function new(string name = "apb_agent", uvm_component parent);
    super.new(name, parent);
  endfunction
//Buils phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = apb_driver::type_id::create("drv", this); // Create driver instance
    mon = apb_monitor::type_id::create("mon", this); // Create monitor instance
    seqr = apb_sequencer::type_id::create("seqr", this); // Create sequencer instance
  endfunction
//connect phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export); // Connect the driver's seq_item_port to the sequencer's export
  endfunction
endclass

