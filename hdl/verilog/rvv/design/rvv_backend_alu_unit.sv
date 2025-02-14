// description: 
// 1. It will get uops from ALU Reservation station and execute this uop.
//
// feature list:
// 1. All are combinatorial logic.
// 2. All alu uop is executed and submit to ROB in 1 cycle.
// 3. Reuse arithmetic logic as much as possible.
// 4. Low-power design.

`include "rvv_backend.svh"

module rvv_backend_alu_unit
(
  clk,
  rst_n,
  alu_uop_valid,
  alu_uop,
  pop_rs,
  result_valid,
  result,
  result_ready
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

//
// internal signals
//   
  logic                   result_valid_addsub_p0;
  PU2ROB_t                result_addsub_p0;
  logic                   result_valid_shift_p0;
  PU2ROB_t                result_shift_p0;
  logic                   result_valid_mask_p0;
  PIPE_DATA_t             result_mask_p0;
  logic                   result_valid_other_p0;
  PU2ROB_t                result_other_p0;
  PU2ROB_t                result_p1;
  // pipeline
  logic                   result_valid_p1_en;
  logic                   result_valid_p1_in;
  logic                   result_valid_p1;
  logic                   uop_p1_en;
  PIPE_DATA_t             uop_p1;

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
    .result               (result_mask_p0)
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
        result_valid_p1_en = (result_mask_p0.alu_sub_opcode==OP_VIOTA)|(result_mask_p0.alu_sub_opcode==OP_VCPOP);
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
  
  edff
  #(
    .WIDTH     (1)
  )
  result_valid_p1_edff
  ( 
    .clk       (clk), 
    .rst_n     (rst_n), 
    .en        (result_valid_p1_en), 
    .d         (result_valid_p1_in),
    .q         (result_valid_p1)
  ); 
  
  // uop_p1
  always_comb begin
    case({result_valid_p1,(result_valid_addsub_p0|result_valid_shift_p0|result_valid_mask_p0|result_valid_other_p0)})
      2'b01: begin
        uop_p1_en = (result_mask_p0.alu_sub_opcode==OP_VIOTA)|(result_mask_p0.alu_sub_opcode==OP_VCPOP);
      end
      2'b11: begin
        uop_p1_en = result_ready;        
      end
      default: begin
        uop_p1_en = 1'b0;
      end
    endcase
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
`ifdef TB_SUPPORT 
      uop_p1.uop_pc         <= 'b0;
`endif
      uop_p1.rob_entry      <= 'b0;
      uop_p1.vd_eew         <= EEW_NONE;
      uop_p1.uop_index      <= 'b0;
      uop_p1.alu_sub_opcode <= OP_NONE;
      uop_p1.result_data    <= 'b0;
      for(int i=0;i<`VLEN/64;i++) begin
        for(int k=0;k<64;k++) begin
          uop_p1.data_viota_per64[i][k][$clog2(64):0] <= 'b0;
        end
      end
      uop_p1.vsaturate      <= 'b0;
    end
    else if(uop_p1_en) begin
`ifdef TB_SUPPORT 
      uop_p1.uop_pc         <= 'b0;
`endif
      uop_p1.rob_entry      <= 'b0;
      uop_p1.vd_eew         <= EEW_NONE;
      uop_p1.uop_index      <= 'b0;
      uop_p1.alu_sub_opcode <= OP_OTHER;
      uop_p1.result_data    <= 'b0;
      for(int i=0;i<`VLEN/64;i++) begin
        for(int k=0;k<64;k++) begin
          uop_p1.data_viota_per64[i][k][$clog2(64):0] <= 'b0;
        end
      end
      uop_p1.vsaturate      <= 'b0;

      case(1'b1)
        result_valid_addsub_p0: begin
`ifdef TB_SUPPORT 
          uop_p1.uop_pc       <= result_addsub_p0.uop_pc;
`endif
          uop_p1.rob_entry    <= result_addsub_p0.rob_entry;
          uop_p1.result_data  <= result_addsub_p0.w_data;
          uop_p1.vsaturate    <= result_addsub_p0.vsaturate;
        end
        result_valid_shift_p0: begin
`ifdef TB_SUPPORT 
          uop_p1.uop_pc       <= result_shift_p0.uop_pc;
`endif
          uop_p1.rob_entry    <= result_shift_p0.rob_entry;
          uop_p1.result_data  <= result_shift_p0.w_data;
          uop_p1.vsaturate    <= result_shift_p0.vsaturate;
        end
        result_valid_other_p0: begin
`ifdef TB_SUPPORT 
          uop_p1.uop_pc       <= result_other_p0.uop_pc;
`endif
          uop_p1.rob_entry    <= result_other_p0.rob_entry;
          uop_p1.result_data  <= result_other_p0.w_data;
          uop_p1.vsaturate    <= result_other_p0.vsaturate;
        end
        result_valid_mask_p0: begin
          uop_p1              <= result_mask_p0;
        end
      endcase
    end
  end

  rvv_backend_alu_unit_execution_p1 u_alu_p1
  ( 
    .uop_valid            (result_valid_p1),
    .uop                  (uop_p1),
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
            result_valid      = result_mask_p0.alu_sub_opcode==OP_OTHER;
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
