/////////////////////currency_driver///////////////////////////////////

class currency_drv extends uvm_driver#(currency_trans);
  `uvm_component_utils(currency_drv)
  currency_trans #(100) td;
  virtual currency_if #(100) cif;
  virtual general_if gif;
  function new(string name="currency_drv",uvm_component parent =null);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    td=currency_trans#(100)::type_id::create("td");
    
    if(!uvm_config_db#(virtual currency_if #(100))::get(this,"","cif",cif))
      `uvm_error("CURRENCY_DRV","unable to acces currency intf config db")
    if(!uvm_config_db#(virtual general_if)::get(this,"","gif",gif))
      `uvm_error("CURRENCY_DRV","unable to acces general intf config db")
    
  endfunction
      
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(td);
      
      cif.currency_select_valid<=td.currency_select_valid;
      cif.currency_value<=td.currency_value;
      
      `uvm_info("CURRENCY_DRV",$sformatf("currency_select_valid:%b || currency_value:%d " ,td.currency_select_valid,td.currency_value),UVM_NONE)
      repeat(2)@(posedge gif.clk);
      seq_item_port.item_done();
     
    end
  endtask
  
endclass
