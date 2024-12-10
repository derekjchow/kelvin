//   DFFR   - posedge ff w/ rst_n,
//   Order of ports is:  q, clk, [rst_n], [e], d
//   E.g.  DFF #(4) qsig (qsig, clk, rst_n, dsig);

module dff ( q, clk, rst_n, d ) ; // FF with async rst_n;  
  parameter WIDTH = 1 ;
  input 	clk ;
  input 	rst_n ;
  input  [WIDTH-1:0] d ;
  output [WIDTH-1:0] q ;
  reg [WIDTH-1:0] 	 q ;
  
  always @(posedge clk or negedge rst_n) 
    if (!rst_n) q <= {WIDTH{1'b0}} ;
    else q <= d ;
endmodule
