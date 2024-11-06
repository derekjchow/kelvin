// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module RstSync_tb;
  logic clk_i, rstn_i, clk_en, rstn_o, clk_o;
  logic [63 : 0] ticker = 0;
  int nfails = 0;

  localparam CLK_PERIOD = 10;
  localparam CLK_RUNNING_INTERVAL = CLK_PERIOD * 10;

  // Sample the ticker to ensure that the output clock is ticking.
  task automatic how_many_ticks
      (ref int ticks,
       input bit debug = 1'b1);
    logic [63 : 0] ticker_start, ticker_end;

    ticker_start = ticker;
    #(CLK_RUNNING_INTERVAL);
    ticker_end = ticker;

    ticks = (ticker_end - ticker_start);

    if (debug) begin
      $display("DEBUG: Ticker End = %0t, Start = %0t, Ticks = %0d",
               ticker_end, ticker_start, ticks);
    end
  endtask  // is_clock_running

  // Check if clock is running or stopped.
  task automatic check_clock
      (input bit is_running,
       ref int nfails);
    int ticks;

    how_many_ticks(ticks);
    if (is_running) begin
      if (ticks == 0) begin
        $display("ERROR: Clock stopped. Expected - running. Time = %0t",
                 $realtime);
        nfails++;
      end
    end else begin
      if (ticks != 0) begin
        $display("ERROR: Clock running. Expected - stopped, Time = %0t",
                 $realtime);
        nfails++;
      end
    end
  endtask

  initial begin
    clk_i = 1'b0;
    rstn_i = 1'b1;
    clk_en = 1'b1;

    fork
      begin : clk_gen
        forever
          #(CLK_PERIOD / 2) clk_i = ~clk_i;
      end

      begin : test
        int ticks;

        // Check clock stops when reset is asserted
        #5;
        rstn_i = 1'b0;
        #(CLK_PERIOD * 10);
        check_clock(1'b0, nfails);

        // Check clock ticks when reset is removed
        #5;
        rstn_i = 1'b1;
        #(CLK_PERIOD * 10);
        check_clock(1'b1, nfails);

        // Check if clock gating works
        #5;
        clk_en = 1'b0;
        #(CLK_PERIOD * 10);
        check_clock(1'b0, nfails);

        #5;
        clk_en = 1'b1;
        #(CLK_PERIOD * 10);
        check_clock(1'b1, nfails);

        $finish;
      end
    join
  end  // initial begin

  final
    if (nfails != 0)
      $display(" *** TEST FAILED *** ");
    else
      $display(" === TEST PASSED === ");

  RstSync dut(.clk_i,
              .rstn_i,
              .clk_en,
              .te(1'b0),

              .clk_o,
              .rstn_o);

  always @(posedge clk_o)
    ticker <= ticker + 1;
endmodule
