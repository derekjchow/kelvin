// edff - posedge ff, async rst_n, sync enable.

module edff (q, en, d, clk, rst_n
);
  parameter WIDTH = 1;
  parameter INIT  = '0;

  output logic [WIDTH-1:0] q;

  input  logic             en;
  input  logic [WIDTH-1:0] d;
  input  logic             clk;
  input  logic             rst_n;

  always @(posedge clk or negedge rst_n)
    if (!rst_n)   q <= INIT;
    else if (en)  q <= d;

endmodule
