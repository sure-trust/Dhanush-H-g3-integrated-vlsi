module cfg_ctrl #(parameter MAX_ITEMS = 32) (
//APB Interface
input         pclk,
input  [15:0] paddr,
input         prstn,
input  [31:0] pwdata,
output [31:0] prdata,
input         pwrite,
input         psel,
input [$clog2(MAX_ITEMS)-1 : 0] get_me_item_cfg,
output [31:0] current_item_cfg,
input update_vld,
input [$clog2(MAX_ITEMS)-1 : 0] update_item_no

);

reg [31:0] prdata_r;
reg [31:0] current_item_cfg_r;
reg [31:0] vending_machine_cfg;
reg [31:0] item_cfg[MAX_ITEMS];

assign prdata = prdata_r;
assign current_item_cfg = current_item_cfg_r;

always @(posedge pclk or negedge prstn) begin
  if (!prstn) begin
    for (int i =0; i<MAX_ITEMS; i++) begin
      item_cfg[i] <= 32'h0;
    end
  end
  else begin
    if (psel & pwrite) begin
      if (paddr[15:12] == 0) begin
        vending_machine_cfg <= pwdata;
      end
      else begin
        item_cfg[paddr[11:0]] <= pwdata;
      end
    end
    if (psel) begin
      if (paddr[15:12] == 0) begin
        prdata_r <= vending_machine_cfg;
      end
      else begin
        prdata_r <= item_cfg[paddr[11:0]];
      end
    end
  end
end

always @(*) begin
  current_item_cfg_r = item_cfg[get_me_item_cfg];
end

always @(*) begin
  if (update_vld) begin
    item_cfg[update_item_no][23:16] -= 1; //Decrement no of available
    item_cfg[update_item_no][31:24] += 1; //Increment no of dispensed
  end
end
endmodule // cfg_ctrl

module posedge_det (input clk, input rstn, input sig, output posedge_sig);
  reg sig_r;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      sig_r <= 1'b0;
    end
    else begin
      sig_r <= sig;
    end
  end
  assign posedge_sig = !sig_r & sig;
endmodule // posedge_det


module vending_machine #(
parameter MAX_ITEMS = 32,
parameter MAX_NOTE_VAL = 100
)
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

reg [$clog2(MAX_ITEMS)-1 : 0] current_item_code;
reg [31:0] current_item_cfg;
reg o_valid_r;
reg [$clog2(MAX_ITEMS)-1 : 0] out_item_r;
reg [15:0] count_notes;
reg [15:0] note_change_r;
reg item_vld_posedge;

//assign currency_change = note_change_r;

//Capture Item no for current item
posedge_det item_posedge (clk, rstn, item_select_valid, item_vld_posedge);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      current_item_code <= 'h0;
    end
    else if (item_vld_posedge) begin
      current_item_code <= item_select;
    end
end

cfg_ctrl #(.MAX_ITEMS(MAX_ITEMS)) u_cfg_ctrl (
  .pclk    (pclk  ),
  .paddr   (paddr ),
  .prstn   (prstn ),
  .pwdata  (pwdata),
  .prdata  (prdata),
  .pwrite  (pwrite && cfg_mode),
  .psel    (psel),
  .get_me_item_cfg  (current_item_code),
  .current_item_cfg (current_item_cfg),
  .update_vld       (o_valid_r),
  .update_item_no   (out_item_r)

);

assign item_dispense_valid     = o_valid_r;
assign item_dispense           = out_item_r;
assign currency_change         = note_change_r;

// Ctrl for item_disp_logic and count_notes used for efficient change handling and checking the money is enough to buy item 
always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    o_valid_r     <= 'b0;
    out_item_r    <= 'h0;
    note_change_r <= 'h0;
    count_notes   <= 'h0; // accumalating the sum of values of currency entered by user
  end
  else begin // -> current_item_cfg[23:16] is to store no of available items
    if (currency_valid & (current_item_cfg[23:16] != 0)) begin //Ctrl logic should start
    //only when there is a valid input and current item is available
      if (count_notes + currency_value >= current_item_cfg[15:0]) begin
    //When the sofar count of money including current note is sufficient i.e
    //equal or greater than the item value then issue the item
        o_valid_r     <= 1'b1;
        out_item_r    <= current_item_code;
        note_change_r <= count_notes + currency_value - current_item_cfg[15:0];
        count_notes  <= 'h0;
      end
      else begin
      // Make sure we nullify item_dispense_valid and all outputs
        o_valid_r     <= 'b0;
        out_item_r    <= 'h0;
        note_change_r <= 'h0;
        count_notes   <= count_notes + currency_value;
      end
    end // The ctrl logic if 
    else if (!currency_valid) begin
      //Make sure oututs are nullified within a clk
      //Also pay attention not to clear the counter
      //So that we allow customer to input notes with bigger gap
        o_valid_r     <= 'b0;
        out_item_r    <= 'h0;
        note_change_r <= 'h0; // why ? count_notes <= 'h0 
    end
  end
end
endmodule
///////////////////general_interface//////////////////
interface general_if;
  logic clk,rstn,cfg_mode;



endinterface
///////////////////////////////////////////////
//////////////////////**apb interface**/////////////////////////
interface apb_if;
  logic  pclk,prstn,psel, pwrite,pready;
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
/*************************************tb************************************/



