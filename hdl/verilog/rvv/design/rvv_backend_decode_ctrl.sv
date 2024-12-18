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
  pkg_valid,
  uop_valid_de2uq,
  uop_de2uq,
  uop_index_remain,
  pop,
  push,
  dataout,
  fifo_full_uq2de, 
  fifo_almost_full_uq2de
);
//
// interface signals
//
  // global signals
  input   logic       clk;
  input   logic       rst_n;

  // decoded uops
  input   logic       [`NUM_DE_INST-1:0]                  pkg_valid;
  input   logic       [`NUM_DE_INST-1:0][`NUM_DE_UOP-1:0] uop_valid_de2uq;
  input   UOP_QUEUE_t [`NUM_DE_INST-1:0][`NUM_DE_UOP-1:0] uop_de2uq;
  
  // uop_index for decode_unit
  output  logic       [`UOP_INDEX_WIDTH-1:0]  uop_index_remain;
  
  // pop signals for command queue
  output  logic       [`NUM_DE_INST-1:0]      pop;

  // signals from Uops Quue
  output  logic       [`NUM_DE_UOP-1:0]       push;
  output  UOP_QUEUE_t [`NUM_DE_UOP-1:0]       dataout;
  input   logic                               fifo_full_uq2de;
  input   logic       [`NUM_DE_UOP-1:1]       fifo_almost_full_uq2de;

//
// internal signals
//
  // get last uop signal 
  logic [`NUM_DE_INST-1:0]      last_uop_unit;
  logic [`NUM_DE_UOP-1:1]       get_unit1_last_signal;

  // the quantity of valid 1 in uop_valid[0] 
  logic [`NUM_DE_UOP_WIDTH-1:0] quantity;
  
  // fifo is ready when it has 4 free spaces at least
  logic                         fifo_ready;
  
  // signals in uop_index DFF 
  logic                         uop_index_clear;   
  logic                         uop_index_enable_unit0;
  logic                         uop_index_enable_unit1;
  logic                         uop_index_enable;
  logic [`UOP_INDEX_WIDTH-1:0]  uop_index_din;
  
  // used in getting push0-3
  logic [`NUM_DE_UOP-1:0]       push_valid;
  
  // for-loop
  genvar                        i;

//
// ctroller
//
  // get the quantity of valid 1 in uop_valid[0]
  always_comb begin
    // initial
    quantity = 'b0;
    
    case(uop_valid_de2uq[0][`NUM_DE_UOP-1:0])
      4'b0001:
        quantity = 'd1; 
      4'b0011:
        quantity = 'd2; 
      4'b0111:
        quantity = 'd3; 
      4'b1111:
        quantity = 'd4; 
    endcase
  end

  // get unit0 last uop signal
  mux8_1 
  #(
    .WIDTH    (1) 
  )
  mux_unit0_last
  (
     .sel      (quantity),
     .indata0  (1'b0),
     .indata1  (1'b1),
     .indata2  (1'b1),
     .indata3  (1'b1),
     .indata4  (uop_de2uq[0][`NUM_DE_UOP-1].last_uop_valid),
     .indata5  (1'b0),
     .indata6  (1'b0),
     .indata7  (1'b0),
     .outdata  (last_uop_unit[0]) 
  );
  
  // get unit1 last uop signal
  assign get_unit1_last_signal[3] = uop_de2uq[1][0].last_uop_valid;
  assign get_unit1_last_signal[2] = get_unit1_last_signal[3] || uop_de2uq[1][1].last_uop_valid;
  assign get_unit1_last_signal[1] = get_unit1_last_signal[2] || uop_de2uq[1][2].last_uop_valid;

  mux8_1 
  #(
    .WIDTH    (1) 
  )
  mux_unit1_last
  (
     .sel      (quantity),
     .indata0  (1'b0),
     .indata1  (get_unit1_last_signal[1]),
     .indata2  (get_unit1_last_signal[2]),
     .indata3  (get_unit1_last_signal[3]),
     .indata4  (1'b0),
     .indata5  (1'b0),
     .indata6  (1'b0),
     .indata7  (1'b0),
     .outdata  (last_uop_unit[1]) 
  );
  
  // get fifo_ready
  assign fifo_ready = !(fifo_full_uq2de | (|fifo_almost_full_uq2de));
  
  // get pop signal to Command Queue
  assign pop[0] = pkg_valid[0] & last_uop_unit[0] & fifo_ready;
  assign pop[1] = pkg_valid[1] & last_uop_unit[1] & pop[0];
  
  // instantiate cdffr for uop_index
  // clear signal
  assign uop_index_clear        = (pop[0]&(!pkg_valid[1])) | pop[1];

  // enable signal
  assign uop_index_enable_unit0 = (!pop[0])&pkg_valid[0];       
  assign uop_index_enable_unit1 = pop[0]&(!last_uop_unit[1])&pkg_valid[1];  
  assign uop_index_enable       = uop_index_enable_unit0 | uop_index_enable_unit1;  
  
  // datain signal
  always_comb begin
    // initial
    uop_index_din     = uop_index_remain;    
    
    case(1'b1)
      uop_index_enable_unit0: 
        uop_index_din = uop_index_remain + 'd4;    
      uop_index_enable_unit1:
        uop_index_din = 'd4 - quantity; 
    endcase
  end

  cdffr 
  #(
    .WIDTH     (`UOP_INDEX_WIDTH)
  )
  uop_index_cdffr
  ( 
    .clk       (clk), 
    .rst_n     (rst_n), 
    .c         (uop_index_clear), 
    .e         (uop_index_enable), 
    .d         (uop_index_din),
    .q         (uop_index_remain)
  ); 
  
  // push signal for Uops Queue
  mux8_1 
  #(
    .WIDTH    (1) 
  )
  mux_push_valid0 
  (
     .sel      (quantity),
     .indata0  ('d0),
     .indata1  (uop_valid_de2uq[0][0]),
     .indata2  (uop_valid_de2uq[0][0]),
     .indata3  (uop_valid_de2uq[0][0]),
     .indata4  (uop_valid_de2uq[0][0]),
     .indata5  (1'b0),
     .indata6  (1'b0),
     .indata7  (1'b0),
     .outdata  (push_valid[0]) 
  );
  
  mux8_1 
  #(
    .WIDTH    (1) 
  )
  mux_push_valid1 
  (
     .sel      (quantity),
     .indata0  ('d0),
     .indata1  (uop_valid_de2uq[1][0]),
     .indata2  (uop_valid_de2uq[0][1]),
     .indata3  (uop_valid_de2uq[0][1]),
     .indata4  (uop_valid_de2uq[0][1]),
     .indata5  (1'b0),
     .indata6  (1'b0),
     .indata7  (1'b0),
     .outdata  (push_valid[1]) 
  );

mux8_1 
  #(
    .WIDTH    (1) 
  )
  mux_push_valid2
  (
     .sel      (quantity),
     .indata0  ('d0),
     .indata1  (uop_valid_de2uq[1][1]),
     .indata2  (uop_valid_de2uq[1][0]),
     .indata3  (uop_valid_de2uq[0][2]),
     .indata4  (uop_valid_de2uq[0][2]),
     .indata5  (1'b0),
     .indata6  (1'b0),
     .indata7  (1'b0),
     .outdata  (push_valid[2]) 
  );

mux8_1 
  #(
    .WIDTH    (1) 
  )
  mux_push_valid3 
  (
     .sel      (quantity),
     .indata0  ('d0),
     .indata1  (uop_valid_de2uq[1][2]),
     .indata2  (uop_valid_de2uq[1][1]),
     .indata3  (uop_valid_de2uq[1][0]),
     .indata4  (uop_valid_de2uq[0][3]),
     .indata5  (1'b0),
     .indata6  (1'b0),
     .indata7  (1'b0),
     .outdata  (push_valid[3]) 
  );
 
  generate 
    for (i=0;i<`NUM_DE_UOP;i++) begin: GET_PUSH
      assign push[i] = push_valid[i]&fifo_ready;
    end
  endgenerate

  // data signal for Uops Queue
  mux8_1 
  #(
    .WIDTH    (`UQ_WIDTH) 
  )
  mux_data0
  (
     .sel      (quantity),
     .indata0  ('d0),
     .indata1  (uop_de2uq[0][0]),
     .indata2  (uop_de2uq[0][0]),
     .indata3  (uop_de2uq[0][0]),
     .indata4  (uop_de2uq[0][0]),
     .indata5  ({`UQ_WIDTH{1'b0}}),
     .indata6  ({`UQ_WIDTH{1'b0}}),
     .indata7  ({`UQ_WIDTH{1'b0}}),
     .outdata  (dataout[0]) 
  );

  mux8_1 
  #(
    .WIDTH    (`UQ_WIDTH) 
  )
  mux_data1
  (
     .sel      (quantity),
     .indata0  ('d0),
     .indata1  (uop_de2uq[1][0]),
     .indata2  (uop_de2uq[0][1]),
     .indata3  (uop_de2uq[0][1]),
     .indata4  (uop_de2uq[0][1]),
     .indata5  ({`UQ_WIDTH{1'b0}}),
     .indata6  ({`UQ_WIDTH{1'b0}}),
     .indata7  ({`UQ_WIDTH{1'b0}}),
     .outdata  (dataout[1]) 
  );

  mux8_1  
  #(
    .WIDTH    (`UQ_WIDTH) 
  )
  mux_data2
  (
     .sel      (quantity),
     .indata0  ('d0),
     .indata1  (uop_de2uq[1][1]),
     .indata2  (uop_de2uq[1][0]),
     .indata3  (uop_de2uq[0][2]),
     .indata4  (uop_de2uq[0][2]),
     .indata5  ({`UQ_WIDTH{1'b0}}),
     .indata6  ({`UQ_WIDTH{1'b0}}),
     .indata7  ({`UQ_WIDTH{1'b0}}),
     .outdata  (dataout[2]) 
  );

  mux8_1  
  #(
    .WIDTH    (`UQ_WIDTH) 
  )
  mux_data3
  (
     .sel      (quantity),
     .indata0  ('d0),
     .indata1  (uop_de2uq[1][2]),
     .indata2  (uop_de2uq[1][1]),
     .indata3  (uop_de2uq[1][0]),
     .indata4  (uop_de2uq[0][3]),
     .indata5  ({`UQ_WIDTH{1'b0}}),
     .indata6  ({`UQ_WIDTH{1'b0}}),
     .indata7  ({`UQ_WIDTH{1'b0}}),
     .outdata  (dataout[3]) 
  );

endmodule
