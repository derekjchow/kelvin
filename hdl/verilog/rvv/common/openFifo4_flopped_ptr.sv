module openFifo4_flopped_ptr(/*AUTOARG*/
   // Outputs
   fifo_outData, fifo_full, fifo_empty, d0, d1, d2, d3, dValid, dPtr,
   // Inputs
   clk, rst_n, fifo_inData, single_push, single_pop
   );
   
  parameter DWIDTH = 32,
	    AWIDTH = 2;

  localparam ZERO = {DWIDTH{1'b0}};

  input		      clk;
  input		      rst_n;

  input	 [DWIDTH-1:0] fifo_inData;
  input		      single_push;
  input		      single_pop;

  output [DWIDTH-1:0] fifo_outData;
  output	      fifo_full;
  output	      fifo_empty;

  output [DWIDTH-1:0] d0;
  output [DWIDTH-1:0] d1;
  output [DWIDTH-1:0] d2;
  output [DWIDTH-1:0] d3;
  
  output [3:0] dValid;
  output [AWIDTH-1:0] dPtr;
  
  // Write pointer
  wire [AWIDTH-1:0] wrPtr;
  wire [AWIDTH-1:0] nxtWrPtr = single_push ? wrPtr + 1'b1 : wrPtr;

  edff #(AWIDTH) wrPtrReg (.q(wrPtr), .clk(clk), .rst_n(rst_n), .d(nxtWrPtr), .en(single_push) `ifdef TB_SUPPORT , .init_data('0)`endif);
  // Read pointer
  wire [AWIDTH-1:0] rdPtr;
  wire [AWIDTH-1:0] nxtRdPtr = single_pop ? rdPtr + 1'b1 : rdPtr;

  edff #(AWIDTH) rdPtrReg (.q(rdPtr), .clk(clk), .rst_n(rst_n), .d(nxtRdPtr), .en(single_pop) `ifdef TB_SUPPORT , .init_data('0)`endif);

  assign dPtr = nxtRdPtr;
  // Flag generation
  reg nxtLempty;

  always @(*)
    if ((nxtWrPtr == nxtRdPtr) & single_pop)
      nxtLempty = 1'b1;
    else if (nxtWrPtr != nxtRdPtr)
      nxtLempty = 1'b0;
    else
      nxtLempty = fifo_empty;

  dff #(1) emptyReg (.q(fifo_empty), .clk(clk), .rst_n(rst_n), .d(nxtLempty));

  reg nxtLfull;

  always @(*)
    if ((nxtWrPtr == nxtRdPtr) & single_push)
      nxtLfull = 1'b1;
    else if (nxtWrPtr != nxtRdPtr)
      nxtLfull = 1'b0;
    else
      nxtLfull = fifo_full;

  dff #(1) fullReg (.q(fifo_full), .clk(clk), .rst_n(rst_n), .d(nxtLfull));

  // Write enable decodes
  wire en0 = single_push & (wrPtr == 2'd0);
  wire en1 = single_push & (wrPtr == 2'd1);
  wire en2 = single_push & (wrPtr == 2'd2);
  wire en3 = single_push & (wrPtr == 2'd3);

  // Data registers
  wire [DWIDTH-1:0] d0;
  wire [DWIDTH-1:0] d1;
  wire [DWIDTH-1:0] d2;
  wire [DWIDTH-1:0] d3;

  edff #(DWIDTH) d0Reg (.q(d0), .clk(clk), .rst_n(rst_n), .en(en0), .d(fifo_inData) `ifdef TB_SUPPORT , .init_data('0)`endif);
  edff #(DWIDTH) d1Reg (.q(d1), .clk(clk), .rst_n(rst_n), .en(en1), .d(fifo_inData) `ifdef TB_SUPPORT , .init_data('0)`endif);
  edff #(DWIDTH) d2Reg (.q(d2), .clk(clk), .rst_n(rst_n), .en(en2), .d(fifo_inData) `ifdef TB_SUPPORT , .init_data('0)`endif);
  edff #(DWIDTH) d3Reg (.q(d3), .clk(clk), .rst_n(rst_n), .en(en3), .d(fifo_inData) `ifdef TB_SUPPORT , .init_data('0)`endif);

  // Read output
  reg [DWIDTH-1:0] fifo_outData;

  always @(*)
    case (rdPtr)
      2'd0 : fifo_outData = d0;
      2'd1 : fifo_outData = d1;
      2'd2 : fifo_outData = d2;
      2'd3 : fifo_outData = d3;
      default : fifo_outData = ZERO;
    endcase

  
  // Valid signal per data
  reg  [4-1:0] dValidN;
  wire updateDValid;
  edff  #(4) dValidReg (.q(dValid), .clk(clk), .d(dValidN), .rst_n(rst_n), .en(updateDValid) `ifdef TB_SUPPORT , .init_data('0)`endif);
  
  assign updateDValid = single_push | single_pop;
  
  always @(*) begin
    dValidN = dValid;
    if (single_push) dValidN[wrPtr] = 1'b1;
    if (single_pop)  dValidN[rdPtr] = 1'b0;
  end

`ifdef ASSERT_ON
  `rvv_forbid(single_push&&fifo_full) 
    else $error("ERROR: Fifo Overflow! \n");

  `rvv_forbid(single_pop&&fifo_empty) 
    else $error("ERROR: Fifo Underflow! \n");
`endif

endmodule
