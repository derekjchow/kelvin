// Copyright 2025 Google LLC
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

`include "prim_assert.sv"

module tlul_host_upsizer
    #(parameter int AddrWidth = 32)
    (input clk_i,
     input rst_ni,

     // Slave (Host-facing) TL-UL Interface
     input kelvin_tlul_pkg_32::tl_h2d_t s_tl_i,
     output kelvin_tlul_pkg_32::tl_d2h_t s_tl_o,

     // Master (Crossbar-facing) TL-UL Interface
     output kelvin_tlul_pkg_128::tl_h2d_t m_tl_o,
     input kelvin_tlul_pkg_128::tl_d2h_t m_tl_i);

  localparam int SlaveDataWidth = 32;
  localparam int MasterDataWidth = 128;
  localparam int LaneWidth = SlaveDataWidth / 8;
  localparam int NumLanes = MasterDataWidth / SlaveDataWidth;
  localparam int LaneIndexWidth = $clog2(NumLanes);

  // Response path skid buffer
  kelvin_tlul_pkg_32::tl_d2h_t d_skid_reg;
  logic d_skid_valid_q, d_skid_valid_d;
  logic d_skid_ready;

  // Internal signals
  logic [LaneIndexWidth - 1 : 0] lane_idx;
  logic [LaneIndexWidth - 1 : 0] lane_idx_reg;
  logic [MasterDataWidth - 1 : 0] m_a_data;
  logic [MasterDataWidth / 8 - 1 : 0] m_a_mask;

  // Lane index calculation
  assign lane_idx = s_tl_i.a_address[LaneIndexWidth + 1 : 2];

  // Master port data and mask generation
  always_comb begin
    m_a_data = '0;
    m_a_mask = '0;
    m_a_data[lane_idx * SlaveDataWidth +: SlaveDataWidth] = s_tl_i.a_data;
    m_a_mask[lane_idx * LaneWidth +: LaneWidth] = s_tl_i.a_mask;
  end

  // Master port connections
  assign m_tl_o.a_valid = s_tl_i.a_valid;
  assign m_tl_o.a_opcode = s_tl_i.a_opcode;
  assign m_tl_o.a_param = s_tl_i.a_param;
  assign m_tl_o.a_size = s_tl_i.a_size;
  assign m_tl_o.a_address = {
             s_tl_i.a_address[AddrWidth - 1 : LaneIndexWidth + 2],
             {(LaneIndexWidth + 2){1'b0}}};
  assign m_tl_o.a_source = s_tl_i.a_source;
  assign m_tl_o.a_data = m_a_data;
  assign m_tl_o.a_mask = m_a_mask;
  assign m_tl_o.a_user = s_tl_i.a_user;
  assign m_tl_o.d_ready = d_skid_ready;

  // Slave port connections
  assign s_tl_o.d_opcode = d_skid_reg.d_opcode;
  assign s_tl_o.d_param = d_skid_reg.d_param;
  assign s_tl_o.d_sink = d_skid_reg.d_sink;
  assign s_tl_o.d_source = d_skid_reg.d_source;
  assign s_tl_o.d_data = d_skid_reg.d_data;
  assign s_tl_o.d_error = d_skid_reg.d_error;
  assign s_tl_o.d_user = d_skid_reg.d_user;
  assign s_tl_o.d_size = d_skid_reg.d_size;
  assign s_tl_o.d_valid = d_skid_valid_q;
  assign s_tl_o.a_ready = m_tl_i.a_ready;

  // Skid buffer logic
  assign d_skid_ready = !d_skid_valid_q || s_tl_i.d_ready;

  always_comb begin
    d_skid_valid_d = d_skid_valid_q;
    if (d_skid_ready) begin
      d_skid_valid_d = m_tl_i.d_valid;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      d_skid_valid_q <= 1'b0;
      d_skid_reg <= '0;
      lane_idx_reg <= '0;
    end else begin
      d_skid_valid_q <= d_skid_valid_d;
      if (d_skid_ready && m_tl_i.d_valid) begin
        d_skid_reg.d_opcode <= m_tl_i.d_opcode;
        d_skid_reg.d_param <= m_tl_i.d_param;
        d_skid_reg.d_sink <= m_tl_i.d_sink;
        d_skid_reg.d_source <= m_tl_i.d_source;
        d_skid_reg.d_data <= m_tl_i.d_data >> (lane_idx_reg * SlaveDataWidth);
        d_skid_reg.d_error <= m_tl_i.d_error;
        d_skid_reg.d_user <= m_tl_i.d_user;
        d_skid_reg.d_size <= m_tl_i.d_size;
      end
      if (s_tl_i.a_valid && s_tl_o.a_ready) begin
        lane_idx_reg <= lane_idx;
      end
    end
  end
endmodule