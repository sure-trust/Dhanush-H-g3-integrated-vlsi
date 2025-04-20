/////////////////currency_sequencer//////////////////////

class currency_gen extends uvm_sequence#(currency_trans);
  `uvm_object_utils(currency_gen)
  currency_trans#(100) tg;
  
  function new(string name="currency_gen");
    super.new(name);
  endfunction
  
  virtual task body();
    tg=currency_trans#(100)::type_id::create("tg");
    
    repeat(10) begin
      start_item(tg);
      assert(tg.randomize());
      `uvm_info("CURRENCY_SEQ",$sformatf("currency_select_valid:%b || currency_select_val:%d " ,tg.currency_select_valid,tg.currency_value),UVM_NONE)
      finish_item(tg);
    end
  endtask
  
endclass
