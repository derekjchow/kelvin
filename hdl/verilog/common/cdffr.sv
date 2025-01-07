// FF with sync enable, clear and async rst_n; 

module cdffr ( q, clk, rst_n, c, e, d ) ; 
  parameter WIDTH = 1 ;
  parameter INIT  = {WIDTH{1'b0}};
  input         clk ;
  input         rst_n ;
  input         e, c;
  input  [WIDTH-1:0] d ;
  output [WIDTH-1:0] q ;
  reg [WIDTH-1:0]        q ;
  always @(posedge clk or negedge rst_n) 
    if (!rst_n)     q <= INIT ;
    // Updated code to better version for coverage. 
    else if (c) q <= INIT; //solidify {'X(fail d == 0)};
    else if (e) q <= d;
endmodule
