`include "rvv.svh"

module RvvBackend
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
	input   logic [`ISSUE_LANE-1:0]             insts_valid_rvs2cq;
	input   INST_t [`ISSUE_LANE-1:0]            insts_rvs2cq;
	output  logic [`ISSUE_LANE-1:0]             insts_ready_cq2rvs;

// load/store unit interface
	// RVV send LSU uop to RVS
	output	logic [`ISSUE_LANE-1:0]             uop_valid;
	output	UOP_LSU_RVV2RVS_t [`ISSUE_LANE-1:0] uop_lsu_rvv2rvs;
	input	logic [`ISSUE_LANE-1:0]             uop_ready;
	// LSU feedback to RVV
	input	logic [`ISSUE_LANE-1:0]             uop_done_valid;
	input	UOP_LSU_RVV2RVS_t [`ISSUE_LANE-1:0]	uop_done_rvs2rvv;
	output	logic [`ISSUE_LANE-1:0]	            uop_done_ready;

// write back to XRF. RVS arbitrates write ports of XRF by itself.
    output  WB_XRF_t [`NUM_WB_UOP-1:0]          wb_xrf_wb2rvs;
    output  logic [`NUM_WB_UOP-1:0]             wb_xrf_valid_wb2rvs;
	input   logic [`NUM_WB_UOP-1:0]             wb_xrf_ready_wb2rvs;

// exception handler
    // trap signal handshake
    input   logic                   			trap_rvs2rvv;
    output  logic                   			ready_rvv2rvs;    
    // the vcsr of last retired uop in last cycle
	output  logic                   			vcsr_valid;
    output  VECTOR_CSR_t            			vector_csr;

endmodule