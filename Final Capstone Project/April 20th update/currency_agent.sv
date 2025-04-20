////////////////////currency_agent//////////////////////

class currency_agent extends uvm_agent;
  `uvm_component_utils(currency_agent)
  currency_drv d;
  currency_mon m;
  uvm_sequencer#(currency_trans) currency_seqr;
  
  function new(string path ="curency_agent",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d=currency_drv::type_id::create("d",this);
    m=currency_mon::type_id::create("m",this);
  currency_seqr=uvm_sequencer#(currency_trans)::type_id::create("currency_seqr",this);
 // `uvm_info("AGN","implementing agnt build phase ",UVM_NONE)
   endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(currency_seqr.seq_item_export);
    //`uvm_info("AGN","implementing agnt cnct phase ",UVM_NONE)
  endfunction
  
  
endclass
