//////////////////////currency_agent//////////////////

class currency_trans#(parameter int MAX_NOTE_VAL=100) extends uvm_sequence_item;
  `uvm_object_utils(currency_trans)
  
  bit currency_select_valid;
  rand bit [$clog2(MAX_NOTE_VAL)-1  : 0] currency_value;
  
  function new(string name="currency_trans");
    super.new(name);
  endfunction

endclass
