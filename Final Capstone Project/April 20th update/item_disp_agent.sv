/////////////////////////item_dispe_agent Class////////////////////////////////
              
class item_disp_agent extends uvm_agent;
  // factory registration
  `uvm_component_utils(item_disp_agent)
  // instance creation
  item_disp_mon m;
 
  // construction item_disp_agent 
  function new(string path ="item_disp_agent",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
 // build phase 
 virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   // creating monitor inside the item_disp_agent
   m = item_disp_mon::type_id::create("m",this);
  endfunction
endclass
