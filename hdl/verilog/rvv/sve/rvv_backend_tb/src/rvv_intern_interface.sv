`ifndef RVV_INTERN_INTERFACE__SV
`define RVV_INTERN_INTERFACE__SV
interface rvv_intern_interface (input bit clk, input bit rst_n);
// This interface will connect to RVV internal signals to collect coverage.

// ROB to Retire
  logic    [`NUM_RT_UOP-1:0]  rob2rt_write_valid;
  ROB2RT_t [`NUM_RT_UOP-1:0]  rob2rt_write_data;
  logic    [`NUM_RT_UOP-1:0]  rt2rob_write_ready;

// Decode to UOPs queue
  logic [`NUM_DE_INST-1:0][`NUM_DE_UOP-1:0] uop_valid_de2uq;

// Disptach to each rs
  /* Dispatch unit to ALU reservation station */
  logic        [`NUM_DP_UOP-1:0] rs_valid_dp2alu;
  logic        [`NUM_DP_UOP-1:0] rs_ready_alu2dp;

  /* Dispatch unit to PMT+RDT reservation station */
  logic        [`NUM_DP_UOP-1:0] rs_valid_dp2pmtrdt;
  logic        [`NUM_DP_UOP-1:0] rs_ready_pmtrdt2dp;

  /* Dispatch unit to MUL reservation station */
  logic        [`NUM_DP_UOP-1:0] rs_valid_dp2mul;
  logic        [`NUM_DP_UOP-1:0] rs_ready_mul2dp;

  /* Dispatch unit to DIV reservation station */
  logic        [`NUM_DP_UOP-1:0] rs_valid_dp2div;
  logic        [`NUM_DP_UOP-1:0] rs_ready_div2dp;

  /* Dispatch unit to LSU reservation station */
  logic        [`NUM_DP_UOP-1:0] rs_valid_dp2lsu;
  logic        [`NUM_DP_UOP-1:0] rs_ready_lsu2dp;

// FIFO empty/full signals
  /* CMD queue */
  logic cmd_q_full, cmd_q_empty;

  /* UOPs queue */
  logic uop_q_full, uop_q_empty;

  /* RS */
  logic alu_rs_full,    alu_rs_empty;
  logic mul_rs_full,    mul_rs_empty;
  logic div_rs_full,    div_rs_empty;
  logic pmtrdt_rs_full, pmtrdt_rs_empty;
  logic lsu_rs_full,    lsu_rs_empty;

endinterface: rvv_intern_interface
`endif // RVV_INTERN_INTERFACE__SV
