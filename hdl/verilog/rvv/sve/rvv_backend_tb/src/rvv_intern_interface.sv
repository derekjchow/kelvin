`ifndef RVV_INTERN_INTERFACE__SV
`define RVV_INTERN_INTERFACE__SV
interface rvv_intern_interface (input bit clk, input bit rst_n);
// This interface will connect to RVV internal signals to collect coverage.

// CMD queue push
  logic    [`ISSUE_LANE-1:0]  cmdq_push;

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

  /* ROB */
  logic rob_empty;

  /* vrf */
  logic [31:0] [`VLEN-1:0] vrf_wr_wenb_full;

// Dispatch status signals
  logic [`NUM_DP_UOP-1:0] uop_valid_uop2dp; // Uops wait to be dispatched
  logic [`NUM_DP_UOP-1:0] uop_valid_dp2rob; // Uops dispatched successfully
  logic [`NUM_DP_UOP-1:0] uop_ready_rob2dp; // ROB reserve space
  ARCH_HAZARD_t           arch_hazard;      

// Trap
  // trap signal handshake
  logic                           trap_valid_rvs2rvv;
  logic                           trap_ready_rvv2rvs;  

  // the vcsr of last retired uop in last cycle
  logic                           vcsr_valid;
  logic                           vcsr_ready;

  function bit rvv_is_idle();
    rvv_is_idle = cmd_q_empty && !(|cmdq_push) &&
                  uop_q_empty &&
                  alu_rs_empty &&
                  mul_rs_empty &&
                  div_rs_empty &&
                  pmtrdt_rs_empty &&
                  lsu_rs_empty &&
                  rob_empty &&
                  (|vrf_wr_wenb_full === 1'b0) &&
                  !trap_valid_rvs2rvv && !trap_ready_rvv2rvs &&
                  !vcsr_valid && !vcsr_ready;
  endfunction: rvv_is_idle
endinterface: rvv_intern_interface
`endif // RVV_INTERN_INTERFACE__SV
