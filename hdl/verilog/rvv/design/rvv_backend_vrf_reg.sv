// rvv_vrf_reg - 32 vector regsiter for V standard extention
`include "rvv.svh"

module rvv_backend_vrf_reg (/*AUTOARG*/
   // Outputs
   vreg,
   // Inputs
   wen, wdata, clk, rst_n
   );

  output logic [31:0][`VLEN-1:0]  vreg;

  input  logic [31:0]             wen; // entry en
  input  logic [31:0][`VLEN-1:0]  wdata;
  input  logic                    clk;
  input  logic                    rst_n;

// -- 32 vector registers --------------------------------------------

genvar i;
generate
  for (i=0; i<32; i=i+1) begin
    edff #(128) vrf_unit128_reg (
        .q      (vreg[i]),
        .en     (wen[i]),
        .d      (wdata[i]),
        .clk    (clk),
        .rst_n  (rst_n)
      );
  end// end for
endgenerate

endmodule
