//
// Template for UVM-compliant interface
//

`ifndef POP_INTERFACE__SV
`define POP_INTERFACE__SV

interface pop_interface;

logic clk;
logic rst_n;
`ifdef FIFO_2W2R
logic [DWIDTH-1:0] pop_data0;
logic pop0;
logic [DWIDTH-1:0] pop_data1;
logic pop1;
`elsif FIFO_4W2R
logic [DWIDTH-1:0] pop_data0;
logic pop0;
logic [DWIDTH-1:0] pop_data1;
logic pop1;
logic [DWIDTH-1:0] pop_data2;
logic pop2;
logic [DWIDTH-1:0] pop_data3;
logic pop3;
`else
logic [DWIDTH-1:0] pop_data;
logic pop;
`endif
logic empty;
logic almost_empty;
logic idle;

endinterface: pop_interface

`endif // POP_INTERFACE__SV
