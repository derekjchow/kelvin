// description
// the multi_fifo is a sync fifo mmodule with some specified features
// features:
//    1. multi push at a time
//    2. multi pop at a time
//    3. parameterize push/pop number with arbitrary value
//    4. output all fifo data and sort them based on read pointer
//    5. output write pointer and read pointer
// constraints:
//    1. do not support push&pop when fifo is full

module multi_fifo
(
  // global
  clk,
  rst_n,
  // push side
  push,
  datain,
  full,
  almost_full,
  // pop side
  pop,
  dataout,
  empty,
  almost_empty,
  // fifo info
  clear,
  fifo_data,
  wptr,
  rptr
);
// ---parameter definition--------------------------------------------
  parameter type T = logic [7:0];  // data structure
  parameter M     = 4;            // push signal width
  parameter N     = 4;            // pop signal width
  parameter DEPTH = 16;           // fifo depth
  parameter POP_CLEAR = 1'b0;     // clear data once pop
  parameter ASYNC_RSTN = 1'b0;    // reset data
  
  localparam DEPTH_BITS = $clog2(DEPTH);

// ---port definition-------------------------------------------------
  input   logic             clk;
  input   logic             rst_n;
  input   logic [M-1:0]     push;   // M bits indicates M push operation(s). 
  input   T     [M-1:0]     datain;
  output  logic             full;
  output  logic [M-1:1]     almost_full;  // almost_full[1] - 1 entry to full
                                          // almost_full[2] - 2 entrys to full
                                          // almost_full[M-1] - (M-1) entry(s) to full
  input   logic [N-1:0]     pop;    // N bits indicates N pop operation(s).
  output  T     [N-1:0]     dataout;
  output  logic             empty;
  output  logic [N-1:1]     almost_empty; // almost_empty[1] - 1 entry to empty
                                          // almost_empty[2] - 2 entrys to empty
                                          // almost_empty[N-1] - (N-1) entry(s) to empty
  input   logic             clear;
  output  T     [DEPTH-1:0] fifo_data;    // sort based on rptr
  output  logic [DEPTH_BITS-1:0] wptr;    // write pointer
  output  logic [DEPTH_BITS-1:0] rptr;    // read pointer

// ---internal signal definition--------------------------------------
  T mem[DEPTH-1:0];

  logic        [DEPTH_BITS  :0] entry_count; // the number of occupied entry.
  logic        [DEPTH_BITS  :0] next_entry_count;
  logic        [DEPTH_BITS-1:0] push_count;
  logic        [DEPTH_BITS-1:0] pop_count;
  logic        [DEPTH_BITS-1:0] next_wptr;
  logic        [DEPTH_BITS-1:0] next_rptr;

  logic        [DEPTH_BITS-1:0] wind_rptr [DEPTH-1:0];
  logic        [DEPTH_BITS-1:0] wind_wptr [DEPTH-1:0];
// ---code start------------------------------------------------------
  genvar  i;  
  
  // wind back rptr/wptr
  generate
    for (i=0; i<DEPTH; i++) begin : gen_wind_ptr
      assign wind_rptr[i] = rptr+i;
      assign wind_wptr[i] = wptr+i;
    end
  endgenerate
  // dataout
  always_comb begin
    pop_count = '0;
    for (int j=0; j<N; j++) pop_count = pop_count + pop[j];
  end

  assign next_rptr = ({1'b0,rptr} + pop_count < DEPTH) ? rptr + pop_count
                                                : rptr + pop_count - DEPTH;
  cdffr #(.WIDTH(DEPTH_BITS)) u_rptr_reg (.q(rptr), .c(clear), .e(|pop), .d(next_rptr), .clk(clk), .rst_n(rst_n));

  generate
    for (i=0; i<N; i++) begin : gen_dataout
      assign dataout[i] = mem[wind_rptr[i]];
    end
  endgenerate

  // datain
  always_comb begin
    push_count = '0;
    for (int j=0; j<M; j++) push_count = push_count + push[j];
  end

  assign next_wptr = ({1'b0,wptr} + push_count < DEPTH) ? wptr + push_count
                                                 : wptr + push_count - DEPTH;
  cdffr #(.WIDTH(DEPTH_BITS)) u_wptr_reg (.q(wptr), .c(clear), .e(|push), .d(next_wptr), .clk(clk), .rst_n(rst_n));

  generate
  if (ASYNC_RSTN)
    always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n)
        for (int j=0; j<DEPTH; j++) begin 
          mem[j] <= '0;
        end
      else begin
        if (push[0] && !full) mem[wptr] <= datain[0];
        for (int j=1; j<M; j++) begin
          if (push[j] && !almost_full[j]) mem[wind_wptr[j]] <= datain[j];
        end

        if (POP_CLEAR) begin
          if (clear) begin
            for (int j=0; j<DEPTH; j++) begin 
              mem[j] <= '0;
            end
          end else begin
            for (int j=0; j<N; j++) begin
              if (pop[j]) mem[wind_rptr[j]] <= '0;
            end
          end
        end
      end
    end
  else
    always_ff @(posedge clk) begin
      if (push[0] && !full) mem[wptr] <= datain[0];
      for (int j=1; j<M; j++) begin
        if (push[j] && !almost_full[j]) mem[wind_wptr[j]] <= datain[j];
      end

      if (POP_CLEAR) begin
        if (clear) begin
          for (int j=0; j<DEPTH; j++) begin 
            mem[j] <= '0;
          end
        end else begin
          for (int j=0; j<N; j++) begin
            if (pop[j]) mem[wind_rptr[j]] <= '0;
          end
        end
      end

    end
  endgenerate

  // fifo status
  assign next_entry_count = entry_count + push_count - pop_count;
  wire entry_count_en = (|push) | (|pop);
  cdffr #(.WIDTH(DEPTH_BITS+1)) u_entry_count_reg (.q(entry_count), .c(clear), .e(entry_count_en), .d(next_entry_count), .clk(clk), .rst_n(rst_n));

  assign full = (entry_count == DEPTH);
  generate
    for (i=1; i<M; i++) begin : gen_almost_full
      assign almost_full[i] = (entry_count + i >= DEPTH);
    end
  endgenerate

  assign empty = (entry_count == '0);
  generate
    for (i=1; i<N; i++) begin : gen_almost_empty
      assign almost_empty[i] = (entry_count <= i);
    end
  endgenerate

  generate
    for (i=0; i<DEPTH; i++) begin : gen_fifo_data
      assign fifo_data[i] = mem[wind_rptr[i]];
    end
  endgenerate

  `ifdef ASSERT_ON
    // test for overflow
      assert property (@(posedge clk) disable iff (!rst_n) not ( push[0] && full))
        else $error("MULTI_FIFO: overflow of fifo when push[0] and full");
      generate
        for (i=1; i<M; i++) begin
          assert property (@(posedge clk) disable iff (!rst_n) not ( push[i] && almost_full[i]))
            else $error("MULTI_FIFO: overflow of fifo when push[%d] and almost_full[%d]", i, i);
        end
      endgenerate
    // test for underflow
      assert property (@(posedge clk) disable iff (!rst_n) not ( pop[0] && empty))
        else $error("MULTI_FIFO: underflow of fifo when pop[0] and empty");
      generate
        for (i=1; i<N; i++) begin
          assert property (@(posedge clk) disable iff (!rst_n) not ( pop[i] && almost_empty[i]))
            else $error("MULTI_FIFO: underflow of fifo when pop[%d] and almost_empty[%d]", i, i);
        end
      endgenerate
  `endif

endmodule
