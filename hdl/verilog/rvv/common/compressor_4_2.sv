module compressor_4_2
(
  src1,
  src2,
  src3,
  src4,
  cin,
  result_sum,
  result_carry,
  result_cout
);
  parameter WIDTH = 8;
  
  input   logic [WIDTH-1:0]   src1;
  input   logic [WIDTH-1:0]   src2;
  input   logic [WIDTH-1:0]   src3;
  input   logic [WIDTH-1:0]   src4;
  input   logic [WIDTH-1:0]   cin;
  output  logic [WIDTH-1:0]   result_sum;
  output  logic [WIDTH-1:0]   result_carry;
  output  logic [WIDTH-1:0]   result_cout;

  logic [WIDTH-1:0]           xor_src1to2;
  logic [WIDTH-1:0]           xor_src3to4;
  logic [WIDTH-1:0]           xor_src1to4;
  genvar                      i;
  
  assign xor_src1to2 = src1^src2;
  assign xor_src3to4 = src3^src4;
  
  generate
    for(i=0;i<WIDTH;i++) begin: GET_RESULT
      assign xor_src1to4[i] = xor_src3to4[i] ? ~xor_src1to2[i] : xor_src1to2[i];
      assign result_sum[i] = xor_src1to4[i] ? ~cin[i] : cin[i];
      assign result_cout[i] = xor_src1to2[i] ? src3[i] : src1[i];
      assign result_carry[i] = xor_src1to4[i] ? cin[i] : src4[i];
    end
  endgenerate
  
endmodule
