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
   wen, wdata, clk, rst_n
   );

  output logic [`NUM_VRF-1:0][`VLEN-1:0]  vreg;

  input  logic [`NUM_VRF-1:0][`VLENB-1:0] wen; // byte enable
  input  logic [`NUM_VRF-1:0][`VLEN-1:0]  wdata;
  input  logic                            clk;
  input  logic                            rst_n;

// -- 32 vector registers --------------------------------------------
genvar i,j;
generate
  for (i=0; i<`NUM_VRF; i=i+1) begin
    for (j=0; j<`VLENB; j=j+1) begin
      edff #(
        .T      (logic [`BYTE_WIDTH-1:0])
      )
      vrf_unit1_reg (
        .q      (vreg[i][j*`BYTE_WIDTH +: `BYTE_WIDTH]),
        .e      (wen[i][j]),
        .d      (wdata[i][j*`BYTE_WIDTH +: `BYTE_WIDTH]),
        .clk    (clk),
        .rst_n  (rst_n)
        );
    `ifdef ASSERT_ON
      `rvv_forbid($isunknown(vreg[i][j*`BYTE_WIDTH +: `BYTE_WIDTH]))
        else $error("VREG: data is unknow at vreg[%0d][%0d:%0d]",i,8*j+7,8*j);
    `endif //ASSERT_ON
    end //end for loop j
  end //end for loop i
endgenerate


endmodule
