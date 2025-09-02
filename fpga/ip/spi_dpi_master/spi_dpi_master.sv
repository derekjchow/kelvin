// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module spi_dpi_master (
  input  logic clk_i,
  input  logic rst_ni,
  output logic sck_o,
  output logic csb_o,
  output logic mosi_o,
  input  logic miso_i
);

  import "DPI-C" function chandle spi_dpi_init();
  import "DPI-C" function void spi_dpi_close(chandle c_context);
  import "DPI-C" function void spi_dpi_reset(chandle c_context);

  chandle c_context;

  // These are driven by the C++ DPI code
  logic sck_q;
  logic csb_q;
  logic mosi_q;

  assign sck_o = sck_q;
  assign csb_o = csb_q;
  assign mosi_o = mosi_q;

  initial begin
    c_context = spi_dpi_init();
  end


  import "DPI-C" task spi_dpi_tick(
    chandle c_context,
    output bit sck,
    output bit csb,
    output bit mosi,
    input  bit miso
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      spi_dpi_reset(c_context);
      sck_q <= 1'b0;
      csb_q <= 1'b1;
      mosi_q <= 1'b0;
    end else begin
      // Use intermediate variables for the DPI task outputs
      bit sck_next, csb_next, mosi_next;
      spi_dpi_tick(c_context, sck_next, csb_next, mosi_next, miso_i);
      // Use non-blocking assignments to update the state
      sck_q <= sck_next;
      csb_q <= csb_next;
      mosi_q <= mosi_next;
    end
  end

  final begin
    spi_dpi_close(c_context);
  end

endmodule
