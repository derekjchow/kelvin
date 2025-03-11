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
  logic [`NUM_DE_UOP-1:0]       get_unit1_last_signal;

  // the quantity of valid 1 in uop_valid[0] 
  logic [`NUM_DE_UOP_WIDTH-1:0] quantity;
  
  // fifo is ready when it has `NUM_DE_UOP free spaces at least
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
  generate
    if(`NUM_DE_UOP==6) begin
      always_comb begin
        // initial
        quantity = 'b0;
        
        case(uop_valid_de2uq[0][`NUM_DE_UOP-1:0])
          6'b000001:
            quantity = 'd1; 
          6'b000011:
            quantity = 'd2; 
          6'b000111:
            quantity = 'd3; 
          6'b001111:
            quantity = 'd4; 
          6'b011111:
            quantity = 'd5; 
          6'b111111:
            quantity = 'd6; 
        endcase
      end

      // get unit0 last uop signal
      mux7_1 
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
         .indata4  (1'b1),
         .indata5  (1'b1),
         .indata6  (uop_de2uq[0][`NUM_DE_UOP-1].last_uop_valid),
         .outdata  (last_uop_unit[0]) 
      );
      
      // get unit1 last uop signal
      assign get_unit1_last_signal[5] = uop_de2uq[1][0].last_uop_valid; 
      assign get_unit1_last_signal[4] = uop_de2uq[1][1].last_uop_valid || get_unit1_last_signal[5]; 
      assign get_unit1_last_signal[3] = uop_de2uq[1][2].last_uop_valid || get_unit1_last_signal[4]; 
      assign get_unit1_last_signal[2] = uop_de2uq[1][3].last_uop_valid || get_unit1_last_signal[3]; 
      assign get_unit1_last_signal[1] = uop_de2uq[1][4].last_uop_valid || get_unit1_last_signal[2]; 
      assign get_unit1_last_signal[0] = uop_de2uq[1][5].last_uop_valid || get_unit1_last_signal[1]; 
    
      mux7_1 
      #(
        .WIDTH    (1) 
      )
      mux_unit1_last
      (
         .sel      (quantity),
         .indata0  (get_unit1_last_signal[0]),
         .indata1  (get_unit1_last_signal[1]),
         .indata2  (get_unit1_last_signal[2]),
         .indata3  (get_unit1_last_signal[3]),
         .indata4  (get_unit1_last_signal[4]),
         .indata5  (get_unit1_last_signal[5]),
         .indata6  (1'b0),
         .outdata  (last_uop_unit[1]) 
      );

    end
    else begin //if(`NUM_DE_UOP==4)
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
      mux5_1 
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
         .outdata  (last_uop_unit[0]) 
      );
      
      // get unit1 last uop signal
      assign get_unit1_last_signal[3] = uop_de2uq[1][0].last_uop_valid; 
      assign get_unit1_last_signal[2] = uop_de2uq[1][1].last_uop_valid || get_unit1_last_signal[3]; 
      assign get_unit1_last_signal[1] = uop_de2uq[1][2].last_uop_valid || get_unit1_last_signal[2]; 
      assign get_unit1_last_signal[0] = uop_de2uq[1][3].last_uop_valid || get_unit1_last_signal[1]; 
    
      mux5_1 
      #(
        .WIDTH    (1) 
      )
      mux_unit1_last
      (
         .sel      (quantity),
         .indata0  (get_unit1_last_signal[0]),
         .indata1  (get_unit1_last_signal[1]),
         .indata2  (get_unit1_last_signal[2]),
         .indata3  (get_unit1_last_signal[3]),
         .indata4  (1'b0),
         .outdata  (last_uop_unit[1]) 
      );

    end
  endgenerate
      
  // get fifo_ready
  assign fifo_ready = !(fifo_full_uq2de | (|fifo_almost_full_uq2de));
  
  // get pop signal to Command Queue
  assign pop[0] =        pkg_valid[0]&((last_uop_unit[0]&fifo_ready) || (uop_valid_de2uq[0][`NUM_DE_UOP-1:0]=='b0));
  assign pop[1] = pop[0]&pkg_valid[1]&((last_uop_unit[1]&fifo_ready) || (uop_valid_de2uq[1][`NUM_DE_UOP-1:0]=='b0));
  
  // instantiate cdffr for uop_index
  // clear signal
  assign uop_index_clear = (pop[0]&(!pkg_valid[1])) | pop[1];
  
  // enable signal
  assign uop_index_enable_unit0 = pkg_valid[0]&(uop_valid_de2uq[0][`NUM_DE_UOP-1:0]!='b0)&(last_uop_unit[0]=='b0)&fifo_ready;       
  assign uop_index_enable_unit1 = pkg_valid[1]&(uop_valid_de2uq[1][`NUM_DE_UOP-1:0]!='b0)&(last_uop_unit[1]=='b0)&fifo_ready&pop[0];  
  assign uop_index_enable       = uop_index_enable_unit0 | uop_index_enable_unit1;  
  
  // uop index remain
  cdffr 
  #(
    .T         (logic[`UOP_INDEX_WIDTH-1:0])
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

  generate
    if(`NUM_DE_UOP==6) begin
      // datain signal
      always_comb begin
        // initial
        uop_index_din = uop_index_remain;    
        
        case(1'b1)
          uop_index_enable_unit0: 
            uop_index_din = uop_de2uq[0][`NUM_DE_UOP-1].uop_index + 1'b1;    
          uop_index_enable_unit1: begin
            case(quantity)
              3'd0:
                uop_index_din = uop_de2uq[1][5].uop_index + 1'b1; 
              3'd1:
                uop_index_din = uop_de2uq[1][4].uop_index + 1'b1; 
              3'd2:
                uop_index_din = uop_de2uq[1][3].uop_index + 1'b1; 
              3'd3:
                uop_index_din = uop_de2uq[1][2].uop_index + 1'b1; 
              3'd4:
                uop_index_din = uop_de2uq[1][1].uop_index + 1'b1; 
              3'd5:
                uop_index_din = uop_de2uq[1][0].uop_index + 1'b1; 
              3'd6:
                uop_index_din = 'b0; 
            endcase
          end
        endcase
      end
    
      // push signal for Uops Queue
      mux7_1 
      #(
        .WIDTH    (1) 
      )
      mux_push_valid0 
      (
         .sel      (quantity),
         .indata0  (uop_valid_de2uq[1][0]),
         .indata1  (uop_valid_de2uq[0][0]),
         .indata2  (uop_valid_de2uq[0][0]),
         .indata3  (uop_valid_de2uq[0][0]),
         .indata4  (uop_valid_de2uq[0][0]),
         .indata5  (uop_valid_de2uq[0][0]),
         .indata6  (uop_valid_de2uq[0][0]),
         .outdata  (push_valid[0]) 
      );
      
      mux7_1 
      #(
        .WIDTH    (1) 
      )
      mux_push_valid1 
      (
         .sel      (quantity),
         .indata0  (uop_valid_de2uq[1][1]),
         .indata1  (uop_valid_de2uq[1][0]),
         .indata2  (uop_valid_de2uq[0][1]),
         .indata3  (uop_valid_de2uq[0][1]),
         .indata4  (uop_valid_de2uq[0][1]),
         .indata5  (uop_valid_de2uq[0][1]),
         .indata6  (uop_valid_de2uq[0][1]),
         .outdata  (push_valid[1]) 
      );
    
      mux7_1 
      #(
        .WIDTH    (1) 
      )
      mux_push_valid2
      (
         .sel      (quantity),
         .indata0  (uop_valid_de2uq[1][2]),
         .indata1  (uop_valid_de2uq[1][1]),
         .indata2  (uop_valid_de2uq[1][0]),
         .indata3  (uop_valid_de2uq[0][2]),
         .indata4  (uop_valid_de2uq[0][2]),
         .indata5  (uop_valid_de2uq[0][2]),
         .indata6  (uop_valid_de2uq[0][2]),
         .outdata  (push_valid[2]) 
      );
    
      mux7_1 
      #(
        .WIDTH    (1) 
      )
      mux_push_valid3 
      (
         .sel      (quantity),
         .indata0  (uop_valid_de2uq[1][3]),
         .indata1  (uop_valid_de2uq[1][2]),
         .indata2  (uop_valid_de2uq[1][1]),
         .indata3  (uop_valid_de2uq[1][0]),
         .indata4  (uop_valid_de2uq[0][3]),
         .indata5  (uop_valid_de2uq[0][3]),
         .indata6  (uop_valid_de2uq[0][3]),
         .outdata  (push_valid[3]) 
      );

      mux7_1 
      #(
        .WIDTH    (1) 
      )
      mux_push_valid4 
      (
         .sel      (quantity),
         .indata0  (uop_valid_de2uq[1][4]),
         .indata1  (uop_valid_de2uq[1][3]),
         .indata2  (uop_valid_de2uq[1][2]),
         .indata3  (uop_valid_de2uq[1][1]),
         .indata4  (uop_valid_de2uq[1][0]),
         .indata5  (uop_valid_de2uq[0][4]),
         .indata6  (uop_valid_de2uq[0][4]),
         .outdata  (push_valid[4]) 
      );

      mux7_1 
      #(
        .WIDTH    (1) 
      )
      mux_push_valid5
      (
         .sel      (quantity),
         .indata0  (uop_valid_de2uq[1][5]),
         .indata1  (uop_valid_de2uq[1][4]),
         .indata2  (uop_valid_de2uq[1][3]),
         .indata3  (uop_valid_de2uq[1][2]),
         .indata4  (uop_valid_de2uq[1][1]),
         .indata5  (uop_valid_de2uq[1][0]),
         .indata6  (uop_valid_de2uq[0][5]),
         .outdata  (push_valid[5]) 
      );
    
      // data signal for Uops Queue
      mux7_1 
      #(
        .WIDTH    (`UQ_WIDTH) 
      )
      mux_data0
      (
         .sel      (quantity),
         .indata0  (uop_de2uq[1][0]),
         .indata1  (uop_de2uq[0][0]),
         .indata2  (uop_de2uq[0][0]),
         .indata3  (uop_de2uq[0][0]),
         .indata4  (uop_de2uq[0][0]),
         .indata5  (uop_de2uq[0][0]),
         .indata6  (uop_de2uq[0][0]),
         .outdata  (dataout[0]) 
      );
    
      mux7_1 
      #(
        .WIDTH    (`UQ_WIDTH) 
      )
      mux_data1
      (
         .sel      (quantity),
         .indata0  (uop_de2uq[1][1]),
         .indata1  (uop_de2uq[1][0]),
         .indata2  (uop_de2uq[0][1]),
         .indata3  (uop_de2uq[0][1]),
         .indata4  (uop_de2uq[0][1]),
         .indata5  (uop_de2uq[0][1]),
         .indata6  (uop_de2uq[0][1]),
         .outdata  (dataout[1]) 
      );
    
      mux7_1  
      #(
        .WIDTH    (`UQ_WIDTH) 
      )
      mux_data2
      (
         .sel      (quantity),
         .indata0  (uop_de2uq[1][2]),
         .indata1  (uop_de2uq[1][1]),
         .indata2  (uop_de2uq[1][0]),
         .indata3  (uop_de2uq[0][2]),
         .indata4  (uop_de2uq[0][2]),
         .indata5  (uop_de2uq[0][2]),
         .indata6  (uop_de2uq[0][2]),
         .outdata  (dataout[2]) 
      );
    
      mux7_1  
      #(
        .WIDTH    (`UQ_WIDTH) 
      )
      mux_data3
      (
         .sel      (quantity),
         .indata0  (uop_de2uq[1][3]),
         .indata1  (uop_de2uq[1][2]),
         .indata2  (uop_de2uq[1][1]),
         .indata3  (uop_de2uq[1][0]),
         .indata4  (uop_de2uq[0][3]),
         .indata5  (uop_de2uq[0][3]),
         .indata6  (uop_de2uq[0][3]),
         .outdata  (dataout[3]) 
      );

      mux7_1  
      #(
        .WIDTH    (`UQ_WIDTH) 
      )
      mux_data4
      (
         .sel      (quantity),
         .indata0  (uop_de2uq[1][4]),
         .indata1  (uop_de2uq[1][3]),
         .indata2  (uop_de2uq[1][2]),
         .indata3  (uop_de2uq[1][1]),
         .indata4  (uop_de2uq[1][0]),
         .indata5  (uop_de2uq[0][4]),
         .indata6  (uop_de2uq[0][4]),
         .outdata  (dataout[4]) 
      );

      mux7_1  
      #(
        .WIDTH    (`UQ_WIDTH) 
      )
      mux_data5
      (
         .sel      (quantity),
         .indata0  (uop_de2uq[1][5]),
         .indata1  (uop_de2uq[1][4]),
         .indata2  (uop_de2uq[1][3]),
         .indata3  (uop_de2uq[1][2]),
         .indata4  (uop_de2uq[1][1]),
         .indata5  (uop_de2uq[1][0]),
         .indata6  (uop_de2uq[0][5]),
         .outdata  (dataout[5]) 
      );

    end //`NUM_DE_UOP==6
    else begin //if(`NUM_DE_UOP==4)
      // datain signal
      always_comb begin
        // initial
        uop_index_din     = uop_index_remain;    
        
        case(1'b1)
          uop_index_enable_unit0: 
            uop_index_din = uop_de2uq[0][`NUM_DE_UOP-1].uop_index + 1'b1;    
          uop_index_enable_unit1: begin
            case(quantity)
              3'd0:
                uop_index_din = uop_de2uq[1][3].uop_index + 1'b1; 
              3'd1:
                uop_index_din = uop_de2uq[1][2].uop_index + 1'b1; 
              3'd2:
                uop_index_din = uop_de2uq[1][1].uop_index + 1'b1; 
              3'd3:
                uop_index_din = uop_de2uq[1][0].uop_index + 1'b1; 
              3'd4:
                uop_index_din = 'b0; 
            endcase
          end
        endcase
      end
      
      // push signal for Uops Queue
      mux5_1 
      #(
        .WIDTH    (1) 
      )
      mux_push_valid0 
      (
         .sel      (quantity),
         .indata0  (uop_valid_de2uq[1][0]),
         .indata1  (uop_valid_de2uq[0][0]),
         .indata2  (uop_valid_de2uq[0][0]),
         .indata3  (uop_valid_de2uq[0][0]),
         .indata4  (uop_valid_de2uq[0][0]),
         .outdata  (push_valid[0]) 
      );
      
      mux5_1 
      #(
        .WIDTH    (1) 
      )
      mux_push_valid1 
      (
         .sel      (quantity),
         .indata0  (uop_valid_de2uq[1][1]),
         .indata1  (uop_valid_de2uq[1][0]),
         .indata2  (uop_valid_de2uq[0][1]),
         .indata3  (uop_valid_de2uq[0][1]),
         .indata4  (uop_valid_de2uq[0][1]),
         .outdata  (push_valid[1]) 
      );
    
    mux5_1 
      #(
        .WIDTH    (1) 
      )
      mux_push_valid2
      (
         .sel      (quantity),
         .indata0  (uop_valid_de2uq[1][2]),
         .indata1  (uop_valid_de2uq[1][1]),
         .indata2  (uop_valid_de2uq[1][0]),
         .indata3  (uop_valid_de2uq[0][2]),
         .indata4  (uop_valid_de2uq[0][2]),
         .outdata  (push_valid[2]) 
      );
    
    mux5_1 
      #(
        .WIDTH    (1) 
      )
      mux_push_valid3 
      (
         .sel      (quantity),
         .indata0  (uop_valid_de2uq[1][3]),
         .indata1  (uop_valid_de2uq[1][2]),
         .indata2  (uop_valid_de2uq[1][1]),
         .indata3  (uop_valid_de2uq[1][0]),
         .indata4  (uop_valid_de2uq[0][3]),
         .outdata  (push_valid[3]) 
      );
    
      // data signal for Uops Queue
      mux5_1 
      #(
        .WIDTH    (`UQ_WIDTH) 
      )
      mux_data0
      (
         .sel      (quantity),
         .indata0  (uop_de2uq[1][0]),
         .indata1  (uop_de2uq[0][0]),
         .indata2  (uop_de2uq[0][0]),
         .indata3  (uop_de2uq[0][0]),
         .indata4  (uop_de2uq[0][0]),
         .outdata  (dataout[0]) 
      );
    
      mux5_1 
      #(
        .WIDTH    (`UQ_WIDTH) 
      )
      mux_data1
      (
         .sel      (quantity),
         .indata0  (uop_de2uq[1][1]),
         .indata1  (uop_de2uq[1][0]),
         .indata2  (uop_de2uq[0][1]),
         .indata3  (uop_de2uq[0][1]),
         .indata4  (uop_de2uq[0][1]),
         .outdata  (dataout[1]) 
      );
    
      mux5_1  
      #(
        .WIDTH    (`UQ_WIDTH) 
      )
      mux_data2
      (
         .sel      (quantity),
         .indata0  (uop_de2uq[1][2]),
         .indata1  (uop_de2uq[1][1]),
         .indata2  (uop_de2uq[1][0]),
         .indata3  (uop_de2uq[0][2]),
         .indata4  (uop_de2uq[0][2]),
         .outdata  (dataout[2]) 
      );
    
      mux5_1  
      #(
        .WIDTH    (`UQ_WIDTH) 
      )
      mux_data3
      (
         .sel      (quantity),
         .indata0  (uop_de2uq[1][3]),
         .indata1  (uop_de2uq[1][2]),
         .indata2  (uop_de2uq[1][1]),
         .indata3  (uop_de2uq[1][0]),
         .indata4  (uop_de2uq[0][3]),
         .outdata  (dataout[3]) 
      );

    end //`NUM_DE_UOP==4
  endgenerate

  generate 
    for (i=0;i<`NUM_DE_UOP;i++) begin: GET_PUSH
      assign push[i] = push_valid[i]&fifo_ready;
    end
  endgenerate

endmodule
