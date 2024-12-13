//
// Template for UVM-compliant verification environment
//

`ifndef RVV_FIFO__SV
`define RVV_FIFO__SV


`ifdef FIFO_2W2R
   parameter PUSH_WIDTH = 2;
   parameter POP_WIDTH = 2;
`elsif FIFO_4W2R
   parameter PUSH_WIDTH = 4;
   parameter POP_WIDTH = 2;
`elsif FIFO_2W4R
   parameter PUSH_WIDTH = 2;
   parameter POP_WIDTH = 4
`else //FIFO_1W1R
   parameter PUSH_WIDTH = 1;
   parameter POP_WIDTH = 1;
`endif

`ifdef DWIDTH_64
   parameter DWIDTH = 64;
`elsif DWIDTH_16
   parameter DWIDTH = 16;
`else //DWIDTH_32
   parameter DWIDTH = 32;
`endif

`ifdef DEPTH_32
`elsif DEPTH_16
`elsif DEPTH_8
   parameter DEPTH = 8;
`elsif DEPTH_4
`else
`endif

`ifdef HALFFULL_HALF
   parameter HALF_FULL = DEPTH>>1;
`else
   parameter HALF_FULL = DEPTH-2;
`endif
   


// ToDo: Add additional required `include directives

`endif // RVV_FIFO__SV
