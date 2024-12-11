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
  alu_uop_valid,
  alu_uop,
  result_valid,
  result
);
//
// interface signals
//
  // ALU RS handshake signals
  input   logic                   alu_uop_valid;
  input   ALU_RS_t                alu_uop;

  // ALU send result signals to ROB
  output  logic                   result_valid;
  output  ALU2ROB_t               result;

//
// internal signals
//   
  logic                           result_valid_addsub;
  ALU2ROB_t                       result_addsub;
  logic                           result_valid_mask;
  ALU2ROB_t                       result_mask;

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

  rvv_backend_alu_unit_mask u_alu_mask
  (
    .alu_uop_valid        (alu_uop_valid),
    .alu_uop              (alu_uop),
    .result_valid         (result_valid_mask),
    .result               (result_mask)
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

      result_valid_mask: begin
        result_valid = 1'b1;
        result       = result_mask;
      end
    endcase
  end

endmodule
