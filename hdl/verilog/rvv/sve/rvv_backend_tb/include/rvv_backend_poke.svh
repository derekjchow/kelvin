`ifndef RVV_BACKEND_POKE__SHV
`define RVV_BACKEND_POKE__SHV


`ifdef TB_BRINGUP
  `define VRF_PATH      DUT
  `define RT_UOP_PATH   DUT
`else
  `define VRF_PATH      DUT.u_vrf
  `define ROB_PATH      DUT.u_rob
  `define RT_VRF_PATH   DUT.u_retire
  `define RT_VXSAT_PATH DUT.u_retire
  `define DECODE_PATH   DUT.u_decode
`endif 

`endif // RVV_BACKEND_POKE__SHV
