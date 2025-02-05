module rvv_backend_alu_unit_mask_viota16
(
  source,
  result_viota16
);
  input  logic  [15:0]                source;
  output logic  [15:0][$clog2(16):0]  result_viota16;

  logic [3:0][3:0][$clog2(4):0]       result_viota4;
  logic [3:0][$clog2(4):0]            sum_3_2;
  logic [3:0][$clog2(4):0]            carry_3_2;
  logic [3:0][$clog2(4):0]            sum_4_2;
  logic [3:0][$clog2(4):0]            carry_4_2;
  logic [3:0][$clog2(4):0]            cout_4_2;

  genvar                              j;
  
  // calculate
  generate
    for(j=0;j<4;j++) begin: GET_VIOTA4
      assign result_viota4[j] = f_viota4(source[4*j +: 4]);
    end

    for(j=0;j<4;j++) begin: GET_VIOTA16
      assign result_viota16[j] = result_viota4[0][j];
      assign result_viota16[j+4] = result_viota4[1][j]+result_viota4[0][3];
      assign result_viota16[j+8] = sum_3_2[j]+{carry_3_2[j],1'b0};
      assign result_viota16[j+12] = sum_4_2[j]+{({1'b0,carry_4_2[j]}+{1'b0,cout_4_2[j]}),1'b0};
    end

    for(j=0;j<4;j++) begin: GET_VIOTA16_CPRS_3_2
      compressor_3_2
      #(
        .WIDTH  ($clog2(4)+1)
      )
      viota16_cprs_3_2
      (
        .src1         (result_viota4[0][3]),
        .src2         (result_viota4[1][3]),
        .src3         (result_viota4[2][j]),
        .result_sum   (sum_3_2[j]),
        .result_carry (carry_3_2[j])
      );
    end

    for(j=0;j<4;j++) begin: GET_VIOTA16_CPRS_4_2
      compressor_4_2
      #(
        .WIDTH  ($clog2(4)+1)
      )
      viota16_cprs_4_2
      (
        .src1         (result_viota4[0][3]),
        .src2         (result_viota4[1][3]),
        .src3         (result_viota4[2][3]),
        .src4         (result_viota4[3][j]),
        .cin          ('0),
        .result_sum   (sum_4_2[j]),
        .result_carry (carry_4_2[j]),
        .result_cout  (cout_4_2[j])
      );
    end
  endgenerate

// 
// function
//
  // calculate viota4 by mux
  function [3:0][$clog2(4):0] f_viota4;
    input logic [3:0] src;
    
    case(src[0])
      1'b0: begin
        f_viota4[0] = 3'd0;
      end
      1'b1: begin
        f_viota4[0] = 3'd1;
      end
      default: begin
        f_viota4[0] = 3'd0;
      end
    endcase

    case(src[1:0])
      2'b00: begin
        f_viota4[1] = 3'd0;
      end
      2'b01,
      2'b10: begin
        f_viota4[1] = 3'd1;
      end
      2'b11: begin
        f_viota4[1] = 3'd2;
      end
      default: begin
        f_viota4[1] = 3'd0;
      end
    endcase

    case(src[2:0])
      3'b000: begin
        f_viota4[2] = 3'd0;
      end
      3'b001,
      3'b010,
      3'b100: begin
        f_viota4[2] = 3'd1;
      end
      3'b011,
      3'b101,
      3'b110: begin
        f_viota4[2] = 3'd2;
      end
      3'b111: begin
        f_viota4[2] = 3'd3;
      end
      default: begin
        f_viota4[2] = 3'd0;
      end
    endcase

    case(src)
      4'b0000: begin
        f_viota4[3] = 3'd0;
      end
      4'b0001,
      4'b0010,
      4'b0100,
      4'b1000: begin
        f_viota4[3] = 3'd1;
      end
      4'b0011,
      4'b0101,
      4'b1001,
      4'b0110,
      4'b1010,
      4'b1100: begin
        f_viota4[3] = 3'd2;
      end
      4'b0111,
      4'b1011,
      4'b1101,
      4'b1110: begin
        f_viota4[3] = 3'd3;
      end
      4'b1111: begin
        f_viota4[3] = 3'd4;
      end
      default: begin
        f_viota4[3] = 3'd0;
      end
    endcase

  endfunction

endmodule
