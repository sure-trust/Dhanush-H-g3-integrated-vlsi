// Transaction class for item selection
// Parameter MAX_ITEMS defines the maximum number of items that can be selected
class item_sel_trans#(parameter int MAX_ITEMS = 32) extends uvm_sequence_item;
  
  // Register this class with UVM factory
  `uvm_object_utils(item_sel_trans);
  
  // Signal to indicate when the item_select is valid
  bit item_select_valid;
  
  // Randomizable selection field - size is dynamically calculated based on MAX_ITEMS
  // Uses $clog2 to determine the minimum number of bits needed to represent MAX_ITEMS
  rand bit [$clog2(MAX_ITEMS)-1 : 0] item_select;
  
  // Constructor
  // name - instance name for this transaction object
  function new(string name="item_sel_trans");
    super.new(name);
  endfunction
  
endclass
