//   EDFFR  - posedge ff w/ rst_n w/ en,
//   Order of ports is:  q, clk, [rst_n], [e], d
//   E.g.  EDFF #(4) qsig (qsig, clk, rst_n, ena, dsig);

module EDFFR ( q, clk, rst_n, e, d ) ; // FF with sync enable and async rst_n;  
  parameter WIDTH = 1 ;
  parameter INIT  = {WIDTH{1'b0}} ;
  input 	clk ;
  input 	rst_n ;
  input 	e ;
  input  [WIDTH-1:0] d ;
  output [WIDTH-1:0] q ;
  reg [WIDTH-1:0] 	 q ;
  always @(posedge clk or negedge rst_n) 
    if (!rst_n)    q <= INIT ;
    else if (e) q <= d ;
endmodule
