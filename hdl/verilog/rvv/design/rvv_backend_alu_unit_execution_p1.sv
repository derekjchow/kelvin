
`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif

module rvv_backend_alu_unit_execution_p1
(
  alu_uop_valid,
  alu_uop,
  result
);
//
// interface signals
//
  input   logic           alu_uop_valid;
  input   PIPE_DATA_t     alu_uop;
  output  PU2ROB_t        result;

  // internal signals
  logic   [`XLEN-1:0]                               result_data_vcpop;
  logic   [`VLEN-1:0][$clog2(`VLEN):0]              result_data_viota;
  logic   [`VLENB-1:0][$clog2(`VLEN):0]             result_data_viota8;
  logic   [`VLEN/`HWORD_WIDTH-1:0][$clog2(`VLEN):0] result_data_viota16;
  logic   [`VLEN/`WORD_WIDTH-1:0][$clog2(`VLEN):0]  result_data_viota32;

  genvar                  j;

  // calculate viota and vcpop 
  generate
    if(`VLEN==128) begin
      for(j=0;j<64;j++) begin: GET_VIOTA128
        assign result_data_viota[j] = ($clog2(`VLEN)+1)'(alu_uop.data_viota_per64[0][j]);
        assign result_data_viota[j+64] = ($clog2(`VLEN)+1)'({1'b0,alu_uop.data_viota_per64[1][j]} + {1'b0,alu_uop.data_viota_per64[0][63]});
      end
    end
  endgenerate
  
  generate
    for(j=0; j<`VLENB;j++) begin: GET_VIOTA8
      assign result_data_viota8[j] = result_data_viota[{alu_uop.uop_index,j[$clog2(`VLENB)-1:0]}];
    end

    for(j=0; j<`VLEN/`HWORD_WIDTH;j++) begin: GET_VIOTA16
      assign result_data_viota16[j] = result_data_viota[{alu_uop.uop_index,j[$clog2(`VLEN/`HWORD_WIDTH)-1:0]}];
    end

    for(j=0; j<`VLEN/`WORD_WIDTH;j++) begin: GET_VIOTA32
      assign result_data_viota32[j] = result_data_viota[{alu_uop.uop_index,j[$clog2(`VLEN/`WORD_WIDTH)-1:0]}];
    end
  endgenerate
  
  // vcpop
  assign result_data_vcpop = (`XLEN)'(result_data_viota[`VLEN-1]);

//
// submit result to ROB
//
  // get result_uop
  always_comb begin
    // initial the data
    `ifdef TB_SUPPORT
    result.uop_pc    = alu_uop.uop_pc;
    `endif
    result.rob_entry = alu_uop.rob_entry;
    result.w_valid   = alu_uop_valid;
    result.w_data    = alu_uop.result_data;
    result.vsaturate = alu_uop.vsaturate;

    // calculate result data
    case(alu_uop.alu_sub_opcode)
      OP_VCPOP: begin
        result.w_data = (`VLEN)'(result_data_vcpop);
        result.vsaturate = 'b0;
      end
      OP_VIOTA: begin
        result.vsaturate = 'b0;
        
        case(alu_uop.vd_eew)
          EEW8: begin
            for(int i=0; i<`VLENB;i++) begin
              result.w_data[i*`BYTE_WIDTH +: `BYTE_WIDTH] = (`BYTE_WIDTH)'(result_data_viota8[i]);
            end
          end
          EEW16: begin
            for(int i=0; i<`VLEN/`HWORD_WIDTH;i++) begin
              result.w_data[i*`HWORD_WIDTH +: `HWORD_WIDTH] = (`HWORD_WIDTH)'(result_data_viota16[i]);
            end
          end
          EEW32: begin
            for(int i=0; i<`VLEN/`WORD_WIDTH;i++) begin
              result.w_data[i*`WORD_WIDTH +: `WORD_WIDTH] = (`WORD_WIDTH)'(result_data_viota32[i]);
            end
          end
        endcase
      end
    endcase
  end

endmodule
