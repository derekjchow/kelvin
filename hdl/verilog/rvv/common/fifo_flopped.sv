module fifo_flopped(
   // Outputs
   fifo_outData, fifo_full, fifo_empty, fifo_idle,
   // Inputs
   clk, rst_n, fifo_inData, single_push, single_pop
   );
   
    parameter DWIDTH = 32;
    parameter DEPTH = 16;

    function integer clogb2;
        input [31:0] depth;
        begin
            depth = depth - 1;
            for(clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
        end
    endfunction

    parameter AWIDTH = (DEPTH==1'b1) ? 1'b1 : clogb2(DEPTH);

    input clk;
    input rst_n;

    input [DWIDTH-1:0] fifo_inData;
    input single_push;
    input single_pop;

    output [DWIDTH-1:0] fifo_outData;
    output fifo_full;
    output fifo_empty;
    output fifo_idle;

    // Write pointer
    wire [AWIDTH-1:0] wrPtr;
    wire [AWIDTH-1:0] nxtWrPtr;
    assign nxtWrPtr = single_push 
                                 ? (
                                    ((wrPtr==(DEPTH-1)) && (DEPTH != 2**AWIDTH)) 
                                    ? 4'd0 
                                    : wrPtr + 1'b1
                                   ) 
                                 : wrPtr;

    edff #(AWIDTH) wrPtrReg (.q(wrPtr), .clk(clk), .rst_n(rst_n), .d(nxtWrPtr), .en(single_push));

    // Read pointer
    wire [AWIDTH-1:0] rdPtr;
    wire [AWIDTH-1:0] rdPtr_p1;
    assign rdPtr_p1 = (
                                  ((rdPtr==(DEPTH-1)) && (DEPTH != 2**AWIDTH)) 
                                   ? 4'd0 
                                   : rdPtr + 1'b1
                                 );
    wire [AWIDTH-1:0] nxtRdPtr;
    assign nxtRdPtr = single_pop ? rdPtr_p1 : rdPtr;

    edff #(AWIDTH) rdPtrReg (.q(rdPtr), .clk(clk), .rst_n(rst_n), .d(nxtRdPtr), .en(single_pop));

    // Write enable decodes
    wire [DEPTH-1:0] en;
    assign en = single_push ? ({{(DEPTH-1){1'b0}},1'b1} << wrPtr) : {DEPTH{1'b0}};   

    // Data registers

    wire [DEPTH*DWIDTH-1:0] d_in;
    assign d_in = {DEPTH{fifo_inData}};  
    wire [DEPTH*DWIDTH-1:0] d_out;  
    edff_2d #(
    .REGISTER_WIDTH(DWIDTH),
    .NUM_OF_REGISTERS(DEPTH)
    )
    dReg (.q(d_out), .clk(clk), .rst_n(rst_n), .en(en), .d(d_in));    

    // Read output    
    assign fifo_outData = d_out[DWIDTH*rdPtr+DWIDTH-1 -: DWIDTH];

    // fifo_idle.

    parameter AWIDTH_PLUS1 = AWIDTH+1;
    wire [AWIDTH_PLUS1-1:0] entryCounter;
    wire [AWIDTH_PLUS1-1:0] entryCounterN;
    wire count;
    edff  #(AWIDTH_PLUS1,0) entryCounterReg (.q(entryCounter), .clk(clk), .d(entryCounterN), .rst_n(rst_n), .en(count));
    
    assign count = single_push | single_pop;
    assign entryCounterN = entryCounter + single_push - single_pop;
    assign fifo_empty = (entryCounter == {AWIDTH_PLUS1{1'b0}});
    assign fifo_full = (entryCounter == DEPTH);
    assign fifo_idle = fifo_empty;

`ifdef ASSERT_ON
  `rvv_forbid(single_push&&fifo_full) 
    else $error("ERROR: Fifo Overflow! \n");

  `rvv_forbid(single_pop&&fifo_empty) 
    else $error("ERROR: Fifo Underflow! \n");
`endif
endmodule

