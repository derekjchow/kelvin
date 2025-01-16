`ifndef RVV_BACKEND_POKE__SHV
`define RVV_BACKEND_POKE__SHV


`ifdef TB_BRINGUP
  `define VRF_PATH      DUT
  `define RT_UOP_PATH   DUT
`else
  `define VRF_PATH      DUT.u_vrf.vrf_reg
  `define RT_UOP_PATH   DUT
  `define RT_VRF_PATH   DUT.u_retire
  `define RT_VXSAT_PATH DUT.u_retire
`endif 

`endif // RVV_BACKEND_POKE__SHV
