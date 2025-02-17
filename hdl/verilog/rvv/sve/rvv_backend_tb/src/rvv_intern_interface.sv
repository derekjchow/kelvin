`ifndef RVV_INTERN_INTERFACE__SV
`define RVV_INTERN_INTERFACE__SV
interface rvv_intern_interface (input bit clk, input bit rst_n);
// This interface will connect to RVV internal signals to collect coverage.

// ROB to Retire
  logic    [`NUM_RT_UOP-1:0]  rob2rt_write_valid;
  ROB2RT_t [`NUM_RT_UOP-1:0]  rob2rt_write_data;
  logic    [`NUM_RT_UOP-1:0]  rt2rob_write_ready;

endinterface: rvv_intern_interface
`endif // RVV_INTERN_INTERFACE__SV
