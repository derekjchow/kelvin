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
                  parameter MAX_CAPACITY=16)
(
  input clk,
  input rstn,

  // Command input.
  input logic [$clog2(N+1)-1:0] valid_in,
  input T [N-1:0] data_in,
  output logic [$clog2(N+1)-1:0] ready_in,

  output logic [$clog2(MAX_CAPACITY+1)-1:0] capacity,

  // Command output.
  output logic [$clog2(N+1)-1:0] valid_out,
  output T [N-1:0] data_out,
  input logic [$clog2(N+1)-1:0] ready_out
);
  localparam CAPACITYBITS = $clog2(MAX_CAPACITY+1);
  typedef logic [CAPACITYBITS-1:0] buffer_ptr_t;
  typedef logic [CAPACITYBITS-1:0] buffer_size_t;

  // Module state
  buffer_ptr_t head;  // Elements to enqueue
  buffer_ptr_t tail;  // Elements to dequeue
  buffer_size_t m_capacity;
  T [MAX_CAPACITY-1:0] buffer;

  function buffer_ptr_t WrapAroundSum(buffer_ptr_t ptr, buffer_size_t sz);
      logic [CAPACITYBITS:0] sum;
      sum = ptr + sz;
      return (sum >= MAX_CAPACITY) ? (sum - MAX_CAPACITY) : sum;
  endfunction

  buffer_size_t n_in;  // Number of elements to enqueue this cycle.
  buffer_size_t n_out;  // Number of elements to dequeue this cycle.
  always_comb begin
    // Enqueue logic
    ready_in = ((MAX_CAPACITY - m_capacity) > N) ? N : (MAX_CAPACITY - m_capacity);
    n_in = (ready_in < valid_in) ? ready_in : valid_in;

    // Dequeue logic
    valid_out = (m_capacity > N) ? N : m_capacity;
    n_out = (ready_out < valid_out) ? ready_out : valid_out;

    // Outputs
    capacity = m_capacity;
  end

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      head <= 0;
      tail <= 0;
      m_capacity <= 0;
    end else begin
      head <= WrapAroundSum(head, n_in);
      tail <= WrapAroundSum(tail, n_out);

      // Update buffer
      for (int i = 0; i < N; i++) begin
        if (i < n_in) begin
          buffer[WrapAroundSum(head, i)] <= data_in[i];
        end
      end
      m_capacity <= m_capacity + n_in - n_out;
    end
  end

  always_comb begin
    for (int i = 0; i < N; i++) begin
      data_out[i] = buffer[WrapAroundSum(tail, i)];
    end
  end

endmodule