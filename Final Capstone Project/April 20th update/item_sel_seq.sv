////////////////////// item_select_generator //////////////////
// UVM sequence class for generating item selection transactions
// Generates multiple randomized item_sel_trans transactions
class item_sel_gen extends uvm_sequence#(item_sel_trans);
  `uvm_object_utils(item_sel_gen)
  
  // Transaction handle that will be randomized and sent
  item_sel_trans#(32) tg;  // Using 32 as MAX_ITEMS parameter
  
  // Constructor
  // @param name - Instance name for this sequence
  function new(string name="item_sel_gen");
    super.new(name);
    // Create the transaction object using UVM factory
    tg = item_sel_trans#(32)::type_id::create("tg");
  endfunction
  
  // Main sequence body task
  // Generates and sends 10 randomized transactions
  virtual task body();
    repeat(10) begin
      // Start the sequence item (blocks until driver is ready)
      start_item(tg);
      
      // Randomize the transaction fields
      assert(tg.randomize());
      
      // Log the generated transaction values
      `uvm_info("ITEM_SEL_SEQ",
                $sformatf("Generated transaction - item_select_valid:%b || item_select:%d",
                         tg.item_select_valid,
                         tg.item_select),
                UVM_NONE)
      
      // Finish the item (sends to driver)
      finish_item(tg);
    end
  endtask
  
endclass
