//////////////////////////test/////////////////////////////
class vending_test extends uvm_test;
  `uvm_component_utils(vending_test)
  apb_sequence  apb_seq;
  currency_gen currency_seq;
  item_sel_gen  item_sel_seq;
  vending_env env;

  function new(string name = "vending_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = vending_env::type_id::create("env", this);
    apb_seq=apb_sequence::type_id::create("apb_seq",this);
    currency_seq=currency_gen::type_id::create("currency_seq",this);
   item_sel_seq=item_sel_gen::type_id::create("item_sel_seq",this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
   
    apb_seq.start(env.apb_agn.seqr);
      
    currency_seq.start(env.currency_agn.currency_seqr);
    item_sel_seq.start(env.item_sel_agn.item_sel_seqr);
  
    phase.drop_objection(this);
  endtask
endclass
           
