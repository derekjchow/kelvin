`ifndef HDL_VERILOG_RVV_DESIGN_RVV_SVH
`include "rvv_backend.svh"
`endif
`ifndef RVV_ASSERT__SVH
`include "rvv_backend_sva.svh"
`endif

module rvv_backend_lsu_remap
(
  mapinfo,
  lsu_res,
  mapinfo_empty,
  mapinfo_almost_empty,
  lsu_res_empty,
  lsu_res_almost_empty,
  pop_mapinfo,
  pop_lsu_res,
  result_valid_lsu2rob,
  result_lsu2rob,
  result_ready_rob2lsu,
  trap_valid_rmp2rob,
  trap_rob_entry_rmp2rob,
  trap_ready_rob2rmp
);

//
// interface signals
//
  // MAP INFO and LSU RES
  input   LSU_MAP_INFO_t  [`NUM_LSU-1:0]  mapinfo;
  input   UOP_LSU_t       [`NUM_LSU-1:0]  lsu_res;
  input   logic                           mapinfo_empty;
  input   logic           [`NUM_LSU-1:0]  mapinfo_almost_empty;
  input   logic                           lsu_res_empty;
  input   logic           [`NUM_LSU-1:0]  lsu_res_almost_empty;
  output  logic           [`NUM_LSU-1:0]  pop_mapinfo;
  output  logic           [`NUM_LSU-1:0]  pop_lsu_res;

  // submit LSU result to ROB
  output  logic           [`NUM_LSU-1:0]  result_valid_lsu2rob;
  output  PU2ROB_t        [`NUM_LSU-1:0]  result_lsu2rob;
  input   logic           [`NUM_LSU-1:0]  result_ready_rob2lsu;

  // submit trap to ROB
  output  logic                           trap_valid_rmp2rob;
  output  logic   [`ROB_DEPTH_WIDTH-1:0]  trap_rob_entry_rmp2rob;
  input   logic                           trap_ready_rob2rmp;

//
// internal signals
//
  logic [`NUM_LSU-1:0]  mapinfo_valid;
  logic [`NUM_LSU-1:0]  lsu_res_valid;

  genvar                i;

//
// start 
//
  // valid signal
  assign mapinfo_valid[0] = !mapinfo_empty;
  assign lsu_res_valid[0] = !lsu_res_empty;

  generate
    for(i=1;i<`NUM_LSU;i++) begin: GET_VALID
      assign mapinfo_valid[i] = !mapinfo_almost_empty[i];
      assign lsu_res_valid[i] = !lsu_res_almost_empty[i];
    end
  endgenerate
  
  // result valid 
  generate
    for(i=0;i<`NUM_LSU;i++) begin: RES_VALID
      assign result_valid_lsu2rob[i] = mapinfo_valid[i]&lsu_res_valid[i]&mapinfo[i].valid&(!lsu_res[i].trap_valid)&(
                                       (mapinfo[i].lsu_class==IS_LOAD) & lsu_res[i].uop_lsu2rvv.vregfile_write_valid ||
                                       (mapinfo[i].lsu_class==IS_STORE) & lsu_res[i].uop_lsu2rvv.lsu_vstore_last);
    end
  endgenerate

  // remap
  generate
    for(i=0;i<`NUM_LSU;i++) begin: GET_RESULT
      `ifdef TB_SUPPORT
        assign result_lsu2rob[i].uop_pc    = mapinfo[i].uop_pc;
      `endif
        assign result_lsu2rob[i].rob_entry = mapinfo[i].rob_entry;
        assign result_lsu2rob[i].w_data    = lsu_res[i].uop_lsu2rvv.vregfile_write_data;
        assign result_lsu2rob[i].w_valid   = (mapinfo[i].lsu_class==IS_LOAD)&
                                             lsu_res[i].uop_lsu2rvv.vregfile_write_valid&
                                             (lsu_res[i].uop_lsu2rvv.vregfile_write_addr==mapinfo[i].vregfile_write_addr);
        assign result_lsu2rob[i].vsaturate = 'b0;
    end
  endgenerate

  always_comb begin
    trap_valid_rmp2rob = 'b0;
    trap_rob_entry_rmp2rob = 'b0;

    for (int j=0;j<`NUM_LSU;j++) begin
      if (lsu_res[j].trap_valid&lsu_res_valid[j]&mapinfo_valid[j]) begin
        trap_valid_rmp2rob     = 'b1;
        trap_rob_entry_rmp2rob = mapinfo[j].rob_entry;
      end
    end
  end

  // pop signal
  generate
    for(i=0;i<`NUM_LSU;i++) begin: GET_POP
      assign pop_mapinfo[i] = (!lsu_res[i].trap_valid)&result_valid_lsu2rob[i]&result_ready_rob2lsu[i]||
                                lsu_res[i].trap_valid&mapinfo_valid[i]&lsu_res_valid[i]&trap_ready_rob2rmp;
      assign pop_lsu_res[i] = pop_mapinfo[i];
    end
  endgenerate

endmodule
