/*
description: 
1. the ROB module receives uop information from Dispatch unit and uop result from Processor Unit (PU).
2. the ROB module provides all status for dispatch unit to foreward operand from ROB.
3. the ROB module send retire request to retire unit.
4. the ROB module receives trap information from LSU and flush buffer(s)

feature list:
1. the ROB can receive 2 uop information form Dispatch unit at most per cycle.
2. the ROB can receive 9 uop result from PU at most per cycle.
    a. However, U-arch of RVV limit the result number from 9 to 8.
3. the ROB can send 4 retire uops to writeback unit at most per cycle.
4. the ROB infomation for dispatch need to be sorted, which depends on program order.
*/

`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif

module rvv_backend_rob
(
    clk,
    rst_n,
    uop_valid_dp2rob,
    uop_dp2rob,
    uop_ready_rob2dp,
    rob_empty,
    uop_index_rob2dp,
    wr_valid_alu2rob,
    wr_alu2rob,
    wr_ready_rob2alu,
    wr_valid_pmtrdt2rob,
    wr_pmtrdt2rob,
    wr_ready_rob2pmtrdt,
    wr_valid_mul2rob,
    wr_mul2rob,
    wr_ready_rob2mul,
    wr_valid_div2rob,
    wr_div2rob,
    wr_ready_rob2div,
    wr_valid_lsu2rob,
    wr_lsu2rob,
    wr_ready_rob2lsu,
    rd_valid_rob2rt,
    rd_rob2rt,
    rd_ready_rt2rob,
    uop_rob2dp,
    trap_valid_rmp2rob,
    trap_rob_entry_rmp2rob,
    trap_ready_rob2rmp,
    trap_ready_rvv2rvs,
    trap_flush_rvv
);  
// global signal
    input   logic                   clk;
    input   logic                   rst_n;

// push uop infomation to ROB
// Dispatch to ROB
    input   logic     [`NUM_DP_UOP-1:0] uop_valid_dp2rob;
    input   DP2ROB_t  [`NUM_DP_UOP-1:0] uop_dp2rob;
    output  logic     [`NUM_DP_UOP-1:0] uop_ready_rob2dp;
    output  logic                       rob_empty;
    output  logic     [`ROB_DEPTH_WIDTH-1:0] uop_index_rob2dp;

// push uop result to ROB
// ALU to ROB
    input   logic     [`NUM_ALU-1:0]    wr_valid_alu2rob;
    input   PU2ROB_t  [`NUM_ALU-1:0]    wr_alu2rob;
    output  logic     [`NUM_ALU-1:0]    wr_ready_rob2alu;

// PMT+RED to ROB
    input   logic     [`NUM_PMTRDT-1:0] wr_valid_pmtrdt2rob;
    input   PU2ROB_t  [`NUM_PMTRDT-1:0] wr_pmtrdt2rob;
    output  logic     [`NUM_PMTRDT-1:0] wr_ready_rob2pmtrdt;

// MUL to ROB
    input   logic     [`NUM_MUL-1:0]    wr_valid_mul2rob;
    input   PU2ROB_t  [`NUM_MUL-1:0]    wr_mul2rob;
    output  logic     [`NUM_MUL-1:0]    wr_ready_rob2mul;

// DIV to ROB
    input   logic     [`NUM_DIV-1:0]    wr_valid_div2rob;
    input   PU2ROB_t  [`NUM_DIV-1:0]    wr_div2rob;
    output  logic     [`NUM_DIV-1:0]    wr_ready_rob2div;

// LSU to ROB
    input   logic     [`NUM_LSU-1:0]    wr_valid_lsu2rob;
    input   PU2ROB_t  [`NUM_LSU-1:0]    wr_lsu2rob;
    output  logic     [`NUM_LSU-1:0]    wr_ready_rob2lsu;

// retire uops
// pop vd_data from ROB and write to VRF
    output  logic     [`NUM_RT_UOP-1:0] rd_valid_rob2rt;
    output  ROB2RT_t  [`NUM_RT_UOP-1:0] rd_rob2rt;
    input   logic     [`NUM_RT_UOP-1:0] rd_ready_rt2rob;

// bypass all rob entries to Dispatch unit
// rob_entries must be in program order instead of entry_index
    output  ROB2DP_t  [`ROB_DEPTH-1:0]  uop_rob2dp;

// trap signal handshake
    input   logic                           trap_valid_rmp2rob;
    input   logic   [`ROB_DEPTH_WIDTH-1:0]  trap_rob_entry_rmp2rob;
    output  logic                           trap_ready_rob2rmp;
    output  logic                           trap_ready_rvv2rvs;
    output  logic                           trap_flush_rvv;

// ---internal signal definition--------------------------------------
  // Uop info
    DP2ROB_t  [`NUM_RT_UOP-1:0]         uop_rob2rt;
    logic     [`NUM_RT_UOP-1:0]         uop_valid_rob2rt;
    DP2ROB_t  [`ROB_DEPTH-1:0]          uop_info;
    logic     [`ROB_DEPTH-1:0]          entry_valid;

    logic     [`ROB_DEPTH_WIDTH-1:0]    uop_wptr;
    logic     [`ROB_DEPTH_WIDTH-1:0]    uop_rptr;
    logic                               uop_info_fifo_full;
    logic     [`NUM_DP_UOP-1:0]         uop_info_fifo_almost_full;

  // Uop result
    RES_ROB_t [`ROB_DEPTH-1:0]          res_mem;
    logic     [`ROB_DEPTH-1:0]          uop_done;

  // trap
    logic     [`ROB_DEPTH-1:0]          trap_flag;

  // retire uops
    logic     [`NUM_RT_UOP-1:0]         uop_retire_valid;

  // temp signal
    logic     [`ROB_DEPTH_WIDTH-1:0]    wind_uop_wptr [`ROB_DEPTH-1:0];
    logic     [`ROB_DEPTH_WIDTH-1:0]    wind_uop_rptr [`ROB_DEPTH-1:0];

    genvar                              i,j;
// ---code start------------------------------------------------------
  // Uop info FIFO
    multi_fifo #(
        .T            (DP2ROB_t),
        .M            (`NUM_DP_UOP),
        .N            (`NUM_RT_UOP),
        .DEPTH        (`ROB_DEPTH),
        .CHAOS_PUSH   (1'b1)
    ) u_uop_info_fifo (
      // global
        .clk          (clk),
        .rst_n        (rst_n),
      // push side
        .push         (uop_valid_dp2rob & uop_ready_rob2dp),
        .datain       (uop_dp2rob),
        .full         (uop_info_fifo_full),
        .almost_full  (uop_info_fifo_almost_full),
      // pop side
        .pop          (rd_valid_rob2rt & rd_ready_rt2rob),
        .dataout      (uop_rob2rt),
        .empty        (rob_empty),
        .almost_empty (),
      // fifo info
        .clear        (trap_flush_rvv),
        .fifo_data    (uop_info),
        .wptr         (uop_wptr),
        .rptr         (uop_rptr),
        .entry_count  ()
    );

    assign uop_index_rob2dp = uop_wptr;
    assign uop_ready_rob2dp[0] = ~uop_info_fifo_full;
    generate
        for (i=1; i<`NUM_DP_UOP; i++) begin : gen_ready_rob2dp
            assign uop_ready_rob2dp[i] = ~uop_info_fifo_almost_full[i];
        end
    endgenerate

  // entry valid
  // set if DP push uop into ROB
  // clear if RT pop uop from ROB
  // reset once flush ROB
    multi_fifo #(
        .T            (logic),
        .M            (`NUM_DP_UOP),
        .N            (`NUM_RT_UOP),
        .DEPTH        (`ROB_DEPTH),
        .POP_CLEAR    (1'b1),
        .ASYNC_RSTN   (1'b1),
        .CHAOS_PUSH   (1'b1)
    ) u_uop_valid_fifo (
      // global
        .clk          (clk),
        .rst_n        (rst_n),
      // push side
        .push         (uop_valid_dp2rob & uop_ready_rob2dp),
        .datain       (uop_valid_dp2rob),
        .full         (),
        .almost_full  (),
      // pop side
        .pop          (rd_valid_rob2rt & rd_ready_rt2rob),
        .dataout      (uop_valid_rob2rt),
        .empty        (),
        .almost_empty (),
      // fifo info
        .clear        (trap_flush_rvv),
        .fifo_data    (entry_valid),
        .wptr         (),
        .rptr         (),
        .entry_count  ()
    );

  // update PU result to result memory
    always_ff @(posedge clk) begin
        for (int k=0; k<`NUM_ALU; k++) begin
            if (wr_valid_alu2rob[k] && wr_ready_rob2alu[k]) begin
`ifdef TB_SUPPORT
                res_mem[wr_alu2rob[k].rob_entry].uop_pc <= wr_alu2rob[k].uop_pc;
`endif                
                res_mem[wr_alu2rob[k].rob_entry].w_valid <= wr_alu2rob[k].w_valid;
                res_mem[wr_alu2rob[k].rob_entry].w_data  <= wr_alu2rob[k].w_data;
                res_mem[wr_alu2rob[k].rob_entry].vsaturate <= wr_alu2rob[k].vsaturate;
            end
        end
        for (int k=0; k<`NUM_PMTRDT; k++) begin
            if (wr_valid_pmtrdt2rob[k] && wr_ready_rob2pmtrdt[k]) begin
`ifdef TB_SUPPORT
                res_mem[wr_pmtrdt2rob[k].rob_entry].uop_pc <= wr_pmtrdt2rob[k].uop_pc;
`endif                
                res_mem[wr_pmtrdt2rob[k].rob_entry].w_valid <= wr_pmtrdt2rob[k].w_valid;
                res_mem[wr_pmtrdt2rob[k].rob_entry].w_data  <= wr_pmtrdt2rob[k].w_data;
                res_mem[wr_pmtrdt2rob[k].rob_entry].vsaturate <= wr_pmtrdt2rob[k].vsaturate;
            end
        end
        for (int k=0; k<`NUM_MUL; k++) begin
            if (wr_valid_mul2rob[k] && wr_ready_rob2mul[k]) begin
`ifdef TB_SUPPORT
                res_mem[wr_mul2rob[k].rob_entry].uop_pc  <= wr_mul2rob[k].uop_pc;
`endif                
                res_mem[wr_mul2rob[k].rob_entry].w_valid <= wr_mul2rob[k].w_valid;
                res_mem[wr_mul2rob[k].rob_entry].w_data  <= wr_mul2rob[k].w_data;
                res_mem[wr_mul2rob[k].rob_entry].vsaturate <= wr_mul2rob[k].vsaturate;
            end
        end
        for (int k=0; k<`NUM_DIV; k++) begin
            if (wr_valid_div2rob[k] && wr_ready_rob2div[k]) begin
`ifdef TB_SUPPORT
                res_mem[wr_div2rob[k].rob_entry].uop_pc  <= wr_div2rob[k].uop_pc;
`endif                
                res_mem[wr_div2rob[k].rob_entry].w_valid <= wr_div2rob[k].w_valid;
                res_mem[wr_div2rob[k].rob_entry].w_data  <= wr_div2rob[k].w_data;
                res_mem[wr_div2rob[k].rob_entry].vsaturate <= wr_div2rob[k].vsaturate;
            end
        end
        for (int k=0; k<`NUM_LSU; k++) begin
            if (wr_valid_lsu2rob[k] && wr_ready_rob2lsu[k]) begin
`ifdef TB_SUPPORT
                res_mem[wr_lsu2rob[k].rob_entry].uop_pc  <= wr_lsu2rob[k].uop_pc;
`endif                
                res_mem[wr_lsu2rob[k].rob_entry].w_valid <= wr_lsu2rob[k].w_valid;
                res_mem[wr_lsu2rob[k].rob_entry].w_data  <= wr_lsu2rob[k].w_data;
                res_mem[wr_lsu2rob[k].rob_entry].vsaturate <= wr_lsu2rob[k].vsaturate;
            end
        end
    end
    
    // readys for PUs are always 1
    generate
        for (i=0; i<`NUM_ALU; i++) assign wr_ready_rob2alu[i] = 1'b1;
        for (i=0; i<`NUM_PMTRDT; i++) assign wr_ready_rob2pmtrdt[i] = 1'b1;
        for (i=0; i<`NUM_MUL; i++) assign wr_ready_rob2mul[i] = 1'b1;
        for (i=0; i<`NUM_DIV; i++) assign wr_ready_rob2div[i] = 1'b1;
        for (i=0; i<`NUM_LSU; i++) assign wr_ready_rob2lsu[i] = 1'b1;
    endgenerate

  // uop done
  // set if PU update uop result
  // clear if RT pop uop reuslt from ROB
  // reset once flush ROB.

  // wind back pointer
     generate
         for (i=0; i<`ROB_DEPTH; i++) assign wind_uop_rptr[i] = uop_rptr+i;
         for (i=0; i<`ROB_DEPTH; i++) assign wind_uop_wptr[i] = uop_wptr+i;
     endgenerate
    
     always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            uop_done <= '0;
        else if (trap_flush_rvv)
            uop_done <= '0;
        else begin
            for (int k=0; k<`NUM_RT_UOP; k++) begin
                if (rd_valid_rob2rt[k] && rd_ready_rt2rob[k])
                    uop_done[wind_uop_rptr[k]] <= 1'b0;
            end
            for (int k=0; k<`NUM_ALU; k++) begin
                if (wr_valid_alu2rob[k] && wr_ready_rob2alu[k])
                    uop_done[wr_alu2rob[k].rob_entry] <= 1'b1;
            end
            for (int k=0; k<`NUM_PMTRDT; k++) begin
                if (wr_valid_pmtrdt2rob[k] && wr_ready_rob2pmtrdt[k])
                    uop_done[wr_pmtrdt2rob[k].rob_entry] <= 1'b1;
            end
            for (int k=0; k<`NUM_MUL; k++) begin
                if (wr_valid_mul2rob[k] && wr_ready_rob2mul[k])
                    uop_done[wr_mul2rob[k].rob_entry] <= 1'b1;
            end
            for (int k=0; k<`NUM_DIV; k++) begin
                if (wr_valid_div2rob[k] && wr_ready_rob2div[k])
                    uop_done[wr_div2rob[k].rob_entry] <= 1'b1;
            end
            for (int k=0; k<`NUM_LSU; k++) begin
                if (wr_valid_lsu2rob[k] && wr_ready_rob2lsu[k])
                    uop_done[wr_lsu2rob[k].rob_entry] <= 1'b1;
            end
        end
    end

  `ifdef ASSERT_ON 
    logic [`ROB_DEPTH-1:0][`NUM_PU-1:0] res_sel; // one hot code for each entry
    generate
        for (i=0; i<`ROB_DEPTH; i++) begin
            for (j=0; j<`NUM_ALU; j++)    
                assign res_sel[i][j]                                        = wr_valid_alu2rob[j]    && wr_ready_rob2alu[j]    && (wr_alu2rob[j].rob_entry == i);
            for (j=0; j<`NUM_PMTRDT; j++) 
                assign res_sel[i][j+`NUM_ALU]                               = wr_valid_pmtrdt2rob[j] && wr_ready_rob2pmtrdt[j] && (wr_pmtrdt2rob[j].rob_entry == i);
            for (j=0; j<`NUM_MUL; j++)    
                assign res_sel[i][j+`NUM_PMTRDT+`NUM_ALU]                   = wr_valid_mul2rob[j]    && wr_ready_rob2mul[j]    && (wr_mul2rob[j].rob_entry == i);
            for (j=0; j<`NUM_DIV; j++)    
                assign res_sel[i][j+`NUM_MUL+`NUM_PMTRDT+`NUM_ALU]          = wr_valid_div2rob[j]    && wr_ready_rob2div[j]    && (wr_div2rob[j].rob_entry == i);
            for (j=0; j<`NUM_LSU; j++)    
                assign res_sel[i][j+`NUM_DIV+`NUM_MUL+`NUM_PMTRDT+`NUM_ALU] = wr_valid_lsu2rob[j]    && wr_ready_rob2lsu[j]    && (wr_lsu2rob[j].rob_entry == i);

            `rvv_expect($onehot0(res_sel[i])) else $error("ROB: Multiple PU results write same entry: index %d, PU %d\n", i, $sampled(res_sel[i]));
        end
    endgenerate
  `endif

  // trap flag
  // write trap to ROB when trap occurs
  // flush all fifo when the uop triggering trap is the oldest uop in ROB
  always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n)
          trap_flag <= '0;
      else if (trap_flush_rvv)
          trap_flag <= '0;
      else if (trap_valid_rmp2rob & trap_ready_rob2rmp)
          trap_flag[trap_rob_entry_rmp2rob] <= 1'b1;
  end

  // trap ready is always 1
  assign trap_ready_rob2rmp = 1'b1;

  // retire uop(s)
  generate
      for (i=0; i<`NUM_RT_UOP; i++) begin : gen_rob2rt
        // retire_uop valid
          if (i==0) begin
            assign uop_retire_valid[0] = uop_valid_rob2rt[0] & (uop_done[wind_uop_rptr[0]]|trap_flag[wind_uop_rptr[i]]);
            assign rd_valid_rob2rt[0] = rd_ready_rt2rob[0] && uop_retire_valid[0];
          end
          else begin
            assign uop_retire_valid[i] = uop_valid_rob2rt[i] & uop_done[wind_uop_rptr[i]];
            assign rd_valid_rob2rt[i] = rd_ready_rt2rob[i] && uop_retire_valid[i] && rd_valid_rob2rt[i-1] && ~trap_flag[wind_uop_rptr[i]-1'b1];
          end

        // retire_uop data
`ifdef TB_SUPPORT          
          assign rd_rob2rt[i].uop_pc  = uop_rob2rt[i].uop_pc;
          assign rd_rob2rt[i].last_uop_valid = uop_rob2rt[i].last_uop_valid;
`endif          
          assign rd_rob2rt[i].w_valid = res_mem[wind_uop_rptr[i]].w_valid & uop_done[wind_uop_rptr[i]];
          assign rd_rob2rt[i].w_index = uop_rob2rt[i].w_index;
          assign rd_rob2rt[i].w_data  = res_mem[wind_uop_rptr[i]].w_data;
          assign rd_rob2rt[i].w_type  = uop_rob2rt[i].w_type;
          assign rd_rob2rt[i].vd_type = uop_rob2rt[i].byte_type;
          assign rd_rob2rt[i].trap_flag = trap_flag[wind_uop_rptr[i]];
          assign rd_rob2rt[i].vector_csr = uop_rob2rt[i].vector_csr;
          assign rd_rob2rt[i].vxsaturate = res_mem[wind_uop_rptr[i]].vsaturate;
      end
  endgenerate
  
  // trap handle ready and flush signal
  assign trap_ready_rvv2rvs = rd_rob2rt[0].trap_flag & rd_ready_rt2rob[0] & uop_retire_valid[0];
  assign trap_flush_rvv = trap_ready_rvv2rvs;

  // bypass ROB info to Dispatch
  generate
      for (i=0; i<`ROB_DEPTH; i++) begin : gen_rob2dp
`ifdef TB_SUPPORT
          assign uop_rob2dp[i].uop_pc  = uop_info[i].uop_pc;
`endif
          assign uop_rob2dp[i].valid   = entry_valid[i];
          assign uop_rob2dp[i].w_valid = res_mem[wind_uop_rptr[i]].w_valid & uop_done[wind_uop_rptr[i]];
          assign uop_rob2dp[i].w_index = uop_info[i].w_index;
          assign uop_rob2dp[i].w_type  = uop_info[i].w_type;
          assign uop_rob2dp[i].w_data  = res_mem[wind_uop_rptr[i]].w_data;
          assign uop_rob2dp[i].byte_type = uop_info[i].byte_type;
          assign uop_rob2dp[i].vector_csr = uop_info[i].vector_csr;
      end
  endgenerate
  
endmodule
