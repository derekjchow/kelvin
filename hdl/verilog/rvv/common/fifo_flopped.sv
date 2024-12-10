module fifo_flopped(/*AUTOARG*/
   // Outputs
   outData, full, empty, halfFull, idle,
   // Inputs
   clk, rst_n, inData, push, pop
   );
   
    parameter DWIDTH = 32;
    parameter DEPTH = 16;
    parameter HALF_FULL = 0;

    function integer clogb2;
        input [31:0] depth;
        begin
            depth = depth - 1;
            for(clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
        end
    endfunction

    parameter AWIDTH = clogb2(DEPTH);

    input clk;
    input rst_n;

    input [DWIDTH-1:0] inData;
    input push;
    input pop;

    output [DWIDTH-1:0] outData;
    output full;
    output empty;
    output halfFull;
    output idle;

    // Write pointer
    wire [AWIDTH-1:0] wrPtr;
    wire [AWIDTH-1:0] nxtWrPtr;
    assign nxtWrPtr = push 
                                 ? (
                                    ((wrPtr==(DEPTH-1)) && (DEPTH != 2**AWIDTH)) 
                                    ? 4'd0 
                                    : wrPtr + 1'b1
                                   ) 
                                 : wrPtr;

    edff #(AWIDTH) wrPtrReg (.q(wrPtr), .clk(clk), .rst_n(rst_n), .d(nxtWrPtr), .en(push));

    // Read pointer
    wire [AWIDTH-1:0] rdPtr;
    wire [AWIDTH-1:0] rdPtr_p1;
    assign rdPtr_p1 = (
                                  ((rdPtr==(DEPTH-1)) && (DEPTH != 2**AWIDTH)) 
                                   ? 4'd0 
                                   : rdPtr + 1'b1
                                 );
    wire [AWIDTH-1:0] nxtRdPtr;
    assign nxtRdPtr = pop ? rdPtr_p1 : rdPtr;

    edff #(AWIDTH) rdPtrReg (.q(rdPtr), .clk(clk), .rst_n(rst_n), .d(nxtRdPtr), .en(pop));

    // Write enable decodes
    wire [DEPTH-1:0] en;
    assign en = push ? ({{(DEPTH-1){1'b0}},1'b1} << wrPtr) : {DEPTH{1'b0}};   

    // Data registers

    wire [DEPTH*DWIDTH-1:0] d_in;
    assign d_in = {DEPTH{inData}};  
    wire [DEPTH*DWIDTH-1:0] d_out;  
    edff_2d #(
    .REGISTER_WIDTH(DWIDTH),
    .NUM_OF_REGISTERS(DEPTH)
    )
    dReg (.q(d_out), .clk(clk), .rst_n(rst_n), .en(en), .d(d_in));    

    // Read output    

    wire [DWIDTH-1:0] outDataCurr;
    assign outDataCurr = d_out[DWIDTH*rdPtr+DWIDTH-1 -: DWIDTH];    

    wire [DWIDTH-1:0] outData;
    assign outData = outDataCurr;

    // Idle.

    parameter AWIDTH_PLUS1 = AWIDTH+1;
    //&dren_reg AWIDTH_PLUS1,0 w-entryCounter w-entryCounterN w-count
    //Begin Perl:
    wire [AWIDTH_PLUS1-1:0] entryCounter;
    wire [AWIDTH_PLUS1-1:0] entryCounterN;
    wire count;
    edff  #(AWIDTH_PLUS1,0) entryCounterReg (.q(entryCounter), .clk(clk), .d(entryCounterN), .rst_n(rst_n), .en(count));
    //End Perl:
    assign count = push | pop;
    assign entryCounterN = entryCounter + push - pop;
    wire halfFull;
    assign halfFull = (entryCounter >= HALF_FULL);
    wire empty;
    assign empty = (entryCounter == {AWIDTH_PLUS1{1'b0}});
    wire full;
    assign full = (entryCounter == DEPTH);
    wire idle;
    assign idle = empty;

    // ****************************************************************
    // Assertions
    // ****************************************************************

    `ifdef ASSERT_ON

    // Test for overflow
    assert_never #(0, 0, "Fifo Overflow") fifo_overflow (clk, rst_n, push & full & ~pop);

    // Test for underflow
    assert_never #(0, 0, "Fifo Underflow") fifo_underflow (clk, rst_n, pop & empty);

    `endif

endmodule

