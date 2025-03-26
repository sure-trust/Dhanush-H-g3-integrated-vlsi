`include "uvm_macros.svh"
import uvm_pkg::*;

////////////////////// item_select_transaction //////////////////
class item_sel_trans#(parameter int MAX_ITEMS = 32) extends uvm_sequence_item;
  bit item_select_valid;
  bit [$clog2(MAX_ITEMS)-1  : 0] item_select;
  
  function new(string name="item_sel_trans");
    super.new(name);
  endfunction
  
endclass

////////////////////// item_select_generator //////////////////
class item_sel_gen extends uvm_sequence#(item_sel_trans);
  item_sel_trans#(32) tg;
  
  function new(string name="item_sel_gen");
    super.new(name);
    tg = new("tg");
  endfunction
  
  virtual task body();
    repeat(10) begin
      start_item(tg);
      assert(tg.randomize());
      `uvm_info("GEN",$sformatf("item_select_valid:%b || item_select:%d ",tg.item_select_valid,tg.item_select),UVM_NONE)
      finish_item(tg);
    end
  endtask
  
endclass

////////////////////// item_select_driver //////////////////
class item_sel_drv extends uvm_driver#(item_sel_trans);
  item_sel_trans #(32) td;
  virtual item_sel_if #(32) sif;
  
  function new(string name="item_sel_drv",uvm_component parent =null);
    super.new(name,parent);
    td = new("td");
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual item_sel_if #(32))::get(this,"","sif",sif))
      `uvm_error("DRV","unable to access config db")
  endfunction
      
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(td);
      sif.item_select_valid <= td.item_select_valid;
      sif.item_select <= td.item_select;
      `uvm_info("DRV",$sformatf("item_select_valid:%b || item_select:%d",td.item_select_valid,td.item_select),UVM_NONE)
      #10;
      seq_item_port.item_done();
    end
  endtask
  
endclass

////////////////////// item_select_monitor //////////////////
class item_sel_mon extends uvm_monitor;
  item_sel_trans#(32) tm;
  virtual item_sel_if #(32) sif;
  
  function new(string path="item_sel_mon",uvm_component parent=null);
    super.new(path,parent);
    tm = new("tm");
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual item_sel_if #(32))::get(this,"","sif",sif))
       `uvm_error("MON","Unable to access config db");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      #10;
      tm.item_select_valid = sif.item_select_valid;
      tm.item_select = sif.item_select;
      `uvm_info("MON",$sformatf("item_select_valid:%b || item_select:%d",tm.item_select_valid,tm.item_select),UVM_NONE)
    end
  endtask
  
endclass

////////////////////// item_select_agent //////////////////
class item_sel_agn extends uvm_agent;
  item_sel_drv d;
  item_sel_mon m;
  uvm_sequencer#(item_sel_trans) item_sel_seqr;
  
  function new(string path ="item_sel_agent",uvm_component parent=null);
    super.new(path,parent);
    d = new("d", this);
    m = new("m", this);
    item_sel_seqr = new("item_sel_seqr", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(item_sel_seqr.seq_item_export);
  endfunction
  
endclass

////////////////////// Testbench Module //////////////////
module tb;
  item_sel_if sif();
  initial begin
    uvm_config_db#(virtual item_sel_if#(32))::set(null,"*","sif",sif);
    run_test("item_sel_agn"); 
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule

