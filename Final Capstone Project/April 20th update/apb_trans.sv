// APB Transaction Class
class apb_transaction extends uvm_sequence_item;
  rand bit [15:0] paddr;   //16-bit random address signal (paddr) for APB transaction
  rand bit [31:0] pwdata; //32-bit random write data signal (pwdata) for APB write transactions 
  rand bit pwrite; //random control signal (pwrite) to specify read (0) or write (1) operation        
  bit [31:0] prdata; //32-bit read data signal (prdata) to hold the data read from the APB slave      
  bit psel;//select signal (psel) to indicate APB peripheral selection (active high)
  bit pready;//ready signal (pready) to indicate when the APB slave is ready to complete the transaction

  // Register the class with the UVM factory
  `uvm_object_utils(apb_transaction)

  // Constructor function
  function new(string name = "apb_transaction");
    super.new(name);
  endfunction

endclass
