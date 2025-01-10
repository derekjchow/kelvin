`include "rvv_backend.svh"

module rvv_backend
(
    clk,
    rst_n,

    insts_valid_rvs2cq,
    insts_rvs2cq,
    insts_ready_cq2rvs,

    uop_valid,
    uop_lsu_rvv2rvs,
    uop_ready,
    uop_done_valid,
    uop_done_rvs2rvv,
    uop_done_ready,

    wb_xrf_wb2rvs,
    wb_xrf_valid_wb2rvs,
    wb_xrf_ready_wb2rvs,

    trap_rvs2rvv,
    ready_rvv2rvs,
    vcsr_valid,
    vector_csr
);
// global signal
    input   logic                  clk;
    input   logic                  rst_n;

// vector instruction and scalar operand input. 
    input   logic   [`NUM_DP_UOP-1:0] insts_valid_rvs2cq;
    input   INST_t  [`NUM_DP_UOP-1:0] insts_rvs2cq;
    output  logic   [`NUM_DP_UOP-1:0] insts_ready_cq2rvs;

// load/store unit interface
  // RVV send LSU uop to RVS
    output  logic   [`NUM_DP_UOP-1:0] uop_valid;
    output  UOP_LSU_RVV2RVS_t [`NUM_DP_UOP-1:0] uop_lsu_rvv2rvs;
    input   logic   [`NUM_DP_UOP-1:0] uop_ready;
  // LSU feedback to RVV
    input   logic   [`NUM_DP_UOP-1:0] uop_done_valid;
    input   UOP_LSU_RVV2RVS_t [`NUM_DP_UOP-1:0] uop_done_rvs2rvv;
    output  logic   [`NUM_DP_UOP-1:0] uop_done_ready;

// write back to XRF. RVS arbitrates write ports of XRF by itself.
    output  WB_XRF_t [`NUM_WB_UOP-1:0] wb_xrf_wb2rvs;
    output  logic    [`NUM_WB_UOP-1:0] wb_xrf_valid_wb2rvs;
    input   logic    [`NUM_WB_UOP-1:0] wb_xrf_ready_wb2rvs;

// exception handler
  // trap signal handshake
    input   logic                         trap_rvs2rvv;
    output  logic                         ready_rvv2rvs;
  // the vcsr of last retired uop in last cycle
    output  logic                         vcsr_valid;
    output  VECTOR_CSR_t                  vector_csr;

// ---internal signals definition-------------------------------------
  // RVV frontend to command queue
    logic                                 cq_full;
    logic                                 cq_1left_to_full;
    logic                                 cq_2left_to_full;
    logic                                 cq_3left_to_full;
  // Command queue to Decode
    logic RVVCmd                          inst_pkg0_cq2de;
    logic RVVCmd                          inst_pkg1_cq2de;
    logic                                 fifo_empty_cq2de;
    logic                                 fifo_1left_to_empty_cq2de;
    logic                                 pop0_de2cq;
    logic                                 pop1_de2cq;
  // Decode to uop queue
    logic                                 push0_de2uq;
    UOP_QUEUE_t                           data0_de2uq;
    logic                                 push1_de2uq;
    UOP_QUEUE_t                           data1_de2uq;
    logic                                 push2_de2uq;
    UOP_QUEUE_t                           data2_de2uq;
    logic                                 push3_de2uq;
    UOP_QUEUE_t                           data3_de2uq;
    logic                                 fifo_full_uq2de;
    logic                                 fifo_1left_to_full_uq2de;
    logic                                 fifo_2left_to_full_uq2de;
    logic                                 fifo_3left_to_full_uq2de;
  // Uop queue to dispatch
    logic                                 uq_empty;
    logic                                 uq_1left_to_empty;
    logic        [`NUM_DP_UOP-1:0]        uop_valid_uop2dp;
    UOP_QUEUE_t  [`NUM_DP_UOP-1:0]        uop_uop2dp;
    logic        [`NUM_DP_UOP-1:0]        uop_ready_dp2uop;
  // Dispatch to RS
    // ALU_RS
    logic                                 alu_rs_full;
    logic                                 alu_rs_1left_to_full;
    logic        [`NUM_DP_UOP-1:0]        rs_valid_dp2alu;
    ALU_RS_t     [`NUM_DP_UOP-1:0]        rs_dp2alu;
    logic        [`NUM_DP_UOP-1:0]        rs_ready_alu2dp;
    // PMTRDT_RS
    logic                                 pmtrdt_rs_full;
    logic                                 pmtrdt_rs_1left_to_full;
    logic        [`NUM_DP_UOP-1:0]        rs_valid_dp2pmtrdt;
    PMT_RDT_RS_t [`NUM_DP_UOP-1:0]        rs_dp2pmtrdt;
    logic        [`NUM_DP_UOP-1:0]        rs_ready_pmtrdt2dp;
    // MUL_RS
    logic                                 mul_rs_full;
    logic                                 mul_rs_1left_to_full;
    logic        [`NUM_DP_UOP-1:0]        rs_valid_dp2mul;
    MUL_RS_t     [`NUM_DP_UOP-1:0]        rs_dp2mul;
    logic        [`NUM_DP_UOP-1:0]        rs_ready_mul2dp;
    // DIV_RS
    logic                                 div_rs_full;
    logic                                 div_rs_1left_to_full;
    logic        [`NUM_DP_UOP-1:0]        rs_valid_dp2div;
    DIV_RS_t     [`NUM_DP_UOP-1:0]        rs_dp2div;
    logic        [`NUM_DP_UOP-1:0]        rs_ready_div2dp;
    // LSU_RS
    logic                                 lsu_rs_full;
    logic                                 lsu_rs_1left_to_full;
    logic        [`NUM_DP_UOP-1:0]        rs_valid_dp2lsu;
    LSU_RS_t     [`NUM_DP_UOP-1:0]        rs_dp2lsu;
    logic        [`NUM_DP_UOP-1:0]        rs_ready_lsu2dp;
  // Dispatch to ROB
    logic        [`NUM_DP_UOP-1:0]        uop_valid_dp2rob;
    DP2ROB_t     [`NUM_DP_UOP-1:0]        uop_dp2rob;
    logic        [`NUM_DP_UOP-1:0]        uop_ready_rob2dp;
    logic        [`ROB_DEPTH_WIDTH-1:0]   uop_index_rob2dp;
  // ALU_RS to ALU
    logic                                 pop0_alu2rs;
    logic                                 pop1_alu2rs;
    ALU_RS_t                              uop0_rs2alu;
    ALU_RS_t                              uop1_rs2alu;
    logic                                 fifo_empty_rs2alu;
    logic                                 fifo_1left_to_empty_rs2alu;
  // ALU to ROB
    logic                                 result0_valid_alu2rob;
    ALU2ROB_t                             result0_alu2rob;
    logic                                 result0_ready_rob2alu;
    logic                                 result1_valid_alu2rob;
    ALU2ROB_t                             result1_alu2rob;
    logic                                 result1_ready_rob2alu;
  // VRF to dispatch
    logic [`NUM_DP_VRF-1:0][`REGFILE_INDEX_WIDTH-1:0] rd_index_dp2vrf;
    logic [`NUM_DP_VRF-1:0][`VLEN-1:0]                rd_data_vrf2dp;
    logic [`VLEN-1:0]                                 v0_mask_vrf2dp;
  // ROB to dispatch
    ROB2DP_t     [`ROB_DEPTH-1:0]         rob_entry;

// ---code start------------------------------------------------------
  // Command queue
    fifo_flopped_4w2r #(
        .DWIDTH     ($bits(INST_t)),
        .DEPTH      (`CQ_DEPTH),
    ) u_command_queue (
      // global
        .clk        (clk),
        .rst_n      (rst_n),
      // write
        .push0      (insts_valid_rvs2cq[0] & insts_ready_cq2rvs[0]),
        .inData0    (insts_rvs2cq[0]),
        .push1      (insts_valid_rvs2cq[1] & insts_ready_cq2rvs[1]),
        .inData1    (insts_rvs2cq[1]),
        .push2      (insts_valid_rvs2cq[2] & insts_ready_cq2rvs[2]),
        .inData2    (insts_rvs2cq[2]),
        .push3      (insts_valid_rvs2cq[3] & insts_ready_cq2rvs[3]),
        .inData3    (insts_rvs2cq[3]),
      // read
        .pop0       (pop0_de2cq),
        .outData0   (inst_pkg0_cq2de),
        .pop1       (pop1_de2cq),
        .outData1   (inst_pkg1_cq2de),
      // fifo status
        .fifo_halfFull        (),
        .fifo_full            (cq_full),
        .fifo_1left_to_full   (cq_1left_to_full),
        .fifo_2left_to_full   (cq_2left_to_full),
        .fifo_3left_to_full   (cq_3left_to_full),
        .fifo_empty           (fifo_empty_cq2de),
        .fifo_1left_to_empty  (fifo_1left_to_empty_cq2de),
        .fifo_idle            ()
    );

    assign insts_ready_cq2rvs[0] = ~cq_full;
    assign insts_ready_cq2rvs[1] = ~cq_1left_to_full;
    assign insts_ready_cq2rvs[2] = ~cq_2left_to_full;
    assign insts_ready_cq2rvs[3] = ~cq_3left_to_full;

  // Decode unit
    rvv_backend_decode #(
    ) u_decode (
      // global
        .clk        (clk),
        .rst_n      (rst_n),
      // cq2de
        .inst_pkg0_cq2de      (inst_pkg0_cq2de),
        .inst_pkg1_cq2de      (inst_pkg1_cq2de),
        .fifo_empty_cq2de     (fifo_empty_cq2de),
        .fifo_1left_to_empty_cq2de  (fifo_1left_to_empty_cq2de),
        .pop0_de2cq           (pop0_de2cq),
        .pop1_de2cq           (pop1_de2cq),
      // de2uq
        .push0_de2uq          (push0_de2uq),
        .data0_de2uq          (data0_de2uq),
        .push1_de2uq          (push1_de2uq),
        .data1_de2uq          (data1_de2uq),
        .push2_de2uq          (push2_de2uq),
        .data2_de2uq          (data2_de2uq),
        .push3_de2uq          (push3_de2uq),
        .data3_de2uq          (data3_de2uq),
        .fifo_full_uq2de      (fifo_full_uq2de),
        .fifo_1left_to_full_uq2de (fifo_1left_to_full_uq2de),
        .fifo_2left_to_full_uq2de (fifo_2left_to_full_uq2de),
        .fifo_3left_to_full_uq2de (fifo_3left_to_full_uq2de)
    );

  // Uop queue
    fifo_flopped_4w2r #(
        .DWIDTH     ($bits(UOP_QUEUE_t)),
        .DEPTH      (`UQ_DEPTH),
    ) u_uop_queue (
      // global
        .clk        (clk),
        .rst_n      (rst_n),
      // write
        .push0      (push0_de2uq),
        .inData0    (data0_de2uq),
        .push1      (push1_de2uq),
        .inData1    (data1_de2uq),
        .push2      (push2_de2uq),
        .inData2    (data2_de2uq),
        .push3      (push3_de2uq),
        .inData3    (data3_de2uq),
      // read
        .pop0       (uop_valid_uop2dp[0] & uop_ready_dp2uop[0]),
        .outData0   (uop_uop2dp[0]),
        .pop1       (uop_valid_uop2dp[1] & uop_ready_dp2uop[1]),
        .outData1   (uop_uop2dp[1]),
      // fifo status
        .fifo_halfFull        (),
        .fifo_full            (fifo_full_uq2de),
        .fifo_1left_to_full   (fifo_1left_to_full_uq2de),
        .fifo_2left_to_full   (fifo_2left_to_full_uq2de),
        .fifo_3left_to_full   (fifo_3left_to_full_uq2de),
        .fifo_empty           (uq_empty),
        .fifo_1left_to_empty  (uq_1left_to_empty),
        .fifo_idle            ()
    );

    assign uop_valid_uop2dp[0] = ~uq_empty;
    assign uop_valid_uop2dp[1] = ~uq_1left_to_empty;

  // Dispatch unit
    rvv_backend_dispatch #(
    ) u_dispatch (
      // global
        .clk        (clk),
        .rst_n      (rst_n),
      // Uop queue to dispatch
        .uop_valid_uop2dp   (uop_valid_uop2dp),
        .uop_uop2dp         (uop_uop2dp),
        .uop_ready_dp2uop   (uop_ready_dp2uop),
      // Dispatch to RS
        // ALU_RS
        .rs_valid_dp2alu    (rs_valid_dp2alu),
        .rs_dp2alu          (rs_dp2alu),
        .rs_ready_alu2dp    (rs_ready_alu2dp),
        // PMTRDT_RS
        .rs_valid_dp2pmtrdt (rs_valid_dp2pmtrdt),
        .rs_dp2pmtrdt       (rs_dp2pmtrdt),
        .rs_ready_pmtrdt2dp (rs_ready_pmtrdt2dp),
        // MUL_RS
        .rs_valid_dp2mul    (rs_valid_dp2mul),
        .rs_dp2mul          (rs_dp2mul),
        .rs_ready_mul2dp    (rs_ready_mul2dp),
        // DIV_RS
        .rs_valid_dp2div    (rs_valid_dp2div),
        .rs_dp2div          (rs_dp2div),
        .rs_ready_div2dp    (rs_ready_div2dp),
        // LSU_RS
        .rs_valid_dp2lsu    (rs_valid_dp2lsu),
        .rs_dp2lsu          (rs_dp2lsu),
        .rs_ready_lsu2dp    (rs_ready_lsu2dp),
      // Dispatch to ROB
        .uop_valid_dp2rob   (uop_valid_dp2rob),
        .uop_dp2rob         (uop_dp2rob),
        .uop_ready_rob2dp   (uop_ready_rob2dp),
        .uop_index_rob2dp   (uop_index_rob2dp),
      // VRF to dispatch
        .rd_index_dp2vrf    (rd_index_dp2vrf),
        .rd_data_vrf2dp     (rd_data_vrf2dp),
        .v0_mask_vrf2dp     (v0_mask_vrf2dp),
      // ROB to dispatch
        .rob_entry          (rob_entry)
    );

  // RS, Reserve station
    // ALU RS
    fifo_flopped_2w2r #(
        .DWIDTH     ($bits(ALU_RS_t)),
        .DEPTH      (`ALU_RS_DEPTH),
    ) u_alu_rs (
      // global
        .clk        (clk),
        .rst_n      (rst_n),
      // write
        .push0      (rs_valid_dp2alu[0] & rs_ready_alu2dp[0]),
        .inData0    (rs_dp2alu[0]),
        .push1      (rs_valid_dp2alu[1] & rs_ready_alu2dp[1]),
        .inData1    (rs_dp2alu[1]),
      // read
        .pop0       (pop0_alu2rs),
        .outData0   (uop0_rs2alu),
        .pop1       (pop1_alu2rs),
        .outData1   (uop1_rs2alu),
      // fifo status
        .fifo_halfFull        (),
        .fifo_full            (alu_rs_full),
        .fifo_1left_to_full   (alu_rs_1left_to_full),
        .fifo_empty           (fifo_empty_rs2alu),
        .fifo_1left_to_empty  (fifo_1left_to_empty_rs2alu),
        .fifo_idle            ()
    );

    assign rs_ready_alu2dp[0] = ~alu_rs_full;
    assign rs_ready_alu2dp[1] = ~alu_rs_1left_to_full;

    // PMTRDT RS, Permutation + Reduction
    // TODO: update once PMTRDT unit implements
    openFifo8_flopped_2w2r #(
        .DWIDTH     ($bits(PMT_RDT_RS_t)),
        .DEPTH      (`PMTRDT_RS_DEPTH),
    ) u_pmtrdt_rs (
      // global
        .clk        (clk),
        .rst_n      (rst_n),
      // write
        .push0      (rs_valid_dp2pmtrdt[0] & rs_ready_pmtrdt2dp[0]),
        .inData0    (rs_dp2pmtrdt[0]),
        .push1      (rs_valid_dp2pmtrdt[1] & rs_ready_pmtrdt2dp[1]),
        .inData1    (rs_dp2pmtrdt[1]),
      // read
        .pop0       (),
        .outData0   (),
        .pop1       (),
        .outData1   (),
      // fifo status
        .fifo_halfFull        (),
        .fifo_full            (pmtrdt_rs_full),
        .fifo_1left_to_full   (pmtrdt_rs_1left_to_full),
        .fifo_empty           (),
        .fifo_1left_to_empty  (),
        .fifo_idle            ()
    );

    assign rs_ready_pmtrdt2dp[0] = ~pmtrdt_rs_full;
    assign rs_ready_pmtrdt2dp[1] = ~pmtrdt_rs_1left_to_full;

    // MUL RS, Multiply + Multiply-accumulate
    // TODO: update once MUL unit implements
    fifo_flopped_2w2r #(
        .DWIDTH     ($bits(MUL_RS_t)),
        .DEPTH      (`MUL_RS_DEPTH),
    ) u_mul_rs (
      // global
        .clk        (clk),
        .rst_n      (rst_n),
      // write
        .push0      (rs_valid_dp2mul[0] & rs_ready_mul2dp[0]),
        .inData0    (rs_dp2mul[0]),
        .push1      (rs_valid_dp2mul[1] & rs_ready_mul2dp[1]),
        .inData1    (rs_dp2mul[1]),
      // read
        .pop0       (),
        .outData0   (),
        .pop1       (),
        .outData1   (),
      // fifo status
        .fifo_halfFull        (),
        .fifo_full            (mul_rs_full),
        .fifo_1left_to_full   (mul_rs_1left_to_full),
        .fifo_empty           (),
        .fifo_1left_to_empty  (),
        .fifo_idle            ()
    );

    assign rs_ready_mul2dp[0] = ~mul_rs_full;
    assign rs_ready_mul2dp[1] = ~mul_rs_1left_to_full;

    // DIV RS
    // TODO: update once DIV unit implements
    fifo_flopped_2w2r #(
        .DWIDTH     ($bits(DIV_RS_t)),
        .DEPTH      (`DIV_RS_DEPTH),
    ) u_div_rs (
      // global
        .clk        (clk),
        .rst_n      (rst_n),
      // write
        .push0      (rs_valid_dp2div[0] & rs_ready_div2dp[0]),
        .inData0    (rs_dp2div[0]),
        .push1      (rs_valid_dp2div[1] & rs_ready_div2dp[1]),
        .inData1    (rs_dp2div[1]),
      // read
        .pop0       (),
        .outData0   (),
        .pop1       (),
        .outData1   (),
      // fifo status
        .fifo_halfFull        (),
        .fifo_full            (div_rs_full),
        .fifo_1left_to_full   (div_rs_1left_to_full),
        .fifo_empty           (),
        .fifo_1left_to_empty  (),
        .fifo_idle            ()
    );

    assign rs_ready_div2dp[0] = ~div_rs_full;
    assign rs_ready_div2dp[1] = ~div_rs_1left_to_full;

    // LSU RS
    fifo_flopped_2w2r #(
        .DWIDTH     ($bits(LSU_RS_t)),
        .DEPTH      (`LSU_RS_DEPTH),
    ) u_lsu_rs (
      // global
        .clk        (clk),
        .rst_n      (rst_n),
      // write
        .push0      (rs_valid_dp2lsu[0] & rs_ready_lsu2dp[0]),
        .inData0    (rs_dp2lsu[0]),
        .push1      (rs_valid_dp2lsu[1] & rs_ready_lsu2dp[1]),
        .inData1    (rs_dp2lsu[1]),
      // read
        .pop0       (),
        .outData0   (),
        .pop1       (),
        .outData1   (),
      // fifo status
        .fifo_halfFull        (),
        .fifo_full            (lsu_rs_full),
        .fifo_1left_to_full   (lsu_rs_1left_to_full),
        .fifo_empty           (),
        .fifo_1left_to_empty  (),
        .fifo_idle            ()
    );
