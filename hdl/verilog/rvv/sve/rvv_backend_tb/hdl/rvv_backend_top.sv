`ifndef RVV_TOP__SV
`define RVV_TOP__SV

`include "rvv_backend_poke.svh"
`include "rvv_backend_tb_mod.sv"
module rvv_backend_top();

  logic clk;
  logic rst_n;

  // Clock Generation
  parameter sim_cycle = 10;
  
  // Reset Delay Parameter
  parameter rst_delay = 5;

  always 
    begin
      #(sim_cycle/2) clk = ~clk;
    end

  rvs_interface rvs_if(clk,rst_n);
  lsu_interface lsu_if(clk,rst_n);
  vrf_interface vrf_if(clk,rst_n);
  
  rvv_backend_tb_mod test(); 
  
  rvv_backend DUT (
    .clk(clk),
    .rst_n(rst_n),
    
    .insts_valid_rvs2cq       (rvs_if.insts_valid_rvs2cq    ),
    .insts_rvs2cq             (rvs_if.insts_rvs2cq          ),
    .insts_ready_cq2rvs       (rvs_if.insts_ready_cq2rvs    ),
    
    .rt_xrf_rvv2rvs           (rvs_if.rt_xrf_rvv2rvs         ),
    .rt_xrf_valid_rvv2rvs     (rvs_if.rt_xrf_valid_rvv2rvs   ),
    .rt_xrf_ready_rvs2rvv     (rvs_if.rt_xrf_ready_rvs2rvv   ),

    .uop_valid_lsu_rvv2rvs    (lsu_if.uop_valid_lsu_rvv2rvs ),
    .uop_lsu_rvv2rvs          (lsu_if.uop_lsu_rvv2rvs       ),
    .uop_ready_lsu_rvs2rvv    (lsu_if.uop_ready_lsu_rvs2rvv ),

    .uop_valid_lsu_rvs2rvv    (lsu_if.uop_valid_lsu_rvs2rvv ),
    .uop_lsu_rvs2rvv          (lsu_if.uop_lsu_rvs2rvv       ),
    .uop_ready_rvv2rvs        (lsu_if.uop_ready_rvv2rvs     ),

    
    .trap_valid_rvs2rvv       (rvs_if.trap_valid_rvs2rvv    ),
    .trap_rvs2rvv             (rvs_if.trap_rvs2rvv          ),
    .trap_ready_rvv2rvs       (rvs_if.trap_ready_rvv2rvs    ), 

    .wr_vxsat_valid           (rvs_if.wr_vxsat_valid        ),
    .wr_vxsat                 (rvs_if.wr_vxsat              ),

    .vcsr_valid               (rvs_if.vcsr_valid            ),
    .vector_csr               (rvs_if.vector_csr            )
  );

  assign rvs_if.rt_uop      = `RT_UOP_PATH.rt_uop;
  assign rvs_if.rt_last_uop = `RT_UOP_PATH.rt_last_uop;
  
  // VRF retire
  always_comb begin
    for(int i=0; i<`NUM_RT_UOP; i++) begin
      rvs_if.rt_vrf_valid_rob2rt[i] = `RT_VRF_PATH.rt2vrf_write_valid[i];
      rvs_if.rt_vrf_data_rob2rt[i].uop_pc   = `RT_VRF_PATH.rob2rt_write_data[i].uop_pc;
      rvs_if.rt_vrf_data_rob2rt[i].rt_data  = `RT_VRF_PATH.rt2vrf_write_data[i].rt_data;
      rvs_if.rt_vrf_data_rob2rt[i].rt_index = `RT_VRF_PATH.rt2vrf_write_data[i].rt_index;
    end
  end
  assign rvs_if.rt_vrf_data_rob2rt[0].rt_strobe  = `RT_VRF_PATH.w_enB0;
  assign rvs_if.rt_vrf_data_rob2rt[1].rt_strobe  = `RT_VRF_PATH.w_enB1;
  assign rvs_if.rt_vrf_data_rob2rt[2].rt_strobe  = `RT_VRF_PATH.w_enB2;
  assign rvs_if.rt_vrf_data_rob2rt[3].rt_strobe  = `RT_VRF_PATH.w_enB3;

  // For VRF value check, we need to delay a cycle to wait for writeback finished.
  always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      vrf_if.rt_uop      <= '0;
      vrf_if.rt_last_uop <= '0;
    end else begin
      vrf_if.rt_uop      <= `RT_UOP_PATH.rt_uop;
      vrf_if.rt_last_uop <= `RT_UOP_PATH.rt_last_uop;
    end
  end

  always_comb begin: vrf_connect
    for(int i=0; i<32; i++) begin
      vrf_if.vreg[i] = `VRF_PATH.vreg[i];
      `VRF_PATH.vreg_init_data[i] = vrf_if.vreg_init_data[i];
    end
  end: vrf_connect

  //Driver reset depending on rst_delay
  initial begin
      clk = 0;
      rst_n = 0;
      repeat (rst_delay) @(posedge clk);
      rst_n = 1'b1;
      @(clk);
  end

endmodule: rvv_backend_top

`endif // RVV_TOP__SV
