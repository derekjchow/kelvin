`ifndef RVV_BACKEND_POKE__SHV
`define RVV_BACKEND_POKE__SHV


`ifdef TB_BRINGUP
  `define VRF_PATH      DUT
  `define RT_EVENT_PATH DUT
`else
  `define VRF_PATH      DUT.u_vrf.vrf_reg
  `define RT_EVENT_PATH DUT.
`endif 

`endif // RVV_BACKEND_POKE__SHV
