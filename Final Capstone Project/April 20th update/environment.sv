///////////////////////////////env/////////////////////////     

class vending_env extends uvm_env;
  `uvm_component_utils(vending_env)

  apb_agent apb_agn;
  currency_agent currency_agn;
  item_sel_agent item_sel_agn;
  item_disp_agent item_disp_agn;// instance of item_disp_agent is item_disp_agen
  scoreboard sb;

  function new(string name="vending_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_agn = apb_agent::type_id::create("apb_agn", this);
    currency_agn = currency_agent::type_id::create("currency_agn", this);
    item_sel_agn = item_sel_agent::type_id::create("item_sel_agn", this);
    item_disp_agn = item_disp_agent::type_id::create("item_disp_agn", this); // building an item_disp_agent inside environment tree hierachy
    sb = scoreboard::type_id::create("sb", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    
    apb_agn.mon.apb_send.connect(sb.apb_imp);
    
    currency_agn.m.currency_send.connect(sb.currency_imp);
    item_sel_agn.m.item_sel_send.connect(sb.item_sel_imp);
    item_disp_agn.m.item_disp_send.connect(sb.item_disp_imp);
  
  endfunction
endclass
