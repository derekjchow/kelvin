`ifndef RVV_ASSERT_SVH
`define RVV_ASSERT_SVH

// SV2009 feature - default values for arguments
`define rvv_expect(prop) assert property (@(posedge clk) disable iff (~rst_n) prop)
`define rvv_forbid(seq)  assert property (@(posedge clk) disable iff (~rst_n) not (strong(seq)))
`define rvv_cover(seq)   cover  property (@(posedge clk) disable iff (~rst_n) seq)
`define rvv_assume(prop) assume property (@(posedge clk) disable iff (~rst_n) prop)

`endif // RVV_ASSERT_SVH
