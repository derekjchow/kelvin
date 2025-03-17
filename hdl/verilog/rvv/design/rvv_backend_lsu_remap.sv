`include "rvv_backend.svh"
`include "rvv_backend_sva.svh"

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
  result_ready_rob2lsu
);

//
// interface signals
//
  // MAP INFO and LSU RES
  input   LSU_MAP_INFO_t  [`NUM_LSU-1:0]  mapinfo;
  input   UOP_LSU2RVV_t   [`NUM_LSU-1:0]  lsu_res;
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
      assign mapinfo_valid[i] = !(|mapinfo_almost_empty[i:0]);
      assign lsu_res_valid[i] = !(|lsu_res_almost_empty[i:0]);
    end
  endgenerate
  
  // result valid 
  generate
    for(i=0;i<`NUM_LSU;i++) begin: RES_VALID
      assign result_valid_lsu2rob[i] = mapinfo_valid[i]&lsu_res_valid[i]&mapinfo[i].valid&(
                                       (mapinfo[i].lsu_class==IS_LOAD) & lsu_res[i].vregfile_write_valid || 
                                       (mapinfo[i].lsu_class==IS_STORE) & lsu_res[i].lsu_vstore_last);
    end
  endgenerate

  // remap
  generate
    for(i=0;i<`NUM_LSU;i++) begin: GET_RESULT
      `ifdef TB_SUPPORT
        assign result_lsu2rob[i].uop_pc = mapinfo[i].uop_pc;
      `endif
        assign result_lsu2rob[i].rob_entry = mapinfo[i].rob_entry;
        assign result_lsu2rob[i].w_data = lsu_res[i].vregfile_write_data;
        assign result_lsu2rob[i].w_valid = (mapinfo[i].lsu_class==IS_LOAD)&lsu_res[i].vregfile_write_valid&(lsu_res[i].vregfile_write_addr==mapinfo[i].vregfile_write_addr);
        assign result_lsu2rob[i].vsaturate = 'b0;
    end
  endgenerate

  // pop signal
  generate
    for(i=0;i<`NUM_LSU;i++) begin: GET_POP
      assign pop_mapinfo[i] = result_valid_lsu2rob[i]&result_ready_rob2lsu[i];
      assign pop_lsu_res[i] = pop_mapinfo[i];
    end
  endgenerate

`ifdef ASSERT_ON
  `ifdef TB_SUPPORT
    `rvv_forbid(mapinfo_valid[0]&lsu_res_valid[0]&result_ready_rob2lsu[0]&(result_valid_lsu2rob[0]==1'b0))
      else $error("pc(0x%h): something wrong in lsu remapping.\n",mapinfo[0].uop_pc);
  `else
    `rvv_forbid(mapinfo_valid[0]&lsu_res_valid[0]&result_ready_rob2lsu[0]&(result_valid_lsu2rob[0]==1'b0))
      else $error("something wrong in lsu remapping.\n");
  `endif
`endif


endmodule
