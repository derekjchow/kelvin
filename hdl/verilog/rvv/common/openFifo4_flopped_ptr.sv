module openFifo4_flopped_ptr(/*AUTOARG*/
   // Outputs
   outData, full, empty, d0, d1, d2, d3, dValid, nxtRdPtr,
   // Inputs
   clk, rst_n, inData, push, pop
   );
   
  parameter DWIDTH = 32,
	    AWIDTH = 2;

  localparam ZERO = {DWIDTH{1'b0}};

  input		      clk;
  input		      rst_n;

  input	 [DWIDTH-1:0] inData;
  input		      push;
  input		      pop;

  output [DWIDTH-1:0] outData;
  output	      full;
  output	      empty;

  //&perl for $i (0 .. 3) {&printl "  output [DWIDTH-1:0] d$i;\n";}
  //Begin Perl:
  output [DWIDTH-1:0] d0;
  output [DWIDTH-1:0] d1;
  output [DWIDTH-1:0] d2;
  output [DWIDTH-1:0] d3;
  //End Perl:
  
  output [3:0] dValid;
  output [AWIDTH-1:0] nxtRdPtr;
  
  // Write pointer
  wire [AWIDTH-1:0] wrPtr;
  wire [AWIDTH-1:0] nxtWrPtr = push ? wrPtr + 1'b1 : wrPtr;

  edff #(AWIDTH) wrPtrReg (.q(wrPtr), .clk(clk), .rst_n(rst_n), .d(nxtWrPtr), .en(push));
  // Read pointer
  wire [AWIDTH-1:0] rdPtr;
  wire [AWIDTH-1:0] nxtRdPtr = pop ? rdPtr + 1'b1 : rdPtr;

  edff #(AWIDTH) rdPtrReg (.q(rdPtr), .clk(clk), .rst_n(rst_n), .d(nxtRdPtr), .en(pop));
  // Flag generation

  wire empty;
  reg nxtLempty;

  always @(pop or nxtRdPtr or nxtWrPtr or empty)
    if ((nxtWrPtr == nxtRdPtr) & pop)
      nxtLempty = 1'b1;
    else if (nxtWrPtr != nxtRdPtr)
      nxtLempty = 1'b0;
    else
      nxtLempty = empty;

  dff #(1) emptyReg (.q(empty), .clk(clk), .rst_n(rst_n), .d(nxtLempty));

  wire full;
  reg nxtLfull;

  always @(push or nxtRdPtr or nxtWrPtr or full)
    if ((nxtWrPtr == nxtRdPtr) & push)
      nxtLfull = 1'b1;
    else if (nxtWrPtr != nxtRdPtr)
      nxtLfull = 1'b0;
    else
      nxtLfull = full;

  dff #(1) fullReg (.q(full), .clk(clk), .rst_n(rst_n), .d(nxtLfull));

  // Write enable decodes

  wire en0 = push & (wrPtr == 2'd0);
  wire en1 = push & (wrPtr == 2'd1);
  wire en2 = push & (wrPtr == 2'd2);
  wire en3 = push & (wrPtr == 2'd3);

  // Data registers

  wire [DWIDTH-1:0] d0;
  wire [DWIDTH-1:0] d1;
  wire [DWIDTH-1:0] d2;
  wire [DWIDTH-1:0] d3;

  edff #(DWIDTH) d0Reg (.q(d0), .clk(clk), .rst_n(rst_n), .en(en0), .d(inData));
  edff #(DWIDTH) d1Reg (.q(d1), .clk(clk), .rst_n(rst_n), .en(en1), .d(inData));
  edff #(DWIDTH) d2Reg (.q(d2), .clk(clk), .rst_n(rst_n), .en(en2), .d(inData));
  edff #(DWIDTH) d3Reg (.q(d3), .clk(clk), .rst_n(rst_n), .en(en3), .d(inData));

  // Read output

  reg [DWIDTH-1:0] outData;

  always @(rdPtr or d0 or d1 or d2 or d3)
    case (rdPtr)
      2'd0 : outData = d0;
      2'd1 : outData = d1;
      2'd2 : outData = d2;
      2'd3 : outData = d3;
      default : outData = ZERO;
    endcase

  
  // Valid signal per data
  //&dren_reg 16,0 w-dValid r-dValidN w-updateDValid
  //Begin Perl:
  wire [4-1:0] dValid;
  reg  [4-1:0] dValidN;
  wire updateDValid;
  edff  #(4) dValidReg (.q(dValid), .clk(clk), .d(dValidN), .rst_n(rst_n), .en(updateDValid));
  //End Perl:
  
  assign updateDValid = push | pop;
  
  always @(/*AUTOSENSE*/dValid or pop or push or rdPtr or wrPtr) begin
    dValidN = dValid;
    if (push) dValidN[wrPtr] = 1'b1;
    if (pop)  dValidN[rdPtr] = 1'b0;
  end


  // ****************************************************************
  // Assertions
  // ****************************************************************

`ifdef ASSERT_ON

  // Test for overflow
  assert_never #(0, 0, "Fifo Overflow") fifo_overflow (clk, rst_n, push & full);

  // Test for underflow
  assert_never #(0, 0, "Fifo Underflow") fifo_underflow (clk, rst_n, pop & empty);

`endif

endmodule
