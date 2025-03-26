
`include "uvm_macros.svh"
import uvm_pkg::*;

// APB Transaction Class
class apb_transaction extends uvm_sequence_item;
  rand bit [15:0] paddr;   
  rand bit [31:0] pwdata;  
  rand bit pwrite;         
  bit [31:0] prdata;       
  bit psel;
  bit pready;

  `uvm_object_utils(apb_transaction)

  function new(string name = "apb_transaction");
    super.new(name);
  endfunction
endclass


// APB Sequencer
class apb_sequencer extends uvm_sequencer #(apb_transaction);
  `uvm_component_utils(apb_sequencer)

  function new(string name = "apb_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass


// APB Driver
class apb_driver extends uvm_driver #(apb_transaction);
  virtual vending_machine_if.apb_cb vif; 
  `uvm_component_utils(apb_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_transaction txn;
    forever begin
      seq_item_port.get_next_item(txn);

      vif.apb_cb.paddr <= txn.paddr;
      vif.apb_cb.pwrite <= txn.pwrite;
      vif.apb_cb.pwdata <= txn.pwdata;
      vif.apb_cb.psel <= 1;

      @(vif.apb_cb);
      while (!vif.apb_cb.pready) @(vif.apb_cb);

      if (!txn.pwrite)
        txn.prdata = vif.apb_cb.prdata;

      vif.apb_cb.psel <= 0;
      seq_item_port.item_done();
    end
  endtask
endclass


// APB Monitor
class apb_monitor extends uvm_monitor;
  virtual vending_machine_if.apb_cb vif;
  uvm_analysis_port #(apb_transaction) monitor_port;

  `uvm_component_utils(apb_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    monitor_port = new("monitor_port", this);
  endfunction

  task run_phase(uvm_phase phase);
    apb_transaction txn;
    forever begin
      txn = apb_transaction::type_id::create("txn");
      @(vif.apb_cb);
      if (vif.apb_cb.psel) begin
        txn.paddr = vif.apb_cb.paddr;
        txn.pwrite = vif.apb_cb.pwrite;
        txn.pwdata = vif.apb_cb.pwdata;
        txn.pready = vif.apb_cb.pready;
        txn.prdata = vif.apb_cb.prdata;

        monitor_port.write(txn);
      end
    end
  endtask
endclass


// APB Agent
class apb_agent extends uvm_agent;
  apb_driver drv;
  apb_monitor mon;
  apb_sequencer seqr;

  `uvm_component_utils(apb_agent)

  function new(string name = "apb_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = apb_driver::type_id::create("drv", this);
    mon = apb_monitor::type_id::create("mon", this);
    seqr = apb_sequencer::type_id::create("seqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass

