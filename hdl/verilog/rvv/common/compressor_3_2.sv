module compressor_3_2
(
  src1,
  src2,
  src3,
  result_sum,
  result_carry
);
  parameter WIDTH = 8;
  
  input   logic [WIDTH-1:0]   src1;
  input   logic [WIDTH-1:0]   src2;
  input   logic [WIDTH-1:0]   src3;
  output  logic [WIDTH-1:0]   result_sum;
  output  logic [WIDTH-1:0]   result_carry;

  logic [WIDTH-1:0]           xor_src1to2;
  genvar                      i;
  
  assign xor_src1to2 = src1^src2;
  assign result_sum = xor_src1to2^src3;
  
  generate
    for(i=0;i<WIDTH;i++) begin: GET_RESULT
      assign result_carry[i] = xor_src1to2[i] ? src3[i] : src1[i];
    end
  endgenerate

endmodule
