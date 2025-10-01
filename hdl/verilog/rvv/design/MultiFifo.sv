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

// A FIFO that can enqueue and dequeue multiple elements at a time.
module MultiFifo#(type T=logic [7:0],
                  parameter N = 4,
                  parameter MAX_CAPACITY=16,
                  parameter INTERFACE_BITS=$clog2(N+1),
                  parameter CAPACITYBITS=$clog2(MAX_CAPACITY+1))
(
  input clk,
  input rstn,

  // Command input.
  input logic [INTERFACE_BITS-1:0] valid_in,
  input T [N-1:0] data_in,

  // fill_level is used to determine if elements can be enqueued and dequeued.
  // valid_in must be <= MAX_CAPACITY - fill_level
  // ready_out must be <= fill_level
  output logic [CAPACITYBITS-1:0] fill_level,

  // Command output.
  output T [N-1:0] data_out,
  input logic [INTERFACE_BITS-1:0] ready_out
);
  typedef logic [CAPACITYBITS-1:0] buffer_ptr_t;
  typedef logic [CAPACITYBITS-1:0] buffer_size_t;

  // Module state
  buffer_ptr_t head;  // Elements to enqueue
  buffer_ptr_t tail;  // Elements to dequeue
  buffer_size_t m_fill_level;
  T [MAX_CAPACITY-1:0] buffer;

  function automatic buffer_ptr_t WrapAroundSum(buffer_ptr_t ptr,
                                                buffer_size_t sz);
      logic [CAPACITYBITS:0] sum;
      sum = ptr + sz;
      return (sum >= MAX_CAPACITY) ? (sum - MAX_CAPACITY) : sum;
  endfunction

  // Output fill_level
  always_comb begin
    fill_level = m_fill_level;
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      head <= 0;
      tail <= 0;
      m_fill_level <= 0;
    end else begin
      head <= WrapAroundSum(head, valid_in);
      tail <= WrapAroundSum(tail, ready_out);
      m_fill_level <= m_fill_level + valid_in - ready_out;
    end
  end

  always_ff @(posedge clk) begin
    // Update buffer
    for (int i = 0; i < N; i++) begin
      if (i < valid_in) begin
        buffer[WrapAroundSum(head, i)] <= data_in[i];
      end
    end
  end

  always_comb begin
    for (int i = 0; i < N; i++) begin
      data_out[i] = buffer[WrapAroundSum(tail, i)];
    end
  end

  // Assertions
`ifndef SYNTHESIS
  always @(posedge clk) begin
    // Producer should enqueue less than what's empty
    assert (valid_in <= (MAX_CAPACITY - m_fill_level)) else
        $error("Trying to enqueue ", valid_in, " elements ",
               (MAX_CAPACITY - m_fill_level), " free");

    // Consumer should dequeue less than what's full
    assert (ready_out <= m_fill_level) else
        $error("Trying to dequeue ", ready_out, " elements ", m_fill_level,
               " free");
  end
`endif  // not def SYNTHESIS

endmodule