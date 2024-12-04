`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv.svh"
`endif

module RvvBackend
(
// global signal
	input logic									clk,
	input logic									rstn,

// vector instruction and scalar operand input. 
	input   logic           					insts_valid_rvs2cq[`NUM_DP_UOP-1:0],
	input   INST_t          					insts_rvs2cq[`NUM_DP_UOP-1:0],
	output  logic           					insts_ready_cq2rvs[`NUM_DP_UOP-1:0],

// load/store unit interface
	// RVV send LSU uop to RVS
	output	logic								uop_valid[`NUM_DP_UOP-1:0],
	output	UOP_LSU_RVV2RVS_t					uop_lsu_rvv2rvs[`NUM_DP_UOP-1:0],
	input	logic								uop_ready[`NUM_DP_UOP-1:0],
	// LSU feedback to RVV
	input	logic								uop_done_valid[`NUM_DP_UOP-1:0],
	input	UOP_LSU_RVV2RVS_t					uop_done_rvs2rvv[`NUM_DP_UOP-1:0],
	output	logic								uop_done_ready[`NUM_DP_UOP-1:0],

// write back to XRF. RVS arbitrates write ports of XRF by itself.
    output  WB_XRF_t                			wb_xrf_wb2rvs[`NUM_WB_UOP-1:0],
    output  logic                   			wb_xrf_valid_wb2rvs[`NUM_WB_UOP-1:0],
	input   logic                   			wb_xrf_ready_wb2rvs[`NUM_WB_UOP-1:0],

// exception handler
    // trap signal handshake
    input   logic                   			trap_rvs2rvv,
    output  logic                   			ready_rvv2rvs,
    // the vcsr of last retired uop in last cycle
	output  logic                   			vcsr_valid,
    output  VECTOR_CSR_t            			vector_csr
);

  // Tie-off for the time being
  always_comb begin
	for (int i = 0; i < `NUM_DP_UOP; i++) begin
	  insts_ready_cq2rvs[i] = 0;
	  uop_valid[i] = 0;
	  uop_lsu_rvv2rvs[i] = 0;
	  uop_done_ready[i] = 0;
	end

	for (int i = 0; i < `NUM_WB_UOP; i++) begin
	  wb_xrf_wb2rvs[i] = 0;
	  wb_xrf_valid_wb2rvs[i] = 0;
	end

	ready_rvv2rvs = 0;
	vcsr_valid = 0;
    vector_csr.vstart = 0;
    vector_csr.vl = 0;
    vector_csr.vtype.vill = 0;
    vector_csr.vtype.vma = 0;
    vector_csr.vtype.vta = 0;
    vector_csr.vtype.vsew = 0;
    vector_csr.vtype.vlmul = 0;
    vector_csr.vcsr.vxrm = 0;
    vector_csr.vcsr.vxsat = 0;
  end

  always @(posedge clk) begin
    if (insts_valid_rvs2cq[0]) begin
	//   $fwrite(32'h80000002, "Got RVV command!\n");
    //   $error("Got RVV command!\n");
    end
  end
endmodule