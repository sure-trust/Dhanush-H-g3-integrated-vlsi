//////////////////currency_monitor//////////////////////////

class currency_mon extends uvm_monitor;
  `uvm_component_utils(currency_mon)
  currency_trans#(100) tm;
  virtual currency_if #(100) cif;
  virtual general_if gif;
  uvm_analysis_port #(currency_trans) currency_send;
  function new(string path="currency_mon",uvm_component parent=null);
    super.new(path,parent);
    currency_send=new("currency_send",this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tm=currency_trans#(100)::type_id::create("tm");
    if(!uvm_config_db#(virtual currency_if #(100))::get(this,"","cif",cif))
      `uvm_error("CURRENCY_MON","unable to acces currency intf config db");
    if(!uvm_config_db#(virtual general_if)::get(this,"","gif",gif))
      `uvm_error("CURRENCY_MON","unable to acces general intfconfig db");
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    forever begin
      
      repeat(2)@(posedge gif.clk)
      tm.currency_select_valid=cif.currency_select_valid;
      tm.currency_value=cif.currency_value;
     
      `uvm_info("CURRENCY_MON",$sformatf("item_select_valid:%b || item_select:%d " ,tm.currency_select_valid,tm.currency_value),UVM_NONE)
      
      currency_send.write(tm);
      //`uvm_info("MON","implementing MON RUN phase ",UVM_NONE)
    end
    
  endtask
  
endclass
////////////////////////////////////////
