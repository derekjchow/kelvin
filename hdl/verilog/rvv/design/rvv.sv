`include "rvv.svh"

module rvv
(
	clk,
	rstn,

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
	input logic									clk;
	input logic									rstn;

// vector instruction and scalar operand input. 
	input   logic           					insts_valid_rvs2cq[`NUM_DP_UOP-1:0];
	input   INST_t          					insts_rvs2cq[`NUM_DP_UOP-1:0];
	output  logic           					insts_ready_cq2rvs[`NUM_DP_UOP-1:0];	

// load/store unit interface
	// RVV send LSU uop to RVS
	output	logic								uop_valid[`NUM_DP_UOP-1:0];
	output	UOP_LSU_RVV2RVS_t					uop_lsu_rvv2rvs[`NUM_DP_UOP-1:0];
	input	logic								uop_ready[`NUM_DP_UOP-1:0];
	// LSU feedback to RVV
	input	logic								uop_done_valid[`NUM_DP_UOP-1:0];
	input	UOP_LSU_RVV2RVS_t					uop_done_rvs2rvv[`NUM_DP_UOP-1:0];
	output	logic								uop_done_ready[`NUM_DP_UOP-1:0];

// write back to XRF. RVS arbitrates write ports of XRF by itself.
    output  WB_XRF_t                			wb_xrf_wb2rvs[`NUM_WB_UOP-1:0];
    output  logic                   			wb_xrf_valid_wb2rvs[`NUM_WB_UOP-1:0];
	input   logic                   			wb_xrf_ready_wb2rvs[`NUM_WB_UOP-1:0];

// exception handler
    // trap signal handshake
    input   logic                   			trap_rvs2rvv;
    output  logic                   			ready_rvv2rvs;    
    // the vcsr of last retired uop in last cycle
	output  logic                   			vcsr_valid;
    output  VECTOR_CSR_t            			vector_csr;

endmodule