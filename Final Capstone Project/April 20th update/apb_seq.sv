// APB Sequence 
class apb_sequence extends uvm_sequence #(apb_transaction);
  
  //Register the sequence class with the UVM factory
  `uvm_object_utils(apb_sequence)

  // Constructor function
  function new(string name = "apb_sequence");
    super.new(name);
  endfunction

  // Task 'body' contains the main behavior of the sequence
  task body();
     // Create a handle for an APB transaction
    apb_transaction txn = apb_transaction::type_id::create("txn");
// Repeat 10 times to generate 10 transactions
    repeat (10) begin 
      start_item(txn); //Start the transaction item
      assert(txn.randomize()); // Randomize the transaction fields
     
      // Print the transaction details to the simulation log 
      `uvm_info("APB_SEQ", $sformatf("Transaction Generated: paddr=%0h, pwdata=%0h, pwrite=%0b", txn.paddr, txn.pwdata, txn.pwrite), UVM_NONE)
     
      finish_item(txn); //Complete the transaction item
       
      end
  endtask
endclass

