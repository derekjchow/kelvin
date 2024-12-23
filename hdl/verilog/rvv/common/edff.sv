// edff - posedge ff, async rst_n, sync enable.

module edff (q, en, d, clk, rst_n
`ifdef TB_SUPPORT
  ,init_data
`endif
);
  parameter WIDTH = 1;
  parameter INIT  = '0;

  output logic [WIDTH-1:0] q;

  input  logic             en;
  input  logic [WIDTH-1:0] d;
  input  logic             clk;
  input  logic             rst_n;

`ifdef TB_SUPPORT
  input  logic [WIDTH-1:0] init_data;
`endif

  always @(posedge clk or negedge rst_n)
`ifdef TB_SUPPORT
    if (!rst_n)   q <= init_data;
`else
    if (!rst_n)   q <= INIT;
`endif
    else if (en)  q <= d;

endmodule
