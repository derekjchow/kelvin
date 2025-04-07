
`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif

module rvv_backend_alu_unit
(
  clk,
  rst_n,
  alu_uop_valid,
  alu_uop,
  pop_rs,
  result_valid,
  result,
  result_ready,
  trap_flush_rvv
);
//
// interface signals
//
  // global signal
  input   logic           clk;
  input   logic           rst_n;

  // ALU RS handshake signals
  input   logic           alu_uop_valid;
  input   ALU_RS_t        alu_uop;
  output  logic           pop_rs;

  // ALU send result signals to ROB
  output  logic           result_valid;
  output  PU2ROB_t        result;
  input   logic           result_ready;

  // trap-flush
  input   logic           trap_flush_rvv;

//
// internal signals
//   
  logic                   result_valid_addsub_p0;
  PU2ROB_t                result_addsub_p0;
  logic                   result_valid_shift_p0;
  PU2ROB_t                result_shift_p0;
  logic                   result_valid_mask_p0;
  PIPE_DATA_t             result_mask_p0;
  logic                   result_mask_2cycle;
  logic                   result_valid_other_p0;
  PU2ROB_t                result_other_p0;
  PU2ROB_t                result_p1;
  // pipeline
  logic                   result_valid_p1_en;
  logic                   result_valid_p1_in;
  logic                   result_valid_p1;
  logic                   alu_uop_p1_en;
  PIPE_DATA_t             alu_uop_p1_in;
  PIPE_DATA_t             alu_uop_p1;

//
// instance
//
  rvv_backend_alu_unit_addsub u_alu_addsub
  (
    .alu_uop_valid        (alu_uop_valid),
    .alu_uop              (alu_uop),
    .result_valid         (result_valid_addsub_p0),
    .result               (result_addsub_p0)
  );

  rvv_backend_alu_unit_shift u_alu_shift
  (
    .alu_uop_valid        (alu_uop_valid),
    .alu_uop              (alu_uop),
    .result_valid         (result_valid_shift_p0),
    .result               (result_shift_p0)
  );
  
  rvv_backend_alu_unit_mask u_alu_mask_p0
  ( 
    .alu_uop_valid        (alu_uop_valid),
    .alu_uop              (alu_uop),
    .result_valid         (result_valid_mask_p0),
    .result               (result_mask_p0),
    .result_2cycle        (result_mask_2cycle)
  );

  rvv_backend_alu_unit_other u_alu_other
  (
    .alu_uop_valid        (alu_uop_valid),
    .alu_uop              (alu_uop),
    .result_valid         (result_valid_other_p0),
    .result               (result_other_p0)
  );

// pipeline
  // result_valid_p1
  always_comb begin
    case({result_valid_p1,(result_valid_addsub_p0|result_valid_shift_p0|result_valid_mask_p0|result_valid_other_p0)})
      2'b01: begin
        result_valid_p1_en = result_mask_2cycle;
        result_valid_p1_in = 1'b1;
      end
      2'b10: begin
        result_valid_p1_en = result_ready;
        result_valid_p1_in = 1'b0;
      end
      2'b11: begin
        result_valid_p1_en = 1'b0;
        result_valid_p1_in = 1'b0;
      end
      default: begin
        result_valid_p1_en = 1'b1;
        result_valid_p1_in = 1'b0;
      end
    endcase
  end
  
  cdffr
  result_valid_p1_cdffr
  ( 
    .clk        (clk),
    .rst_n      (rst_n),
    .c          (trap_flush_rvv),
    .e          (result_valid_p1_en),
    .d          (result_valid_p1_in),
    .q          (result_valid_p1)
  ); 
  
  // alu_uop_p1
  always_comb begin
    case({result_valid_p1,(result_valid_addsub_p0|result_valid_shift_p0|result_valid_mask_p0|result_valid_other_p0)})
      2'b01: begin
        alu_uop_p1_en = result_mask_2cycle;
      end
      2'b11: begin
        alu_uop_p1_en = result_ready;        
      end
      default: begin
        alu_uop_p1_en = 1'b0;
      end
    endcase
  end

  always_comb begin
  `ifdef TB_SUPPORT 
    alu_uop_p1_in.uop_pc         = 'b0;
  `endif
    alu_uop_p1_in.rob_entry      = 'b0;
    alu_uop_p1_in.vd_eew         = EEW_NONE;
    alu_uop_p1_in.uop_index      = 'b0;
    alu_uop_p1_in.alu_sub_opcode = OP_OTHER;
    alu_uop_p1_in.result_data    = 'b0;
    alu_uop_p1_in.data_viota_per64 = 'b0;
    alu_uop_p1_in.vsaturate      = 'b0;

    case(1'b1)
      result_valid_addsub_p0: begin 
      `ifdef TB_SUPPORT 
        alu_uop_p1_in.uop_pc      = result_addsub_p0.uop_pc;
      `endif
        alu_uop_p1_in.rob_entry   = result_addsub_p0.rob_entry;
        alu_uop_p1_in.result_data = result_addsub_p0.w_data;
        alu_uop_p1_in.vsaturate   = result_addsub_p0.vsaturate;
      end
      result_valid_shift_p0: begin
      `ifdef TB_SUPPORT 
        alu_uop_p1_in.uop_pc      = result_shift_p0.uop_pc;
      `endif
        alu_uop_p1_in.rob_entry   = result_shift_p0.rob_entry;
        alu_uop_p1_in.result_data = result_shift_p0.w_data;
        alu_uop_p1_in.vsaturate   = result_shift_p0.vsaturate;
      end
      result_valid_other_p0: begin
      `ifdef TB_SUPPORT 
        alu_uop_p1_in.uop_pc      = result_other_p0.uop_pc;
      `endif
        alu_uop_p1_in.rob_entry   = result_other_p0.rob_entry;
        alu_uop_p1_in.result_data = result_other_p0.w_data;
        alu_uop_p1_in.vsaturate   = result_other_p0.vsaturate;
      end
      result_valid_mask_p0: begin
        alu_uop_p1_in             = result_mask_p0;
      end
    endcase
  end

  edff
  #(
    .T      (PIPE_DATA_t)
  )
  alu_uop_d1
  (
    .clk    (clk),
    .rst_n  (rst_n),
    .e      (alu_uop_p1_en), 
    .d      (alu_uop_p1_in),
    .q      (alu_uop_p1)
  );

  rvv_backend_alu_unit_execution_p1 u_alu_p1
  ( 
    .alu_uop_valid        (result_valid_p1),
    .alu_uop              (alu_uop_p1),
    .result               (result_p1)
  );

// 
// submit to ROB
// 
  always_comb begin
    result_valid = 'b0;
    result       = 'b0;
    pop_rs       = 'b0;

    case({result_valid_p1,(result_valid_addsub_p0|result_valid_shift_p0|result_valid_mask_p0|result_valid_other_p0)})
      2'b01: begin
        case(1'b1)
          result_valid_addsub_p0: begin
            result_valid = 1'b1;
            result       = result_addsub_p0;
            pop_rs       = 1'b1;
          end
          result_valid_shift_p0: begin
            result_valid = 1'b1;
            result       = result_shift_p0;
            pop_rs       = 1'b1;
          end
          result_valid_other_p0: begin
            result_valid = 1'b1;
            result       = result_other_p0;
            pop_rs       = 1'b1;
          end
          result_valid_mask_p0: begin
            result_valid      = !result_mask_2cycle;
`ifdef TB_SUPPORT
            result.uop_pc     = result_mask_p0.uop_pc;
`endif
            result.rob_entry  = result_mask_p0.rob_entry;
            result.w_data     = result_mask_p0.result_data;
            result.w_valid    = 1'b1;
            result.vsaturate  = 'b0;
            pop_rs            = 1'b1;
          end
        endcase
      end
      2'b10: begin
        result_valid = 1'b1;
        result       = result_p1;
        pop_rs       = 1'b0;
      end
      2'b11: begin
        result_valid = 1'b1;
        result       = result_p1;
        pop_rs       = result_ready;
      end
    endcase
  end

endmodule
