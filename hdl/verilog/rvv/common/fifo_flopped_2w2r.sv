module fifo_flopped_2w2r(/*AUTOARG*/
   // Outputs
   outData0, outData1, fifo_halfFull, fifo_full, fifo_1left_to_full,
   fifo_empty, fifo_1left_to_empty, fifo_idle,
   // Inputs
   clk, rst_n, push0, inData0, push1, inData1, pop0, pop1
   );

parameter DWIDTH = 32;
parameter DEPTH = 8;
parameter DEPTH_SUB = 4;//half of DEPTH


// global signal
  input clk;
  input rst_n;
// write
  input logic  push0;
  input logic [DWIDTH-1:0] inData0;
  input logic  push1;
  input logic [DWIDTH-1:0] inData1;
// read
  input logic  pop0;
  output logic [DWIDTH-1:0] outData0;
  input logic  pop1;
  output logic [DWIDTH-1:0] outData1;
// fifo status
  output logic fifo_halfFull;
  output logic fifo_full;
  output logic fifo_1left_to_full;
  output logic fifo_empty;
  output logic fifo_1left_to_empty;
  output logic fifo_idle;

// Wires & Regs
wire push0_int;
wire [DWIDTH-1:0] inData0_int;
wire push1_int;
wire [DWIDTH-1:0] inData1_int;
wire pop0_int;
wire [DWIDTH-1:0] outData0_int;
wire pop1_int;
wire [DWIDTH-1:0] outData1_int;
wire full0_int;
wire full1_int;
wire empty0_int;
wire empty1_int;
wire halfFull0_int;
wire halfFull1_int;
wire idle0_int;
wire idle1_int;

//Push arbitration
wire pushSwapFlag;
wire pushSwapFlag_nxt;
wire single_push = push0 && !push1;
assign pushSwapFlag_nxt = single_push ? !pushSwapFlag : pushSwapFlag;
edff #(1) pushSwapFlagReg (.q(pushSwapFlag), .clk(clk), .rst_n(rst_n), .d(pushSwapFlag_nxt), .en(push0||push1));

assign {push1_int,push0_int}     = pushSwapFlag ? {push0,push1}     : {push1,push0};
assign {inData1_int,inData0_int} = pushSwapFlag ? {inData0,inData1} : {inData1,inData0};

//Pop arbitration
wire popSwapFlag;
wire popSwapFlag_nxt;
wire single_pop = pop0 && !pop1;
assign popSwapFlag_nxt = single_pop ? !popSwapFlag : popSwapFlag;
edff #(1) popSwapReg (.q(popSwapFlag), .clk(clk), .rst_n(rst_n), .d(popSwapFlag_nxt), .en(pop0||pop1));

assign {pop1_int,pop0_int} = popSwapFlag ? {pop0,pop1}               : {pop1,pop0};
assign {outData1,outData0} = popSwapFlag ? {outData0_int,outData1_int} : {outData1_int,outData0_int};

// Full flag
assign fifo_full = full0_int && full1_int;
assign fifo_1left_to_full = (full0_int && !full1_int) || (!full0_int && full1_int);

assign fifo_halfFull = halfFull1_int && halfFull0_int;

// Empty flag
assign fifo_empty = empty1_int && empty0_int;
assign fifo_1left_to_empty = (empty0_int && !empty1_int) || (!empty0_int && empty1_int); 
assign fifo_idle = idle1_int && idle0_int;

// Fifo inst even
// Entry 0, 2, 4, 6, 8, ...
fifo_flopped #(DWIDTH,DEPTH_SUB) fifo_even (
  //Outputs
  .outData(outData0_int), 
  .full(full0_int), 
  .empty(empty0_int), 
  .halfFull(halfFull0_int), 
  .idle(idle0_int),
  //Inputs
  .clk(clk), 
  .rst_n(rst_n), 
  .inData(inData0_int), 
  .push(push0_int), 
  .pop(pop0_int));

// Fifo inst odd
// Entry 1, 3, 5, 7, 9, ...
fifo_flopped #(DWIDTH,DEPTH_SUB) fifo_odd (
  //Outputs
  .outData(outData1_int), 
  .full(full1_int), 
  .empty(empty1_int), 
  .halfFull(halfFull1_int), 
  .idle(idle1_int),
  //Inputs
  .clk(clk), 
  .rst_n(rst_n), 
  .inData(inData1_int), 
  .push(push1_int), 
  .pop(pop1_int));


endmodule
