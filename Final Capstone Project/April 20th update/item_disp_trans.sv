/////////////////////////item_disp_trans Class////////////////////////////////
 
//parameterization for max items as per design file as 32 items

class item_disp_trans#(parameter int MAX_ITEMS=32) extends uvm_sequence_item;
   // factory registration
   `uvm_object_utils(item_disp_trans)
  
  bit item_dispense_valid;
  rand bit [$clog2(MAX_ITEMS)-1 : 0] item_dispense;
  bit [15:0] currency_change; 

  // construction item_disp_trans 
  
   function new(string name="item_disp_trans");
    super.new(name);
  endfunction
  
endclass
