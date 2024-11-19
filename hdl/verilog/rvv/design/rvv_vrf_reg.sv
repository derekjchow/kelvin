// rvv_vrf_reg - 32 vector regsiter for V standard extention

module rvv_vrf_reg (
  vreg, 
  we, 
  wdata, 
  clk, 
  rst_n
  );

  output logic [31:0][`VLEN-1:0]  vreg;

  input  logic [31:0][`VLENB-1:0] we; // byte enable
  input  logic [31:0][`VLEN-1:0]  wdata;
  input  logic                    clk;
  input  logic                    rst_n;

// -- 32 vector registers --------------------------------------------

genvar i,j;
generate
  for (i=0; i<32; i=i+1) begin: vrf_regsiter
    for (j=0; j<VLENB; j=j+1) begin: byte_regsiter
      edff #(.WIDTH(8)) vrf_byte (
        .q      (vreg[i][8*j+:8]),
        .en     (we[i][j]),
        .d      (wdata[i][8*j+:8]),
        .clk    (clk),
        .rst_n  (rst_n)
      );

`ifdef ASSERT_ON
      assert property (@(posedge clk) disable iff (!rst_n) not (we[i][j] && $isunknown(wdata[i][8*j+:8])))
        else $error("VRF_REG: VRF unknown data %h updating vreg[%d][%d]", $sample(wdata[i][8*j+:8]), i, j);
`endif
    end
  end
endgenerate

endmodule
