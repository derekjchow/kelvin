//
// Template for UVM-compliant interface
//

`ifndef PUSH_INTERFACE__SV
`define PUSH_INTERFACE__SV

interface push_interface();
   logic clk;
   logic rst_n;
   `ifdef FIFO_2W2R
   logic  push0;
   logic  [DWIDTH-1:0] push_data0;
   logic  push1 ;
   logic  [DWIDTH-1:0] push_data1;
   `elsif FIFO_4W2R
   logic  push0;
   logic  [DWIDTH-1:0] push_data0;
   logic  push1 ;
   logic  [DWIDTH-1:0] push_data1;
   logic  push2;
   logic  [DWIDTH-1:0] push_data2;
   logic  push3 ;
   logic  [DWIDTH-1:0] push_data3;
   `else
   logic  push ;
   logic  [DWIDTH-1:0] push_data;
   `endif
   logic full;
   logic halfFull;
   logic almost_full; //fifo has 1 valid entry
   logic almost_full2; //fifo has 2 valid entry
   logic almost_full3; //fifo has 3 valid entry
endinterface: push_interface

`endif // PUSH_INTERFACE__SV
