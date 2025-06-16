// rvv_vrf_reg - 32 vector regsiter for V standard extention
`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif
module rvv_backend_vrf_reg (/*AUTOARG*/
   // Outputs
   vreg,
   // Inputs
   wenb, wdata, clk, rst_n
   );

  output logic [`NUM_VRF-1:0][`VLEN-1:0]  vreg;

  input  logic [`NUM_VRF-1:0][`VLEN-1:0]  wenb; // bit en
  input  logic [`NUM_VRF-1:0][`VLEN-1:0]  wdata;
  input  logic                            clk;
  input  logic                            rst_n;

// -- 32 vector registers --------------------------------------------
genvar i,j;
generate
  for (i=0; i<`NUM_VRF; i=i+1) begin
    for (j=0; j<`VLEN; j=j+1) begin
      edff vrf_unit1_reg (
        .q      (vreg[i][j]),
        .e      (wenb[i][j]),
        .d      (wdata[i][j]),
        .clk    (clk),
        .rst_n  (rst_n)
        );
    `ifdef ASSERT_ON
      `rvv_forbid($isunknown(vreg[i][j]))
        else $error("VREG: data is unknow at vreg[%0d][%0d]",i,j);
    `endif //ASSERT_ON
    end //end for loop j
  end //end for loop i
endgenerate


endmodule
