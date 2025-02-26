// FF with sync enable, clear and async rst_n; 

module cdffr ( q, clk, rst_n, c, e, d ) ; 
  parameter type T = logic;
  parameter T INIT  = '0;
  input         clk;
  input         rst_n;
  input         e, c;
  input  T      d;
  output T      q;
  always @(posedge clk or negedge rst_n) 
    if (!rst_n)     q <= INIT ;
    // Updated code to better version for coverage. 
    else if (c) q <= INIT; //solidify {'X(fail d == 0)};
    else if (e) q <= d;
endmodule
