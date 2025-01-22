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

  // ALU send result signals to ROB
  output  logic           result_valid;
  output  PU2ROB_t        result;
  input   logic           result_ready;

//
// internal signals
//   
  logic                   result_valid_addsub;
  PU2ROB_t                result_addsub;
  logic                   result_valid_shift;
  PU2ROB_t                result_shift;
  logic                   result_valid_mask;
  PU2ROB_t                result_mask;
  logic                   result_valid_other;
  PU2ROB_t                result_other;

//
// instance
//
  rvv_backend_alu_unit_addsub u_alu_addsub
  (
    .alu_uop_valid        (alu_uop_valid),
    .alu_uop              (alu_uop),
    .result_valid         (result_valid_addsub),
    .result               (result_addsub)
  );

  rvv_backend_alu_unit_shift u_alu_shift
  (
    .alu_uop_valid        (alu_uop_valid),
    .alu_uop              (alu_uop),
    .result_valid         (result_valid_shift),
    .result               (result_shift)
  );
  
  rvv_backend_alu_unit_mask u_alu_mask
  ( 
    .clk                  (clk),
    .rst_n                (rst_n),
    .alu_uop_valid        (alu_uop_valid),
    .alu_uop              (alu_uop),
    .result_valid         (result_valid_mask),
    .result               (result_mask),
    .result_ready         (result_ready)
  );

  rvv_backend_alu_unit_other u_alu_other
  (
    .alu_uop_valid        (alu_uop_valid),
    .alu_uop              (alu_uop),
    .result_valid         (result_valid_other),
    .result               (result_other)
  );

// 
// submit to ROB
// 
  always_comb begin
    // initial
    result_valid = 'b0;
    result       = 'b0;

    case(1'b1)
      result_valid_addsub: begin
        result_valid = 1'b1;
        result       = result_addsub;
      end

      result_valid_shift: begin
        result_valid = 1'b1;
        result       = result_shift;
      end

      result_valid_mask: begin
        result_valid = 1'b1;
        result       = result_mask;
      end

      result_valid_other: begin
        result_valid = 1'b1;
        result       = result_other;
      end
    endcase
  end

endmodule
