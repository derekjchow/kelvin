module rvv_backend_alu_unit_mask_viota64
(
  source,
  result_viota64
);
  input  logic  [63:0]                source;
  output logic  [63:0][$clog2(64):0]  result_viota64;

  logic [3:0][15:0][$clog2(16):0]     result_viota16;
  logic [15:0][$clog2(16):0]          sum_3_2;
  logic [15:0][$clog2(16):0]          carry_3_2;
  logic [15:0][$clog2(16):0]          sum_4_2;
  logic [15:0][$clog2(16):0]          carry_4_2;
  logic [15:0][$clog2(16):0]          cout_4_2;

  genvar                              j;
  
  // calculate
  generate
    for(j=0;j<4;j++) begin: GET_VIOTA16
      rvv_backend_alu_unit_mask_viota16
      u_viota16
      (
        .source         (source[16*j +: 16]),
        .result_viota16 (result_viota16[j])
      );
    end
    
    for(j=0;j<16;j++) begin: GET_VIOTA64
      assign result_viota64[j] = result_viota16[0][j];
      assign result_viota64[j+16] = result_viota16[1][j]+result_viota16[0][15];
      assign result_viota64[j+32] = sum_3_2[j]+{carry_3_2[j],1'b0};
      assign result_viota64[j+48] = sum_4_2[j]+{({1'b0,carry_4_2[j]}+{1'b0,cout_4_2[j]}),1'b0};
    end

    for(j=0;j<16;j++) begin: GET_VIOTA64_CPRS_3_2
      compressor_3_2
      #(
        .WIDTH  ($clog2(16)+1)
      )
      viota64_cprs_3_2
      (
        .src1         (result_viota16[0][15]),
        .src2         (result_viota16[1][15]),
        .src3         (result_viota16[2][j]),
        .result_sum   (sum_3_2[j]),
        .result_carry (carry_3_2[j])
      );
    end

    for(j=0;j<16;j++) begin: GET_VIOTA64_CPRS_4_2
      compressor_4_2
      #(
        .WIDTH  ($clog2(16)+1)
      )
      viota64_cprs_4_2
      (
        .src1         (result_viota16[0][15]),
        .src2         (result_viota16[1][15]),
        .src3         (result_viota16[2][15]),
        .src4         (result_viota16[3][j]),
        .cin          ('0),
        .result_sum   (sum_4_2[j]),
        .result_carry (carry_4_2[j]),
        .result_cout  (cout_4_2[j])
      );
    end
  endgenerate

endmodule
