/////////////////////////item_disp_mon//////////////////////////////// (updated line no 63)

class item_disp_mon extends uvm_monitor;
  // factory registration
  `uvm_component_utils(item_disp_mon);
  
  item_disp_trans#(32) tm; // tm instance for item_disp_trans
  
  virtual item_disp_if #(32) dif; // dif instance for item dispense interface with DUT
  
  virtual general_if gif; // gif as general interface for sys clock
  
  uvm_analysis_port #(item_disp_trans) item_disp_send; // sends item_disp_trans objects out of the monitor to scb in line 33 of env.
  
  // constructor for item_disp_mon called from item_disp_agent using create method
  
  function new(string path="item_disp_mon",uvm_component parent=null);
    
    super.new(path,parent);
    
    // creating memory space for item_disp_send at the time of item_disp_mon constructor called
    
   item_disp_send = new("item_disp_send",this);
    
  endfunction
  
  // Build phase 
  
  virtual function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    // Creates a transaction object `tm` using UVM factory.
    
    tm = item_disp_trans#(32)::type_id::create("tm");
    
    // If the `dif` wasn't set properly, show an error message.
    
    if(!uvm_config_db#(virtual item_disp_if #(32))::get(this,"","dif",dif))
      
      `uvm_error("ITEM_DISP_MON","Unable to access item disp intf config db");
    
    // If it fails to get `gif`, show an error message.
    
    if(!uvm_config_db#(virtual general_if)::get(this,"","gif",gif))
      
       `uvm_error("ITEM_DISP_MON","unable to access general intf config db")
     
  endfunction
      
  // Run phase    
     
  virtual task run_phase(uvm_phase phase);
 
    forever begin
      //Wait for 2 positive clock edges before sampling data for timing mismatches
     repeat(2)@(posedge gif.clk);
      // sending info to item_disp_trans from interface through monitor
      tm.item_dispense_valid = dif.item_dispense_valid;
      tm.item_dispense = dif.item_dispense;
      tm.currency_change=dif.currency_change;
      
      `uvm_info("ITEM_DISP_MON",$sformatf("item_dispense_valid:%b || item_dispense:%d || currency_change :%d",tm.item_dispense_valid,tm.item_dispense,tm.currency_change),UVM_NONE)
      
      item_disp_send.write(tm);// to scoreboard
      
    end
    
  endtask

  
endclass
