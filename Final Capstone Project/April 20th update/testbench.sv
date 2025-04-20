// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
`include "uvm_macros.svh"
import uvm_pkg::*;
/////////////////////////////////////////////
`include "apb_trans.sv"
`include "apb_seq.sv"
`include "apb_drv.sv"
`include "apb_mon.sv"
`include "apb_agent.sv"

`include "currency_trans.sv"
`include "currency_seq.sv"
`include "currency_drv.sv"
`include "currency_mon.sv"
`include "currency_agent.sv"

`include "item_sel_trans.sv"
`include "item_sel_seq.sv"
`include "item_sel_drv.sv"
`include "item_sel_mon.sv"
`include "item_sel_agent.sv"

`include "item_disp_trans.sv"
`include "item_disp_mon.sv"
`include "item_disp_agent.sv"

`include "scoreboard.sv"
`include "environment.sv"
`include "test.sv"

/////////////////////////module tb///////////////////////////////
module tb;
  general_if gif();
  apb_if vif();
  currency_if#(100) cif();
  item_sel_if #(32) sif();
  item_disp_if #(32) dif();
  
  initial begin
    gif.clk=0;
    gif.rstn=0;
    #10;
    gif.rstn=1;
    gif.cfg_mode<=1;
    vif.pclk=0;
  end
  always #5gif.clk=~gif.clk;
  always #50vif.pclk=~vif.pclk;
  
  vending_machine dut(gif.clk,gif.rstn,gif.cfg_mode,vif.pclk,vif.prstn,vif.paddr,vif.psel,vif.pwrite,vif.pwdata,vif.prdata,vif.pready,cif.currency_select_valid,cif.currency_value,sif.item_select_valid,sif.item_select,dif.item_dispense_valid,dif.item_dispense,dif.currency_change);
  
  initial begin
    uvm_config_db#(virtual general_if)::set(null,"*","gif",gif);
    uvm_config_db#(virtual  apb_if)::set(null,"*","vif",vif);
    uvm_config_db#(virtual currency_if#(100))::set(null,"*","cif",cif);
    uvm_config_db#(virtual  item_sel_if #(32))::set(null,"*","sif",sif);
     uvm_config_db#(virtual  item_disp_if #(32))::set(null,"*","dif",dif);
    run_test("vending_test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
  end
  
endmodule// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
`include "uvm_macros.svh"
import uvm_pkg::*;
/////////////////////////////////////////////
`include "apb_trans.sv"
`include "apb_seq.sv"
`include "apb_drv.sv"
`include "apb_mon.sv"
`include "apb_agent.sv"

`include "currency_trans.sv"
`include "currency_seq.sv"
`include "currency_drv.sv"
`include "currency_mon.sv"
`include "currency_agent.sv"

`include "item_sel_trans.sv"
`include "item_sel_seq.sv"
`include "item_sel_drv.sv"
`include "item_sel_mon.sv"
`include "item_sel_agent.sv"

`include "item_disp_trans.sv"
`include "item_disp_mon.sv"
`include "item_disp_agent.sv"

`include "scoreboard.sv"
`include "environment.sv"
`include "test.sv"

/////////////////////////module tb///////////////////////////////
module tb;
  general_if gif();
  apb_if vif();
  currency_if#(100) cif();
  item_sel_if #(32) sif();
  item_disp_if #(32) dif();
  
  initial begin
    gif.clk=0;
    gif.rstn=0;
    #10;
    gif.rstn=1;
    gif.cfg_mode<=1;
    vif.pclk=0;
  end
  always #5gif.clk=~gif.clk;
  always #50vif.pclk=~vif.pclk;
  
  vending_machine dut(gif.clk,gif.rstn,gif.cfg_mode,vif.pclk,vif.prstn,vif.paddr,vif.psel,vif.pwrite,vif.pwdata,vif.prdata,vif.pready,cif.currency_select_valid,cif.currency_value,sif.item_select_valid,sif.item_select,dif.item_dispense_valid,dif.item_dispense,dif.currency_change);
  
  initial begin
    uvm_config_db#(virtual general_if)::set(null,"*","gif",gif);
    uvm_config_db#(virtual  apb_if)::set(null,"*","vif",vif);
    uvm_config_db#(virtual currency_if#(100))::set(null,"*","cif",cif);
    uvm_config_db#(virtual  item_sel_if #(32))::set(null,"*","sif",sif);
     uvm_config_db#(virtual  item_disp_if #(32))::set(null,"*","dif",dif);
    run_test("vending_test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
  end
  
endmodule
