`include "rvv_backend.svh"
`include "rvv_backend_sva.svh"

module rvv_backend
(
    clk,
    rst_n,

    insts_valid_rvs2cq,
    insts_rvs2cq,
    insts_ready_cq2rvs,

    uop_valid_lsu_rvv2rvs,
    uop_lsu_rvv2rvs,
    uop_ready_lsu_rvs2rvv,

    uop_valid_lsu_rvs2rvv,
    uop_lsu_rvs2rvv,
    uop_ready_rvv2rvs,

    rt_xrf_rvv2rvs,
    rt_xrf_valid_rvv2rvs,
    rt_xrf_ready_rvs2rvv,

    wr_vxsat_valid,
    wr_vxsat,

    trap_valid_rvs2rvv,
    trap_rvs2rvv,
    trap_ready_rvv2rvs,    

    vcsr_valid,
    vector_csr
);
// global signal
    input   logic                  clk;
    input   logic                  rst_n;

// vector instruction and scalar operand input. 
    input   logic   [`ISSUE_LANE-1:0] insts_valid_rvs2cq;
    input   RVVCmd  [`ISSUE_LANE-1:0] insts_rvs2cq;
    output  logic   [`ISSUE_LANE-1:0] insts_ready_cq2rvs;  

// load/store unit interface
  // RVV send LSU uop to RVS
    output  logic   [`NUM_DP_UOP-1:0] uop_valid_lsu_rvv2rvs;
    output  UOP_LSU_RVV2RVS_t [`NUM_DP_UOP-1:0] uop_lsu_rvv2rvs;
    input   logic   [`NUM_DP_UOP-1:0] uop_ready_lsu_rvs2rvv;
  // LSU feedback to RVV
    input   logic   [`NUM_DP_UOP-1:0] uop_valid_lsu_rvs2rvv;
    input   UOP_LSU_RVS2RVV_t [`NUM_DP_UOP-1:0] uop_lsu_rvs2rvv;
    output  logic   [`NUM_DP_UOP-1:0] uop_ready_rvv2rvs;

// RT to XRF. RVS arbitrates write ports of XRF by itself.
    output  logic    [`NUM_RT_UOP-1:0] rt_xrf_valid_rvv2rvs;
    output  RT2XRF_t [`NUM_RT_UOP-1:0] rt_xrf_rvv2rvs;
    input   logic    [`NUM_RT_UOP-1:0] rt_xrf_ready_rvs2rvv;

// RT to VCSR.vxsat
    output  logic                            wr_vxsat_valid;
    output  logic    [`VCSR_VXSAT_WIDTH-1:0] wr_vxsat;

// exception handler
  // trap signal handshake
    input   logic                         trap_valid_rvs2rvv;
    input   TRAP_t                        trap_rvs2rvv;
    output  logic                         trap_ready_rvv2rvs;    
  // the vcsr of last retired uop in last cycle
    output  logic                         vcsr_valid;
    output  RVVConfigState                vector_csr;

`ifdef TB_BRINGUP
  // inst queue
  logic [5:0] src1_idx [3:0]; 
  logic [5:0] src2_idx [3:0]; 
  logic [5:0] dest_idx [3:0];
  logic inst_valid [3:0];
  logic [31:0] inst_queue [3:0];
  always_ff @(posedge clk) begin
    if(!rst_n) begin 
      insts_ready_cq2rvs[0] <= 1'b0;
      insts_ready_cq2rvs[1] <= 1'b0;
      insts_ready_cq2rvs[2] <= 1'b0;
      insts_ready_cq2rvs[3] <= 1'b0;
      rt_xrf_valid_wb2rvs[0] <= 1'b0;
      rt_xrf_valid_wb2rvs[1] <= 1'b0;
      rt_xrf_valid_wb2rvs[2] <= 1'b0;
      rt_xrf_valid_wb2rvs[3] <= 1'b0;
    end else begin
      insts_ready_cq2rvs[0] <= 1'b1;
      insts_ready_cq2rvs[1] <= 1'b1;
      insts_ready_cq2rvs[2] <= 1'b0;
      insts_ready_cq2rvs[3] <= 1'b0;
      rt_xrf_valid_wb2rvs[0] <= 1'b0;
      rt_xrf_valid_wb2rvs[1] <= 1'b0;
      rt_xrf_valid_wb2rvs[2] <= 1'b0;
      rt_xrf_valid_wb2rvs[3] <= 1'b0;
    end
  end

  always_ff @(posedge clk) begin
    if(!rst_n) begin 
      inst_valid[0] <= 1'b0;
      inst_valid[1] <= 1'b0;
      inst_valid[2] <= 1'b0;
      inst_valid[3] <= 1'b0;
    end else begin
      inst_valid[0] <= insts_ready_cq2rvs[0] & insts_valid_rvs2cq[0];
      inst_valid[1] <= insts_ready_cq2rvs[1] & insts_valid_rvs2cq[1];
      inst_valid[2] <= insts_ready_cq2rvs[2] & insts_valid_rvs2cq[2];
      inst_valid[3] <= insts_ready_cq2rvs[3] & insts_valid_rvs2cq[3];
      inst_queue[0] <= (insts_ready_cq2rvs[0] & insts_valid_rvs2cq[0]) ? {insts_rvs2cq[0].bits,insts_rvs2cq[0].opcode,5'b0} : inst_queue[0];
      inst_queue[1] <= (insts_ready_cq2rvs[1] & insts_valid_rvs2cq[1]) ? {insts_rvs2cq[1].bits,insts_rvs2cq[1].opcode,5'b0} : inst_queue[1];
      inst_queue[2] <= (insts_ready_cq2rvs[2] & insts_valid_rvs2cq[2]) ? {insts_rvs2cq[2].bits,insts_rvs2cq[2].opcode,5'b0} : inst_queue[2];
      inst_queue[3] <= (insts_ready_cq2rvs[3] & insts_valid_rvs2cq[3]) ? {insts_rvs2cq[3].bits,insts_rvs2cq[3].opcode,5'b0} : inst_queue[3];
    end
  end

  always_comb begin
    for(int i=0;i<4;i++) begin
      src1_idx[i] = inst_queue[i][19:15];
      src2_idx[i] = inst_queue[i][24:20];
      dest_idx[i] = inst_queue[i][11:7];
    end
  end

  // vrf
  logic [127:0] vreg [31:0];
  logic [127:0] vreg_init_data [31:0];
  logic [3:0] rt_last_uop;
  always_ff @(posedge clk) begin
    if(!rst_n) begin 
      for(int i=0; i<32; i++) begin
        vreg[i] <= vreg_init_data[i];
      end
      for(int i=0; i<4; i++) begin
        rt_last_uop[i] <= 1'b0;
      end
    end else begin
      for(int i=0; i<4; i++) begin
        if(inst_valid[i]) begin
            for(int elm_idx=0; elm_idx<16; elm_idx++) begin
              // sew 8b, lmul 1, vl=16
              vreg[dest_idx[i]][elm_idx*8+:8] <= vreg[src1_idx[i]][elm_idx*8+:8] + vreg[src2_idx[i]][elm_idx*8+:8];
            end
          rt_last_uop[i] <= 1'b1;
        end else begin
          rt_last_uop[i] <= 1'b0;
        end
      end
    end
  end

  initial begin
    forever begin
      @(posedge clk);
      for(int i=0; i<3; i++) begin
        if(insts_valid_rvs2cq[i] && insts_ready_cq2rvs[i]) begin
          $display("[RTL INFO] @ %0t Got a instruction packet in insts_rvs2cq[%0d]", $time, i);
          $display("insts_rvs2cq[i].pc    = 0x%8x", insts_rvs2cq[i].inst_pc);
          $display("insts_rvs2cq[i].insts = 0x%8x", {insts_rvs2cq[i].bits,insts_rvs2cq[i].opcode,5'b0});
        end
      end
    end
  end
`else
// ---internal signals definition-------------------------------------
  // RVV frontend to command queue
    logic                                 cq_full;
    logic                                 cq_1left_to_full;
    logic                                 cq_2left_to_full;
    logic                                 cq_3left_to_full;
  // Command queue to Decode
    RVVCmd       [`NUM_DE_INST-1:0]       inst_pkg_cq2de;
    logic                                 fifo_empty_cq2de;
    logic        [`NUM_DE_INST-1:1]       fifo_almost_empty_cq2de;
    logic        [`NUM_DE_INST-1:0]       pop_de2cq;
  // Decode to uop queue
    logic        [`NUM_DE_UOP-1:0]        push_de2uq;
    UOP_QUEUE_t  [`NUM_DE_UOP-1:0]        data_de2uq;
    logic                                 fifo_full_uq2de; 
    logic        [`NUM_DE_UOP-1:1]        fifo_almost_full_uq2de;
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
    logic        [`NUM_ALU-1:0]           pop_alu2rs;
    ALU_RS_t     [`NUM_ALU-1:0]           uop_rs2alu;
    logic                                 fifo_empty_rs2alu;
    logic        [`NUM_ALU-1:1]           fifo_almost_empty_rs2alu;
  // LSU_RS to LSU
    logic        [`NUM_LSU-1:0]           pop_lsu2rs;
    LSU_RS_t     [`NUM_LSU-1:0]           uop_rs2lsu;
    logic                                 fifo_empty_rs2lsu;
    logic        [`NUM_LSU-1:1]           fifo_almost_empty_rs2lsu;
  // MUL_RS to MUL
    logic        [`NUM_MUL-1:0]           pop_mul2rs;
    MUL_RS_t     [`NUM_MUL-1:0]           uop_rs2mul;
    logic                                 fifo_empty_rs2mul;
    logic                                 fifo_1left_to_empty_rs2mul;
  // DIV_RS to DIV
    logic        [`NUM_DIV-1:0]           pop_div2rs;
    DIV_RS_t     [`NUM_DIV-1:0]           uop_rs2div;
    logic                                 fifo_empty_rs2div;
`ifdef MULTI_DIV
    logic                                 fifo_1left_to_empty_rs2div;
`endif
  // ALU to ROB
    logic        [`NUM_ALU-1:0]           wr_valid_alu2rob;
    PU2ROB_t     [`NUM_ALU-1:0]           wr_alu2rob;
    logic        [`NUM_ALU-1:0]           wr_ready_rob2alu;
  // PMTRDT to ROB
    logic        [`NUM_PMTRDT-1:0]        wr_valid_pmtrdt2rob;
    PU2ROB_t     [`NUM_PMTRDT-1:0]        wr_pmtrdt2rob;
    logic        [`NUM_PMTRDT-1:0]        wr_ready_rob2pmtrdt;
  // MUL to ROB
    logic        [`NUM_MUL-1:0]           wr_valid_mul2rob;
    PU2ROB_t     [`NUM_MUL-1:0]           wr_mul2rob;
    logic        [`NUM_MUL-1:0]           wr_ready_rob2mul;
  // DIV to ROB
    logic        [`NUM_DIV-1:0]           wr_valid_div2rob;
    PU2ROB_t     [`NUM_DIV-1:0]           wr_div2rob;
    logic        [`NUM_DIV-1:0]           wr_ready_rob2div;
  // LSU to ROB
    logic        [`NUM_LSU-1:0]           wr_valid_lsu2rob;
    PU2ROB_t     [`NUM_LSU-1:0]           wr_lsu2rob;
    logic        [`NUM_LSU-1:0]           wr_ready_rob2lsu;
  // DP to VRF
    logic [`NUM_DP_VRF-1:0][`REGFILE_INDEX_WIDTH-1:0] rd_index_dp2vrf;          
    logic [`NUM_DP_VRF-1:0][`VLEN-1:0]                rd_data_vrf2dp;
    logic [`VLEN-1:0]                                 v0_mask_vrf2dp;
  // ROB to dispatch
    ROB2DP_t     [`ROB_DEPTH-1:0]         uop_rob2dp;
  // ROB to RT
    logic        [`NUM_RT_UOP-1:0]        rd_valid_rob2rt;
    ROB2RT_t     [`NUM_RT_UOP-1:0]        rd_rob2rt;
    logic        [`NUM_RT_UOP-1:0]        rd_ready_rt2rob;
  // RT to VRF
    logic        [`NUM_RT_UOP-1:0]        wr_valid_rt2vrf;
    RT2VRF_t     [`NUM_RT_UOP-1:0]        wr_data_rt2vrf;

    genvar i;

// ---code start------------------------------------------------------
  // Command queue
    fifo_flopped_4w2r #(
        .DWIDTH     ($bits(RVVCmd)),
        .DEPTH      (`CQ_DEPTH)
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
        .pop0       (pop_de2cq[0]),
        .outData0   (inst_pkg_cq2de[0]),
        .pop1       (pop_de2cq[1]),
        .outData1   (inst_pkg_cq2de[1]),
      // fifo status
        .fifo_full            (cq_full),
        .fifo_1left_to_full   (cq_1left_to_full),
        .fifo_2left_to_full   (cq_2left_to_full),
        .fifo_3left_to_full   (cq_3left_to_full),
        .fifo_empty           (fifo_empty_cq2de),
        .fifo_1left_to_empty  (fifo_almost_empty_cq2de),
        .fifo_idle            ()
    );

    assign insts_ready_cq2rvs[0] = ~cq_full;
    assign insts_ready_cq2rvs[1] = ~cq_full & ~cq_1left_to_full;
    assign insts_ready_cq2rvs[2] = ~cq_full & ~cq_1left_to_full & ~cq_2left_to_full;
    assign insts_ready_cq2rvs[3] = ~cq_full & ~cq_1left_to_full & ~cq_2left_to_full & ~cq_3left_to_full;

  `ifdef ASSERT_ON
    PushToCMDQueue: `rvv_expect((insts_valid_rvs2cq & insts_ready_cq2rvs) inside {4'b1111, 4'b0111, 4'b0011, 4'b0001, 4'b0000})
      else $error("Push to command queue out-of-order: %4b.", $sampled(insts_valid_rvs2cq & insts_ready_cq2rvs));

    PopFromCMDQueue: `rvv_expect(pop_de2cq inside {2'b11, 2'b01, 2'b00})
      else $error("Pop from command queue out-of-order: %2b.", $sampled(pop_de2cq));
  `endif // ASSERT_ON

  // Decode unit
    rvv_backend_decode #(
    ) u_decode (
      // global
        .clk        (clk),
        .rst_n      (rst_n),
      // cq2de
        .inst_pkg_cq2de       (inst_pkg_cq2de),
        .fifo_empty_cq2de     (fifo_empty_cq2de),
        .fifo_almost_empty_cq2de  (fifo_almost_empty_cq2de),
        .pop_de2cq            (pop_de2cq),
      // de2uq
        .push_de2uq           (push_de2uq),
        .data_de2uq           (data_de2uq),
        .fifo_full_uq2de      (fifo_full_uq2de),
        .fifo_almost_full_uq2de (fifo_almost_full_uq2de)
    );

  // Uop queue
    fifo_flopped_4w2r #(
        .DWIDTH     ($bits(UOP_QUEUE_t)),
        .DEPTH      (`UQ_DEPTH)
    ) u_uop_queue (
      // global
        .clk        (clk),
        .rst_n      (rst_n),
      // write
        .push0      (push_de2uq[0]),
        .inData0    (data_de2uq[0]),
        .push1      (push_de2uq[1]),
        .inData1    (data_de2uq[1]),
        .push2      (push_de2uq[2]),
        .inData2    (data_de2uq[2]),
        .push3      (push_de2uq[3]),
        .inData3    (data_de2uq[3]),
      // read
        .pop0       (uop_valid_uop2dp[0] & uop_ready_dp2uop[0]),
        .outData0   (uop_uop2dp[0]),
        .pop1       (uop_valid_uop2dp[1] & uop_ready_dp2uop[1]),
        .outData1   (uop_uop2dp[1]),
      // fifo status
        .fifo_full            (fifo_full_uq2de),
        .fifo_1left_to_full   (fifo_almost_full_uq2de[1]),
        .fifo_2left_to_full   (fifo_almost_full_uq2de[2]),
        .fifo_3left_to_full   (fifo_almost_full_uq2de[3]),
        .fifo_empty           (uq_empty),
        .fifo_1left_to_empty  (uq_1left_to_empty),
        .fifo_idle            ()
    );

    assign uop_valid_uop2dp[0] = ~uq_empty;
    assign uop_valid_uop2dp[1] = ~uq_empty & ~uq_1left_to_empty;

  `ifdef ASSERT_ON
    PushToUopQueue: `rvv_expect(push_de2uq inside {4'b1111, 4'b0111, 4'b0011, 4'b0001, 4'b0000})
      else $error("Push to uops queue out-of-order: %4b", $sampled(push_de2uq));

    PopFromUopQueue: `rvv_expect((uop_valid_uop2dp & uop_ready_dp2uop) inside {2'b11, 2'b01, 2'b00})
      else $error("Pop from uops queue out-of-order: %2b", $sampled(uop_valid_uop2dp & uop_ready_dp2uop));
  `endif // ASSERT_ON

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
        .rob_entry          (uop_rob2dp)
    );

  // RS, Reserve station
    // ALU RS
    fifo_flopped_2w2r #(
        .DWIDTH     ($bits(ALU_RS_t)),
        .DEPTH      (`ALU_RS_DEPTH)
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
        .pop0       (pop_alu2rs[0]),
        .outData0   (uop_rs2alu[0]),
        .pop1       (pop_alu2rs[1]),
        .outData1   (uop_rs2alu[1]),
      // fifo status
        .fifo_full            (alu_rs_full),
        .fifo_1left_to_full   (alu_rs_1left_to_full),
        .fifo_empty           (fifo_empty_rs2alu),
        .fifo_1left_to_empty  (fifo_almost_empty_rs2alu),
        .fifo_idle            ()
    );

    assign rs_ready_alu2dp[0] = ~alu_rs_full;
    assign rs_ready_alu2dp[1] = ~alu_rs_full & ~alu_rs_1left_to_full;

  `ifdef ASSERT_ON
    PushToAluRSQueue: `rvv_expect((rs_valid_dp2alu & rs_ready_alu2dp) inside {2'b11, 2'b01, 2'b00})
      else $error("Push to ALU Reservation Station out-of-order: %4b", $sampled(rs_valid_dp2alu & rs_ready_alu2dp));

    PopFromAluRSQueue: `rvv_expect((pop_alu2rs) inside {2'b11, 2'b01, 2'b00})
      else $error("Pop from ALU Reservation Station out-of-order: %2b", $sampled(pop_alu2rs));
  `endif // ASSERT_ON

    // PMTRDT RS, Permutation + Reduction
    // TODO: update once PMTRDT unit implements
    openFifo8_flopped_2w2r #(
        .DWIDTH     ($bits(PMT_RDT_RS_t))
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
        .pop0       (1'b0),
        .outData0   (),
        .pop1       (1'b0),
        .outData1   (),
      // fifo status
        .fifo_full            (pmtrdt_rs_full),
        .fifo_1left_to_full   (pmtrdt_rs_1left_to_full),
        .fifo_empty           (),
        .fifo_1left_to_empty  (),
        .d0                   (),
        .d1                   (),
        .d2                   (),
        .d3                   (),
        .d4                   (),
        .d5                   (),
        .d6                   (),
        .d7                   (),
        .dPtr                 (),
        .dValid               ()
    );

    assign rs_ready_pmtrdt2dp[0] = ~pmtrdt_rs_full;
    assign rs_ready_pmtrdt2dp[1] = ~pmtrdt_rs_full & ~pmtrdt_rs_1left_to_full;

  `ifdef ASSERT_ON
    PushToPmtrdtRSQueue: `rvv_expect((rs_valid_dp2pmtrdt & rs_ready_pmtrdt2dp) inside {2'b11, 2'b01, 2'b00})
      else $error("Push to PMTRDT Reservation Station out-of-order: %4b", $sampled(rs_valid_dp2pmtrdt & rs_ready_pmtrdt2dp));

    // PopFromPmtrdtRSQueue: `rvv_expect((pop_pmtrdt2rs) inside {2'b11, 2'b01, 2'b00})
    //   else $error("Pop from PMTRDT Reservation Station out-of-order: %2b", $sampled(pop_pmtrdt2rs));
  `endif // ASSERT_ON

    // MUL RS, Multiply + Multiply-accumulate
    fifo_flopped_2w2r #(
        .DWIDTH     ($bits(MUL_RS_t)),
        .DEPTH      (`MUL_RS_DEPTH)
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
        .pop0       (pop_mul2rs[0]),
        .outData0   (uop_rs2mul[0]),
        .pop1       (pop_mul2rs[1]),
        .outData1   (uop_rs2mul[1]),
      // fifo status
        .fifo_full            (mul_rs_full),
        .fifo_1left_to_full   (mul_rs_1left_to_full),
        .fifo_empty           (fifo_empty_rs2mul),
        .fifo_1left_to_empty  (fifo_1left_to_empty_rs2mul),
        .fifo_idle            ()
    );

    assign rs_ready_mul2dp[0] = ~mul_rs_full;
    assign rs_ready_mul2dp[1] = ~mul_rs_full & ~mul_rs_1left_to_full;

  `ifdef ASSERT_ON
    PushToMulRSQueue: `rvv_expect((rs_valid_dp2mul & rs_ready_mul2dp) inside {2'b11, 2'b01, 2'b00})
      else $error("Push to MUL Reservation Station out-of-order: %4b", $sampled(rs_valid_dp2mul & rs_ready_mul2dp));

    // PopFromMulRSQueue: `rvv_expect((pop_mul2rs) inside {2'b11, 2'b01, 2'b00})
    //   else $error("Pop from MUL Reservation Station out-of-order: %2b", $sampled(pop_mul2rs));
  `endif // ASSERT_ON

    // DIV RS
    fifo_flopped_2w2r #(
        .DWIDTH     ($bits(DIV_RS_t)),
        .DEPTH      (`DIV_RS_DEPTH)
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
        .pop0       (pop_div2rs[0]),
        .outData0   (uop_rs2div[0]),
        .pop1       (1'b0),
        .outData1   (),
      // fifo status
        .fifo_full            (div_rs_full),
        .fifo_1left_to_full   (div_rs_1left_to_full),
        .fifo_empty           (fifo_empty_rs2div),
`ifdef MULTI_DIV
        .fifo_1left_to_empty  (fifo_1left_to_empty_rs2div),
`endif
        .fifo_idle            ()
    );

    assign rs_ready_div2dp[0] = ~div_rs_full;
    assign rs_ready_div2dp[1] = ~div_rs_full & ~div_rs_1left_to_full;

  `ifdef ASSERT_ON
    PushToDivRSQueue: `rvv_expect((rs_valid_dp2div & rs_ready_div2dp) inside {2'b11, 2'b01, 2'b00})
      else $error("Push to DIV Reservation Station out-of-order: %4b", $sampled(rs_valid_dp2div & rs_ready_div2dp));

    // PopFromDivRSQueue: `rvv_expect((pop_div2rs) inside {2'b11, 2'b01, 2'b00})
    //   else $error("Pop from DIV Reservation Station out-of-order: %2b", $sampled(pop_div2rs));
  `endif // ASSERT_ON

    // LSU RS
    fifo_flopped_2w2r #(
        .DWIDTH     ($bits(LSU_RS_t)),
        .DEPTH      (`LSU_RS_DEPTH)
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
        .pop0       (uop_valid_lsu_rvv2rvs[0] & uop_ready_lsu_rvs2rvv[0]),
        .outData0   (uop_rs2lsu[0]),
        .pop1       (uop_valid_lsu_rvv2rvs[1] & uop_ready_lsu_rvs2rvv[1]),
        .outData1   (uop_rs2lsu[1]),
      // fifo status
        .fifo_full            (lsu_rs_full),
        .fifo_1left_to_full   (lsu_rs_1left_to_full),
        .fifo_empty           (fifo_empty_rs2lsu),
        .fifo_1left_to_empty  (fifo_almost_empty_rs2lsu),
        .fifo_idle            ()
    );
  
    assign rs_ready_lsu2dp[0] = ~lsu_rs_full;
    assign rs_ready_lsu2dp[1] = ~lsu_rs_full & ~lsu_rs_1left_to_full;

    assign uop_valid_lsu_rvv2rvs[0] = ~fifo_empty_rs2lsu;
    assign uop_valid_lsu_rvv2rvs[1] = ~(fifo_empty_rs2lsu || fifo_almost_empty_rs2lsu);
    assign uop_lsu_rvv2rvs = uop_rs2lsu;

  `ifdef ASSERT_ON
    PushToLsuRSQueue: `rvv_expect((rs_valid_dp2lsu & rs_ready_lsu2dp) inside {2'b11, 2'b01, 2'b00})
      else $error("Push to LSU Reservation Station out-of-order: %4b", $sampled(rs_valid_dp2lsu & rs_ready_lsu2dp));

    // PopFromLsuRSQueue: `rvv_expect((pop_lsu2rs) inside {2'b11, 2'b01, 2'b00})
    //   else $error("Pop from LSU Reservation Station out-of-order: %2b", $sampled(pop_lsu2rs));
  `endif // ASSERT_ON

  // PU, Process unit
    // ALU
    rvv_backend_alu #(
    ) u_alu (
      // ALU_RS to ALU
        .pop_ex2rs                  (pop_alu2rs),
        .alu_uop_rs2ex              (uop_rs2alu),
        .fifo_empty_rs2ex           (fifo_empty_rs2alu),
        .fifo_almost_empty_rs2ex    (fifo_almost_empty_rs2alu),
      // ALU to ROB  
        .result_valid_ex2rob        (wr_valid_alu2rob),
        .result_ex2rob              (wr_alu2rob),
        .result_ready_rob2alu       (wr_ready_rob2alu)
    );

    /*
    // PMTRDT
    // TODO
    rvv_pmtrdt #(
    ) u_pmtrdt (
    );
    */
    assign wr_valid_pmtrdt2rob = '0;
    assign wr_pmtrdt2rob       = '0;

    
    // MULMAC
    rvv_backend_mulmac u_mulmac (
      .clk(clk), 
      .rst_n(rst_n), 
    // MUL_RS to MULMAC
      .ex2rs_fifo_pop(pop_mul2rs),
      .rs2ex_uop_data(uop_rs2mul), 
      .rs2ex_fifo_empty(fifo_empty_rs2mul), 
      .rs2ex_fifo_1left_to_empty(fifo_1left_to_empty_rs2mul), 
    //MULMAC to ROB
      .ex2rob_valid(wr_valid_mul2rob), 
      .ex2rob_data(wr_mul2rob),
      .rob2ex_ready(wr_ready_rob2mul)
    );
    
    
    // DIV
    rvv_backend_div u_div
    (  
      .clk                      (clk),
      .rst_n                    (rst_n),
      // DIV_RS to DIV
      .pop_ex2rs                (pop_div2rs),
      .div_uop_rs2ex            (uop_rs2div),
      .fifo_empty_rs2ex         (fifo_empty_rs2div),
`ifdef MULTI_DIV
      .fifo_almost_empty_rs2ex  (fifo_1left_to_empty_rs2div),
`endif
      // DIV to ROB
      .result_valid_ex2rob      (wr_valid_div2rob),
      .result_ex2rob            (wr_div2rob),
      .result_ready_rob2div     (wr_ready_rob2div) 
    );

    // LSU
    generate
        for (i=0; i<`NUM_LSU; i++) begin : gen_lsu2rob
`ifdef TB_SUPPORT
            assign wr_lsu2rob[i].uop_pc = uop_lsu_rvs2rvv[i].uop_pc;
`endif
            assign wr_valid_lsu2rob[i] = uop_valid_lsu_rvs2rvv[i]; 
            assign wr_lsu2rob[i].rob_entry = uop_lsu_rvs2rvv[i].uop_id;
            assign wr_lsu2rob[i].w_data    = uop_lsu_rvs2rvv[i].vregfile_write_data;
            assign wr_lsu2rob[i].w_valid   = ~uop_lsu_rvs2rvv[i].uop_type; // 0 for load, 1 for store
            assign wr_lsu2rob[i].vxsat     = 1'b0;
            assign wr_lsu2rob[i].ignore_vta = 1'b0;
            assign wr_lsu2rob[i].ignore_vma = 1'b0;
        end
    endgenerate

  // ROB, Re-Order Buffer
    rvv_backend_rob #(
    ) u_rob (
      // global signal
        .clk                 (clk),
        .rst_n               (rst_n),
      // Dispatch to ROB
        .uop_valid_dp2rob    (uop_valid_dp2rob),
        .uop_dp2rob          (uop_dp2rob),
        .uop_ready_rob2dp    (uop_ready_rob2dp),
        .uop_index_rob2dp    (uop_index_rob2dp),
      // ALU to ROB
        .wr_valid_alu2rob    (wr_valid_alu2rob),
        .wr_alu2rob          (wr_alu2rob),
        .wr_ready_rob2alu    (wr_ready_rob2alu),
      // PMTRDT to ROB
        .wr_valid_pmtrdt2rob (wr_valid_pmtrdt2rob),
        .wr_pmtrdt2rob       (wr_pmtrdt2rob),
        .wr_ready_rob2pmtrdt (wr_ready_rob2pmtrdt),
      // MUL to ROB
        .wr_valid_mul2rob    (wr_valid_mul2rob),
        .wr_mul2rob          (wr_mul2rob),
        .wr_ready_rob2mul    (wr_ready_rob2mul),
      // DIV to ROB
        .wr_valid_div2rob    (wr_valid_div2rob),
        .wr_div2rob          (wr_div2rob),
        .wr_ready_rob2div    (wr_ready_rob2div),
      // LSU to ROB
        .wr_valid_lsu2rob    (wr_valid_lsu2rob),
        .wr_lsu2rob          (wr_lsu2rob),
        .wr_ready_rob2lsu    (wr_ready_rob2lsu),
      // ROB to RT
        .rd_valid_rob2rt     (rd_valid_rob2rt),
        .rd_rob2rt           (rd_rob2rt),
        .rd_ready_rt2rob     (rd_ready_rt2rob),
      // ROB to DP
        .uop_rob2dp          (uop_rob2dp),
      // Trap
        .trap_valid_rvs2rvv  (trap_valid_rvs2rvv),
        .trap_rvs2rvv        (trap_rvs2rvv),
        .trap_ready_rvv2rvs  (trap_ready_rvv2rvs)
    );

  // RT, Retire
    rvv_backend_retire #(
    ) u_retire (
      // ROB to RT
        .rob2rt_write_valid  (rd_valid_rob2rt),
        .rob2rt_write_data   (rd_rob2rt),
        .rob2rt_write_ready  (rd_ready_rt2rob),
      // RT to RVS.XRF
        .rt2xrf_write_valid  (rt_xrf_valid_rvv2rvs),
        .rt2xrf_write_data   (rt_xrf_rvv2rvs),
        .rt2xrf_write_ready  (rt_xrf_ready_rvs2rvv),
      // RT to VRF
        .rt2vrf_write_valid  (wr_valid_rt2vrf),
        .rt2vrf_write_data   (wr_data_rt2vrf),
      // write to update vcsr
        .rt2vcsr_write_valid (vcsr_valid),
        .rt2vcsr_write_data  (vector_csr),
      // update to vxsat
        .rt2vsat_write_valid (wr_vxsat_valid),
        .rt2vsat_write_data  (wr_vxsat)
    );

  // VRF, Vector Register File
    rvv_backend_vrf #(
    ) u_vrf (
      // global signal
        .clk             (clk),
        .rst_n           (rst_n),
      // DP to VRF
        .dp2vrf_rd_index (rd_index_dp2vrf),
      // VRF to DP
        .vrf2dp_rd_data  (rd_data_vrf2dp),
        .vrf2dp_v0_data  (v0_mask_vrf2dp),
      // RT to VRF
        .rt2vrf_wr_valid (wr_valid_rt2vrf),
        .rt2vrf_wr_data  (wr_data_rt2vrf)
    );

  // testbench verification
  `ifdef TB_SUPPORT
    logic [`NUM_RT_UOP-1:0] rt_uop;
    logic [`NUM_RT_UOP-1:0] rt_last_uop;
    generate
      for (i=0; i<`NUM_RT_UOP; i++)
        always_comb begin
          rt_last_uop[i] = rd_valid_rob2rt[i] & rd_ready_rt2rob[i] & rd_rob2rt[i].last_uop_valid;
        end
    endgenerate
    always_comb begin
        rt_uop = rd_valid_rob2rt & rd_ready_rt2rob;
    end

    logic single_inst_mode;
    initial begin
      if($test$plusargs("single_inst_mode"))
        single_inst_mode = 1;
      else 
        single_inst_mode = 0;
    end

    LastUop:`rvv_expect(~single_inst_mode || single_inst_mode & ((rt_last_uop ^ rt_uop) inside {4'b0000,4'b0001,4'b0011,4'b0111,4'b1111}))
      else $error("TB_ISSUE: get not-last uops retired after last uops.");
  `endif
`endif // TB_BRINGUP

endmodule
