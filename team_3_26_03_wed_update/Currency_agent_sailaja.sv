//Golla Sailaja ->currency agent
// Code your design here

module vending_machine #(
  parameter  MAX_ITEMS = 32,parameter MAX_NOTE_VAL = 100)
(

//General interface
input clk,
input rstn,
input cfg_mode,

//APB Interface
input         pclk,
input         prstn,
input  [15:0] paddr,
input         psel,
input         pwrite,
input  [31:0] pwdata,
output [31:0] prdata,
output        pready,

//Coin or Note interface
input currency_valid,
input [$clog2(MAX_NOTE_VAL) : 0] currency_value,

//Item Select Interface
input item_select_valid,
input [$clog2(MAX_ITEMS)-1 : 0] item_select,

//Ouput interface
output item_dispense_valid,
output [$clog2(MAX_ITEMS)-1 : 0] item_dispense,
output [15:0] currency_change
);
  
  
endmodule
//////////////////////**apb interface**/////////////////////////
interface apb_if;
  logic      pclk,prstn,psel, pwrite,pready;
  logic  [15:0] paddr;         
  logic  [31:0] pwdata,prdata;        
  
endinterface
///////////////////////**currency interface**////////////////////
interface currency_if#(parameter int MAX_NOTE_VAL=100);
  logic currency_select_valid;
  logic [$clog2(MAX_NOTE_VAL)-1 : 0] currency_value;
  
endinterface
//////////////////////** item_sel interface**////////////////////
interface item_sel_if #(parameter int MAX_ITEMS = 32);
  logic item_select_valid;
  logic [$clog2(MAX_ITEMS)-1 : 0] item_select;
endinterface
////////////////////////**item_disp interface**///////////////
interface item_disp_if #(parameter int MAX_ITEMS = 32);
  logic item_dispense_valid;
  logic [$clog2(MAX_ITEMS)-1 : 0] item_dispense;
  logic [15:0] currency_change; 
endinterface
/*************************************tb*******************************************/

// Code your testbench here
// or browse Examples

`include "uvm_macros.svh"
import uvm_pkg::*;
//////////////////////currency_agent//////////////////
class currency_trans#(parameter int MAX_NOTE_VAL=100) extends uvm_sequence_item;
  `uvm_object_utils(currency_trans)
  
  bit currency_select_valid;
  bit [$clog2(MAX_NOTE_VAL)-1  : 0] currency_value;
  
  function new(string name="currency_trans");
    super.new(name);
  endfunction
  
  /*constraint item_sel_val {
    item_select_valid dist{1:=80 ,0:=20};
  }*/
endclass
//////////////////////////////////////////////////////
class currency_gen extends uvm_sequence#(currency_trans);
  `uvm_object_utils(currency_gen)
  currency_trans#(100) tg;
  
  function new(string name="currency_gen");
    super.new(name);
  endfunction
  
  virtual task body();
    tg=currency_trans#(100)::type_id::create("tg");
    repeat(10) begin
      start_item(tg);
      assert(tg.randomize());
      `uvm_info("GEN",$sformatf("currency_select_valid:%b || currency_select_val:%d " ,tg.currency_select_valid,tg.currency_value),UVM_NONE)
      finish_item(tg);
    end
  endtask
  
endclass
////////////////////////////////////////////////////////
class currency_drv extends uvm_driver#(currency_trans);
  `uvm_component_utils(currency_drv)
  currency_trans #(100) td;
  virtual currency_if #(100) cif;
  
  function new(string name="currency_drv",uvm_component parent =null);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    td=currency_trans#(100)::type_id::create("td");
    
    if(!uvm_config_db#(virtual currency_if #(100))::get(this,"","cif",cif))
      `uvm_error("DRV","unable to acces config db")
      
      `uvm_info("DRV","implementing DRV BUILD phase ",UVM_NONE)
  endfunction
      
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(td);
      
      cif.currency_select_valid<=td.currency_select_valid;
      cif.currency_value<=td.currency_value;
      
      `uvm_info("DRV",$sformatf("currency_select_valid:%b || currency_value:%d " ,td.currency_select_valid,td.currency_value),UVM_NONE)
    #10;
      seq_item_port.item_done();
      `uvm_info("DRV","implementing DRV RUN phase ",UVM_NONE)
    end
  endtask
  
endclass
////////////////////////////////////////////
class currency_mon extends uvm_monitor;
  `uvm_component_utils(currency_mon)
  currency_trans#(100) tm;
  virtual currency_if #(100) cif;
 // uvm_analysis_port #(currency_trans) send;
  function new(string path="currency_mon",uvm_component parent=null);
    super.new(path,parent);
    //send=new("send",this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tm=currency_trans#(100)::type_id::create("tm");
    if(!uvm_config_db#(virtual currency_if #(100))::get(this,"","cif",cif))
       `uvm_error("MON","unable to acces config db");
    
    `uvm_info("MON","implementing MON BUILD phase ",UVM_NONE)
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      #10;
      
      tm.currency_select_valid=cif.currency_select_valid;
      tm.currency_value=cif.currency_value;
     
      `uvm_info("MON",$sformatf("item_select_valid:%b || item_select:%d " ,tm.currency_select_valid,tm.currency_value),UVM_NONE)
      
      //send.write(tm);
      `uvm_info("MON","implementing MON RUN phase ",UVM_NONE)
    end
    
  endtask
  
endclass
////////////////////////////////////////
class currency_agn extends uvm_agent;
  `uvm_component_utils(currency_agn)
  currency_drv d;
  currency_mon m;
  uvm_sequencer#(currency_trans) currency_seqr;
  
  function new(string path ="agent",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d=currency_drv::type_id::create("d",this);
    m=currency_mon::type_id::create("m",this);
  currency_seqr=uvm_sequencer#(currency_trans)::type_id::create("currency_seqr",this);
  `uvm_info("AGN","implementing agnt build phase ",UVM_NONE)
   endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(currency_seqr.seq_item_export);
    `uvm_info("AGN","implementing agnt cnct phase ",UVM_NONE)
  endfunction
  
  
endclass
///////////////////////////////////////////////////////
module tb;
  currency_if cif();
  initial begin
    uvm_config_db#(virtual currency_if#(100))::set(null,"*","cif",cif);
    run_test("currency_agn"); 
 end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
  end
    
  
  
  
endmodule
      
      
 /////////////////////////////////////////////

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(td);
      
      cif.currency_select_valid<=td.currency_select_valid;
      cif.currency_value<=td.currency_value;
      
      `uvm_info("DRV",$sformatf("currency_select_valid:%b || currency_value:%d " ,td.currency_select_valid,td.currency_value),UVM_NONE)
    #10;
      seq_item_port.item_done();
      `uvm_info("DRV","implementing DRV RUN phase ",UVM_NONE)
    end
  endtask
  
endclass
////////////////////////////////////////////
class currency_mon extends uvm_monitor;
  `uvm_component_utils(currency_mon)
  currency_trans#(100) tm;
  virtual currency_if #(100) cif;
 // uvm_analysis_port #(currency_trans) send;
  function new(string path="currency_mon",uvm_component parent=null);
    super.new(path,parent);
    //send=new("send",this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tm=currency_trans#(100)::type_id::create("tm");
    if(!uvm_config_db#(virtual currency_if #(100))::get(this,"","cif",cif))
       `uvm_error("MON","unable to acces config db");
    
    `uvm_info("MON","implementing MON BUILD phase ",UVM_NONE)
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      #10;
      
      tm.currency_select_valid=cif.currency_select_valid;
      tm.currency_value=cif.currency_value;
     
      `uvm_info("MON",$sformatf("item_select_valid:%b || item_select:%d " ,tm.currency_select_valid,tm.currency_value),UVM_NONE)
      
      //send.write(tm);
      `uvm_info("MON","implementing MON RUN phase ",UVM_NONE)
    end
    
  endtask
  
endclass
////////////////////////////////////////
class currency_agn extends uvm_agent;
  `uvm_component_utils(currency_agn)
  currency_drv d;
  currency_mon m;
  uvm_sequencer#(currency_trans) currency_seqr;
  
  function new(string path ="agent",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    d=currency_drv::type_id::create("d",this);
    m=currency_mon::type_id::create("m",this);
  currency_seqr=uvm_sequencer#(currency_trans)::type_id::create("currency_seqr",this);
  `uvm_info("AGN","implementing agnt build phase ",UVM_NONE)
   endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(currency_seqr.seq_item_export);
    `uvm_info("AGN","implementing agnt cnct phase ",UVM_NONE)
  endfunction
  
  
endclass
///////////////////////////////////////////////////////
module tb;
  currency_if cif();
  initial begin
    uvm_config_db#(virtual currency_if#(100))::set(null,"*","cif",cif);
    run_test("currency_agn"); 
 end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
  end
    
  
  
  
endmodule
      
      
 /////////////////////////////////////////////
