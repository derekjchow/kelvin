//
// description: 
// 1. It will read instructions from Command Queue and decode the instructions to uops and write to Uop Queue.
//
// feature list:
// 1. One instruction can be decoded to 8 uops at most.
// 2. Decoder will push 4 uops at most into Uops Queue, so decoder only decode to 4 uops at most per cycle.
// 3. uops_de2dp.rs1_data could be from X[rs1] and imm(inst[19:15]).
// 4. If the instruction is in wrong encoding, it will be discarded directly without applying a trap, but take assertion in simulation.
// 5. The vstart of the instruction will be calculated to a new value for every decoded uops.
// 6. vmv<nr>r.v instruction will be split to <nr> vmv.v.v uops, which means funct6, funct3, vs1, vs2 fields will be modified in new uop. However, new uops' vtype.vlmul is not changed to recovery execution right when trap handling is done.

`include "rvv_backend.svh"
`include "rvv_backend_sva.svh"

module rvv_backend_decode
(
  clk,
  rst_n,
  inst_pkg0_cq2de, 
  inst_pkg1_cq2de,
  fifo_empty_cq2de,
  fifo_1left_to_empty_cq2de,
  pop0_de2cq,
  pop1_de2cq,
  push0_de2uq,
  data0_de2uq,
  push1_de2uq,
  data1_de2uq,
  push2_de2uq,
  data2_de2uq,
  push3_de2uq,
  data3_de2uq,
  fifo_full_uq2de, 
  fifo_1left_to_full_uq2de,
  fifo_2left_to_full_uq2de,
  fifo_3left_to_full_uq2de
);
//
// interface signals
//
  // global signal
  input   logic                   clk;
  input   logic                   rst_n;
  
  // signals from command queue
  input   RVVCmd                  inst_pkg0_cq2de; 
  input   RVVCmd                  inst_pkg1_cq2de;
  input   logic                   fifo_empty_cq2de;
  input   logic                   fifo_1left_to_empty_cq2de;
  output  logic                   pop0_de2cq;
  output  logic                   pop1_de2cq;

  // signals from Uops Quue
  output logic                    push0_de2uq;
  output UOP_QUEUE_t              data0_de2uq;
  output logic                    push1_de2uq;
  output UOP_QUEUE_t              data1_de2uq;
  output logic                    push2_de2uq;
  output UOP_QUEUE_t              data2_de2uq;
  output logic                    push3_de2uq;
  output UOP_QUEUE_t              data3_de2uq;
  input logic                     fifo_full_uq2de; 
  input logic                     fifo_1left_to_full_uq2de;
  input logic                     fifo_2left_to_full_uq2de; 
  input logic                     fifo_3left_to_full_uq2de;

//
// internal signals
//
  // instruction struct valid signal 
  logic                             pkg0_valid;
  logic                             pkg1_valid;
  
  // the uops decoded in unit0
  logic         [`NUM_DE_UOP-1:0]   unit0_uop_valid_de2uq;
  UOP_QUEUE_t   [`NUM_DE_UOP-1:0]   unit0_uop_de2uq;
  
  // the uops decoded in unit1
  logic         [`NUM_DE_UOP-1:0]   unit1_uop_valid_de2uq;
  UOP_QUEUE_t   [`NUM_DE_UOP-1:0]   unit1_uop_de2uq;
 
  // uop index from controller
  logic [`UOP_INDEX_WIDTH-1:0]      uop_index_remain;

//
// decode
//
  // get data valid signals
  assign pkg0_valid = !fifo_empty_cq2de;
  assign pkg1_valid = !(fifo_empty_cq2de | fifo_1left_to_empty_cq2de);
  
  // decode unit
  rvv_backend_decode_unit u_decode_unit0
  (
    inst_valid_cq2de        (pkg0_valid),
    inst_cq2de              (inst_pkg0_cq2de),
    uop_index_remain        (uop_index_remain),
    uop_valid_de2uq         (unit0_uop_valid_de2uq),
    uop_de2uq               (unit0_uop_de2uq)
  );
   
  rvv_backend_decode_unit u_decode_unit1
  (
    inst_valid_cq2de        (pkg1_valid),
    inst_cq2de              (inst_pkg1_cq2de),
    uop_index_remain        ('b0),
    uop_valid_de2uq         (unit1_uop_valid_de2uq),
    uop_de2uq               (unit1_uop_de2uq)
  ); 
  
  // decode controller
  rvv_backend_decode_ctrl u_decode_ctrl
  (
    clk                     (clk),
    rst_n                   (rst_n),
    pkg0_valid              (pkg0_valid),
    unit0_uop_valid_de2uq   (unit0_uop_valid_de2uq),
    unit0_uop_de2uq         (unit0_uop_de2uq),
    pkg1_valid              (pkg1_valid),
    unit1_uop_valid_de2uq   (unit1_uop_valid_de2uq),
    unit1_uop_de2uq         (unit1_uop_de2uq),
    uop_index_remain        (uop_index_remain),
    pop0                    (pop0_de2cq),
    pop1                    (pop1_de2cq),
    push0                   (push0_de2uq),
    data0                   (data0_de2uq),
    push1                   (push1_de2uq),
    data1                   (data1_de2uq),
    push2                   (push2_de2uq),
    data2                   (data2_de2uq),
    push3                   (push3_de2uq),
    data3                   (data3_de2uq),
    fifo_full               (fifo_full_de2uq), 
    fifo_1left_to_full      (fifo_1left_to_full_de2uq),
    fifo_2left_to_full      (fifo_2left_to_full_de2uq), 
    fifo_3left_to_full      (fifo_3left_to_full_de2uq)
  );

endmodule
