module ClockGate(
  input         clk_i,
  input         enable,  // '1' passthrough, '0' disable.
  output        clk_o
);

`ifndef CLOCKGATE_ENABLE

assign clk_o = clk_i;

`else

reg clk_en;

// Capture 'enable' during low phase of the clock.
always_latch begin
  if (~clk_i) begin
    clk_en <= enable;
  end
end

assign clk_o = clk_i & clk_en;

`endif

endmodule  // ClockGate
