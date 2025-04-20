/*`include "apb_trans.sv"
`include "currency_trans.sv"
`include "item_sel_trans.sv"
`include "item_disp_trans.sv"*/

///////////////////////////score board///////////////////////////////

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  uvm_analysis_imp#(apb_transaction, scoreboard) apb_imp;
  uvm_analysis_imp#(currency_trans#(100), scoreboard) currency_imp;
  uvm_analysis_imp#(item_sel_trans#(32), scoreboard) item_sel_imp;
  uvm_analysis_imp#(item_disp_trans#(32), scoreboard) item_disp_imp;

  function new(string name = "scoreboard", uvm_component parent=null);
    super.new(name, parent);
    apb_imp = new("apb_imp", this);
    currency_imp = new("currency_imp", this);
    item_sel_imp = new("item_sel_imp", this);
    item_disp_imp = new("item_disp_imp", this);
  endfunction
    
 
   function void write(uvm_object txn);
  apb_transaction apb_txn;
  currency_trans#(100) currency_txn;
  item_sel_trans#(32) item_sel_txn;
  item_disp_trans#(32) item_disp_txn;

  if ($cast(apb_txn, txn)) begin
    `uvm_info("APB_SCOREBOARD", $sformatf("Received APB Transaction: addr=%h, data=%h", apb_txn.paddr, apb_txn.pwdata), UVM_NONE);
  end
  else if ($cast(currency_txn, txn)) begin
    `uvm_info("CURRENCY_SCOREBOARD", $sformatf("Received Currency: value=%d, valid=%b", currency_txn.currency_value, currency_txn.currency_select_valid), UVM_NONE);
  end
  else if ($cast(item_sel_txn, txn)) begin
    `uvm_info("ITEM_SEL_SCOREBOARD", $sformatf("Received Item Selection: item=%d, valid=%b", item_sel_txn.item_select, item_sel_txn.item_select_valid), UVM_NONE);
  end
  else if ($cast(item_disp_txn, txn)) begin
    `uvm_info("ITEM_DISP_COREBOARD", $sformatf("Received Item Dispense: item=%d, change=%d", item_disp_txn.item_dispense, item_disp_txn.currency_change), UVM_NONE);
  end
  else begin
    `uvm_warning("SCOREBOARD", "Received unknown transaction type");
  end
endfunction


  
  
endclass
