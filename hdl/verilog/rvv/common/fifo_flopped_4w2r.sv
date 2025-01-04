module fifo_flopped_4w2r(
   // Outputs
   outData0, outData1, fifo_full, fifo_1left_to_full,
   fifo_2left_to_full, fifo_3left_to_full, fifo_empty,
   fifo_1left_to_empty, fifo_idle,
   // Inputs
   clk, rst_n, push0, inData0, push1, inData1, push2, inData2, push3,
   inData3, pop0, pop1
   );

parameter DWIDTH = 32;
parameter DEPTH = 8;
parameter DEPTH_SUB = DEPTH/4;//half of DEPTH

// global signal
  input clk;
  input rst_n;
// write
  input logic  push0;
  input logic [DWIDTH-1:0] inData0;
  input logic  push1;
  input logic [DWIDTH-1:0] inData1;
  input logic  push2;
  input logic [DWIDTH-1:0] inData2;
  input logic  push3;
  input logic [DWIDTH-1:0] inData3;

// read
  input logic  pop0;
  output logic [DWIDTH-1:0] outData0;
  input logic  pop1;
  output logic [DWIDTH-1:0] outData1;
// fifo status
  output logic fifo_full;
  output logic fifo_1left_to_full;
  output logic fifo_2left_to_full;
  output logic fifo_3left_to_full;
  output logic fifo_empty;
  output logic fifo_1left_to_empty;
  output logic fifo_idle;

// Wires & Regs
reg push0_int;
reg [DWIDTH-1:0] inData0_int;
reg push1_int;
reg [DWIDTH-1:0] inData1_int;
reg push2_int;
reg [DWIDTH-1:0] inData2_int;
reg push3_int;
reg [DWIDTH-1:0] inData3_int;
reg pop0_int;
wire [DWIDTH-1:0] outData0_int;
reg pop1_int;
wire [DWIDTH-1:0] outData1_int;
reg pop2_int;
wire [DWIDTH-1:0] outData2_int;
reg pop3_int;
wire [DWIDTH-1:0] outData3_int;
wire full0_int;
wire full1_int;
wire full2_int;
wire full3_int;
wire empty0_int;
wire empty1_int;
wire empty2_int;
wire empty3_int;
wire idle0_int;
wire idle1_int;
wire idle2_int;
wire idle3_int;

//Push arbitration
wire [1:0] push_startFifo_id;
wire [1:0] push_startFifo_id_nxt;

wire single_push = push0 && !push1 && !push2 && !push3;
wire double_push = push0 &&  push1 && !push2 && !push3;
wire triple_push = push0 &&  push1 &&  push2 && !push3;

assign push_startFifo_id_nxt = single_push ? push_startFifo_id + 2'd1 : 
                               double_push ? push_startFifo_id + 2'd2 :
                               triple_push ? push_startFifo_id + 2'd3 : push_startFifo_id;                            
edff #(2) pushStartFifoIDReg (
  .q     (push_startFifo_id           ), 
  .clk   (clk                         ), 
  .rst_n (rst_n                       ), 
  .d     (push_startFifo_id_nxt       ), 
  .en    ((push0||push1||push2||push3))
`ifdef TB_SUPPORT
  ,.init_data('0)
`endif
  );

always@(*) begin
  case (push_startFifo_id) 
    2'd0 : begin
      {push3_int,push2_int,push1_int,push0_int} = {push3,push2,push1,push0};
      {inData3_int,inData2_int,inData1_int,inData0_int} = {inData3,inData2,inData1,inData0};
    end
    2'd1 : begin
      {push3_int,push2_int,push1_int,push0_int} = {push2,push1,push0,push3};
      {inData3_int,inData2_int,inData1_int,inData0_int} = {inData2,inData1,inData0,inData3};
    end
    2'd2 : begin
      {push3_int,push2_int,push1_int,push0_int} = {push1,push0,push3,push2};
      {inData3_int,inData2_int,inData1_int,inData0_int} = {inData1,inData0,inData3,inData2};
    end
    2'd3 : begin
      {push3_int,push2_int,push1_int,push0_int} = {push0,push3,push2,push1};
      {inData3_int,inData2_int,inData1_int,inData0_int} = {inData0,inData3,inData2,inData1};
    end
    default : begin
      {push3_int,push2_int,push1_int,push0_int} = {push3,push2,push1,push0};
      {inData3_int,inData2_int,inData1_int,inData0_int} = {inData3,inData2,inData1,inData0};
    end
  endcase
end

//Pop arbitration
wire [1:0] pop_startFifo_id;
wire [1:0] pop_startFifo_id_nxt;

wire single_pop = pop0 && !pop1;
assign pop_startFifo_id_nxt = single_pop ? pop_startFifo_id + 2'd1 : pop_startFifo_id + 2'd2;

edff #(2) popStartFifoIDReg (
  .q     (pop_startFifo_id            ), 
  .clk   (clk                         ), 
  .rst_n (rst_n                       ), 
  .d     (pop_startFifo_id_nxt        ), 
  .en    (pop0||pop1                  )
`ifdef TB_SUPPORT
  ,.init_data('0)
`endif
);

always@(*) begin
  case (pop_startFifo_id) 
    2'd0 : begin
      {pop3_int,pop2_int,pop1_int,pop0_int} = {1'b0,1'b0,pop1,pop0};
      {outData1,outData0} = {outData1_int,outData0_int};
    end
    2'd1 : begin
      {pop3_int,pop2_int,pop1_int,pop0_int} = {1'b0,pop1,pop0,1'b0};
      {outData1,outData0} = {outData2_int,outData1_int};
    end
    2'd2 : begin
      {pop3_int,pop2_int,pop1_int,pop0_int} = {pop1,pop0,1'b0,1'b0};
      {outData1,outData0} = {outData3_int,outData2_int};
    end
    2'd3 : begin
      {pop3_int,pop2_int,pop1_int,pop0_int} = {pop0,1'b0,1'b0,pop1};
      {outData1,outData0} = {outData0_int,outData3_int};
    end
    default : begin
      {pop3_int,pop2_int,pop1_int,pop0_int} = {1'b0,1'b0,pop1,pop0};
      {outData1,outData0} = {outData1_int,outData0_int};
    end
  endcase
end

// Full flag
assign fifo_full = full3_int && full2_int && full1_int && full0_int;
assign fifo_1left_to_full = (!full3_int &&  full2_int &&  full1_int &&  full0_int) || 
                            ( full3_int && !full2_int &&  full1_int &&  full0_int) || 
                            ( full3_int &&  full2_int && !full1_int &&  full0_int) || 
                            ( full3_int &&  full2_int &&  full1_int && !full0_int);

assign fifo_2left_to_full = (!full3_int && !full2_int &&  full1_int &&  full0_int) ||
                            ( full3_int && !full2_int && !full1_int &&  full0_int) ||
                            ( full3_int &&  full2_int && !full1_int && !full0_int) ||
                            (!full3_int &&  full2_int &&  full1_int && !full0_int);

assign fifo_3left_to_full = (!full3_int && !full2_int && !full1_int &&  full0_int) || 
                            ( full3_int && !full2_int && !full1_int && !full0_int) || 
                            (!full3_int &&  full2_int && !full1_int && !full0_int) || 
                            (!full3_int && !full2_int &&  full1_int && !full0_int);


// Empty flag
assign fifo_empty = empty3_int && empty2_int && empty1_int && empty0_int;
assign fifo_1left_to_empty = (!empty3_int &&  empty2_int &&  empty1_int &&  empty0_int) || 
                             ( empty3_int && !empty2_int &&  empty1_int &&  empty0_int) || 
                             ( empty3_int &&  empty2_int && !empty1_int &&  empty0_int) || 
                             ( empty3_int &&  empty2_int &&  empty1_int && !empty0_int); 
assign fifo_idle = idle3_int && idle2_int && idle1_int && idle0_int;

// Fifo inst 0
// Entry 0, 4, 8, 12 ...
fifo_flopped #(DWIDTH,DEPTH_SUB) fifo_inst0 (
  //Outputs
  .fifo_outData(outData0_int), 
  .fifo_full(full0_int), 
  .fifo_empty(empty0_int), 
  .fifo_idle(idle0_int),
  //Inputs
  .clk(clk), 
  .rst_n(rst_n), 
  .fifo_inData(inData0_int), 
  .single_push(push0_int), 
  .single_pop(pop0_int));

// Fifo inst 1
// Entry 1, 5, 9, 13 ...
fifo_flopped #(DWIDTH,DEPTH_SUB) fifo_inst1 (
  //Outputs
  .fifo_outData(outData1_int), 
  .fifo_full(full1_int), 
  .fifo_empty(empty1_int), 
  .fifo_idle(idle1_int),
  //Inputs
  .clk(clk), 
  .rst_n(rst_n), 
  .fifo_inData(inData1_int), 
  .single_push(push1_int), 
  .single_pop(pop1_int));

// Fifo inst 2
// Entry 2, 6, 10, 14 ...
fifo_flopped #(DWIDTH,DEPTH_SUB) fifo_inst2 (
  //Outputs
  .fifo_outData(outData2_int), 
  .fifo_full(full2_int), 
  .fifo_empty(empty2_int), 
  .fifo_idle(idle2_int),
  //Inputs
  .clk(clk), 
  .rst_n(rst_n), 
  .fifo_inData(inData2_int), 
  .single_push(push2_int), 
  .single_pop(pop2_int));

// Fifo inst 3
// Entry 3, 7, 11, 15 ...
fifo_flopped #(DWIDTH,DEPTH_SUB) fifo_inst3 (
  //Outputs
  .fifo_outData(outData3_int), 
  .fifo_full(full3_int), 
  .fifo_empty(empty3_int), 
  .fifo_idle(idle3_int),
  //Inputs
  .clk(clk), 
  .rst_n(rst_n), 
  .fifo_inData(inData3_int), 
  .single_push(push3_int), 
  .single_pop(pop3_int));

`ifdef ASSERT_ON
  `rvv_expect(({push3,push2,push1,push0}) inside {4'b1111, 4'b0111, 4'b0011, 4'b0001, 4'b0000})
    else $error("ERROR: Push 4w2r fifo out-of-order: %4b", $sampled({push3,push2,push1,push0}));

  `rvv_expect(({pop1,pop0}) inside {2'b11, 2'b01, 2'b00})
    else $error("ERROR: Pop 4w2r fifo out-of-order: %2b", $sampled({pop1,pop0}));
`endif

endmodule
