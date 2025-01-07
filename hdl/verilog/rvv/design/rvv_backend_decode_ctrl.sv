//
// description:
// 1. control to pop data from Command Queue and push data into Uop Queue. 
//
// features:
// 1. decode_ctrl will push data to Uops Queue only when Uops Queue has 4 free spaces at least.


`include "rvv_backend.svh"

module rvv_backend_decode_ctrl
(
  clk,
  rst_n,
  pkg0_valid,
  unit0_uop_valid_de2uq,
  unit0_uop_de2uq,
  pkg1_valid,
  unit1_uop_valid_de2uq,
  unit1_uop_de2uq,
  uop_index_remain,
  pop0,
  pop1,
  push0,
  data0,
  push1,
  data1,
  push2,
  data2,
  push3,
  data3,
  fifo_full, 
  fifo_1left_to_full,
  fifo_2left_to_full, 
  fifo_3left_to_full
);
//
// interface signals
//
  // global signals
  input   logic                             clk;
  input   logic                             rst_n;

  // uops from decode_unit0
  input   logic                             pkg0_valid;
  input   logic         [`NUM_DE_UOP-1:0]   unit0_uop_valid_de2uq;
  input   UOP_QUEUE_t   [`NUM_DE_UOP-1:0]   unit0_uop_de2uq;
  
  // uops from decode_unit1
  input   logic                             pkg1_valid;
  input   logic         [`NUM_DE_UOP-1:0]   unit1_uop_valid_de2uq;
  input   UOP_QUEUE_t   [`NUM_DE_UOP-1:0]   unit1_uop_de2uq;
  
  // uop_index for decode_unit
  output  logic [`UOP_INDEX_WIDTH-1:0]      uop_index_remain;
  
  // pop signals for command queue
  output  logic                             pop0;
  output  logic                             pop1;

  // signals from Uops Quue
  output logic                              push0;
  output UOP_QUEUE_t                        data0;
  output logic                              push1;
  output UOP_QUEUE_t                        data1;
  output logic                              push2;
  output UOP_QUEUE_t                        data2;
  output logic                              push3;
  output UOP_QUEUE_t                        data3;
  input logic                               fifo_full; 
  input logic                               fifo_1left_to_full;
  input logic                               fifo_2left_to_full; 
  input logic                               fifo_3left_to_full;

//
// internal signals
//
  // get last uop signal 
  logic                                     unit0_last;
  logic                                     unit1_0o01uop;
  logic                                     unit1_0to2uop;
  logic                                     unit1_0to3uop;
  logic                                     unit1_0touop;
  logic                                     unit1_last;

  // the quantity of valid 1 in unit0_uop_valid[`NUM_DE_UOP-1:0] 
  logic [`NUM_DE_UOP_WIDTH-1:0]             quantity;
  
  // fifo is ready when it has 4 free spaces at least
  logic                                     fifo_ready;
  
  // signals in uop_index DFF 
  logic                                     uop_index_clear;   
  logic                                     uop_index_enable_unit0;
  logic                                     uop_index_enable_unit1;
  logic                                     uop_index_enable;
  logic [`UOP_INDEX_WIDTH-1:0]              uop_index_din;
  
  // used in getting push0-3
  logic                                     push_valid0;
  logic                                     push_valid1;
  logic                                     push_valid2;
  logic                                     push_valid3;

//
// ctroller
//
  // get the quantity of valid 1 in unit0_uop_valid
  always_comb begin
    // initial
    quantity      = 'b0;
    
    case(unit0_uop_valid_de2uq[`NUM_DE_UOP-1:0])
      4'b0001:
        quantity  = `NUM_DE_UOP_WIDTH'd1; 
      4'b0011:
        quantity  = `NUM_DE_UOP_WIDTH'd2; 
      4'b0111:
        quantity  = `NUM_DE_UOP_WIDTH'd3; 
      4'b1111:
        quantity  = `NUM_DE_UOP_WIDTH'd4; 
    endcase
  end
  
  // get unit0 last uop signal
  mux8_1 mux_unit0_last
  #(
    .WIDTH    (1) 
  )
  (
     sel      (quantity),
     indata0  (1'b1),
     indata1  (1'b1),
     indata2  (1'b1),
     indata3  (1'b1),
     indata4  (unit0_uop_de2uq[3].last_uop_valid),
     indata5  (1'b0),
     indata6  (1'b0),
     indata7  (1'b0),
     outdata  (unit0_last) 
  );
  
  // get unit1 last uop signal
  assign unit1_0to1uop  = (unit1_uop_valid_de2uq[`NUM_DE_UOP-1:0]=='b0) || unit1_uop_de2uq[0].last_uop_valid;
  assign unit1_0to2uop  = unit1_0to1uop | unit1_uop_de2uq[1].last_uop_valid;
  assign unit1_0to3uop  = unit1_0to2uop | unit1_uop_de2uq[2].last_uop_valid;
  assign unit1_0to4uop  = unit1_0to3uop | unit1_uop_de2uq[3].last_uop_valid;

  mux8_1 mux_unit1_last
  #(
    .WIDTH    (1) 
  )
  (
     sel      (quantity),
     indata0  (unit1_0to4uop),
     indata1  (unit1_0to3uop),
     indata2  (unit1_0to2uop),
     indata3  (unit1_0to1uop),
     indata4  (1'b0),
     indata5  (1'b0),
     indata6  (1'b0),
     indata7  (1'b0),
     outdata  (unit1_last) 
  );
  
  // get fifo_ready
  assign fifo_ready = !(fifo_full|fifo_1left_to_full|fifo_2left_to_full|fifo_3left_to_full);
  
  // get pop signal to Command Queue
  assign pop0 = pkg0_valid & unit0_last & fifo_ready;
  assign pop1 = pkg1_valid & unit1_last & pop0;
  
  // instantiate cdffr for uop_index
  // clear signal
  assign uop_index_clear        = (pop0&(!pkg1_valid)) | pop1;

  // enable signal
  assign uop_index_enable_unit0 = (!pop0)&pkg0_valid;       
  assign uop_index_enable_unit1 = pop0&(!unit1_last)&pkg1_valid;  
  assign uop_index_enable       = uop_index_enable_unit0 | uop_index_enable_unit1;  
  
  // datain signal
  always_comb begin
    // initial
    uop_index_din               = uop_index_remain;    
    
    case(1'b1)
      uop_index_enable_unit0: 
        uop_index_din           = uop_index_remain + `NUM_DE_UOP_WIDTH'd4;    
      uop_index_enable_unit1:
        uop_index_din           = `NUM_DE_UOP_WIDTH'd4 - quantity; 
    end
  end

  cdffr uop_index_cdffr
  ( 
    clk       (clk), 
    rst_n     (rst_n), 
    c         (uop_index_clear), 
    e         (uop_index_enable), 
    d         (uop_index_din),
    q         (uop_index_remain)
  ); 
  
  // push signal for Uops Queue
  mux8_1 mux_push_valid0 
  #(
    .WIDTH    (1) 
  )
  (
     sel      (quantity),
     indata0  (unit1_uop_valid_de2uq[0]),
     indata1  (unit0_uop_valid_de2uq[0]),
     indata2  (unit0_uop_valid_de2uq[0]),
     indata3  (unit0_uop_valid_de2uq[0]),
     indata4  (unit0_uop_valid_de2uq[0]),
     indata5  ('b0),
     indata6  ('b0),
     indata7  ('b0),
     outdata  (push_valid0) 
  );
  
  mux8_1 mux_push_valid1 
  #(
    .WIDTH    (1) 
  )
  (
     sel      (quantity),
     indata0  (unit1_uop_valid_de2uq[1]),
     indata1  (unit1_uop_valid_de2uq[0]),
     indata2  (unit0_uop_valid_de2uq[1]),
     indata3  (unit0_uop_valid_de2uq[1]),
     indata4  (unit0_uop_valid_de2uq[1]),
     indata5  ('b0),
     indata6  ('b0),
     indata7  ('b0),
     outdata  (push_valid1) 
  );

mux8_1 mux_push_valid2
  #(
    .WIDTH    (1) 
  )
  (
     sel      (quantity),
     indata0  (unit1_uop_valid_de2uq[2]),
     indata1  (unit1_uop_valid_de2uq[1]),
     indata2  (unit1_uop_valid_de2uq[0]),
     indata3  (unit0_uop_valid_de2uq[2]),
     indata4  (unit0_uop_valid_de2uq[2]),
     indata5  ('b0),
     indata6  ('b0),
     indata7  ('b0),
     outdata  (push_valid2) 
  );

mux8_1 mux_push_valid3 
  #(
    .WIDTH    (1) 
  )
  (
     sel      (quantity),
     indata0  (unit1_uop_valid_de2uq[3]),
     indata1  (unit1_uop_valid_de2uq[2]),
     indata2  (unit1_uop_valid_de2uq[1]),
     indata3  (unit1_uop_valid_de2uq[0]),
     indata4  (unit0_uop_valid_de2uq[3]),
     indata5  ('b0),
     indata6  ('b0),
     indata7  ('b0),
     outdata  (push_valid3) 
  );
  
  assign push0 = push_valid0&fifo_ready;
  assign push1 = push_valid1&fifo_ready;
  assign push2 = push_valid2&fifo_ready;
  assign push3 = push_valid3&fifo_ready;

  // data signal for Uops Queue
  mux8_1 mux_data0 
  #(
    .WIDTH    (`UQ_WIDTH) 
  )
  (
     sel      (quantity),
     indata0  (unit1_uop_de2uq[0]),
     indata1  (unit0_uop_de2uq[0]),
     indata2  (unit0_uop_de2uq[0]),
     indata3  (unit0_uop_de2uq[0]),
     indata4  (unit0_uop_de2uq[0]),
     indata5  ('b0),
     indata6  ('b0),
     indata7  ('b0),
     outdata  (data0) 
  );

  mux8_1 mux_data1 
  #(
    .WIDTH    (`UQ_WIDTH) 
  )
  (
     sel      (quantity),
     indata0  (unit1_uop_de2uq[1]),
     indata1  (unit1_uop_de2uq[0]),
     indata2  (unit0_uop_de2uq[1]),
     indata3  (unit0_uop_de2uq[1]),
     indata4  (unit0_uop_de2uq[1]),
     indata5  ('b0),
     indata6  ('b0),
     indata7  ('b0),
     outdata  (data1) 
  );

  mux8_1 mux_data2 
  #(
    .WIDTH    (`UQ_WIDTH) 
  )
  (
     sel      (quantity),
     indata0  (unit1_uop_de2uq[2]),
     indata1  (unit1_uop_de2uq[1]),
     indata2  (unit1_uop_de2uq[0]),
     indata3  (unit0_uop_de2uq[2]),
     indata4  (unit0_uop_de2uq[2]),
     indata5  ('b0),
     indata6  ('b0),
     indata7  ('b0),
     outdata  (data2) 
  );

  mux8_1 mux_data3 
  #(
    .WIDTH    (`UQ_WIDTH) 
  )
  (
     sel      (quantity),
     indata0  (unit1_uop_de2uq[3]),
     indata1  (unit1_uop_de2uq[2]),
     indata2  (unit1_uop_de2uq[1]),
     indata3  (unit1_uop_de2uq[0]),
     indata4  (unit0_uop_de2uq[3]),
     indata5  ('b0),
     indata6  ('b0),
     indata7  ('b0),
     outdata  (data3) 
  );

endmodule
