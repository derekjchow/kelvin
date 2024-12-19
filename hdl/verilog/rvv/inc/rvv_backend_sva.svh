`ifndef RVV_ASSERT__SVH
`define RVV_ASSERT__SVH

`define RVV_ASSERT_CLK  rvv_backend.clk
`define RVV_ASSERT_RSTN rvv_backend.rst_n
// SV2009 feature - default values for arguments
`define rvv_expect(prop) assert property (@(posedge `RVV_ASSERT_CLK) disable iff (~`RVV_ASSERT_RSTN) prop)
`define rvv_forbid(seq)  assert property (@(posedge `RVV_ASSERT_CLK) disable iff (~`RVV_ASSERT_RSTN) not (strong(seq)))
`define rvv_cover(seq)   cover  property (@(posedge `RVV_ASSERT_CLK) disable iff (~`RVV_ASSERT_RSTN) seq)
`define rvv_assume(prop) assume property (@(posedge `RVV_ASSERT_CLK) disable iff (~`RVV_ASSERT_RSTN) prop)

`endif // RVV_ASSERT_SVH
