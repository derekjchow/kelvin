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

module TlulAdapterSram
import prim_mubi_pkg::mubi4_t;
(
  input clk_i,
  input rst_ni,
  input tl_i_a_valid,
  input [2:0] tl_i_a_opcode,
  input [2:0] tl_i_a_param,
  input [5:0] tl_i_a_size,
  input [9:0] tl_i_a_source,
  input [31:0] tl_i_a_address,
  input [31:0] tl_i_a_mask,
  input [255:0] tl_i_a_data,
  input [4:0] tl_i_a_user_rsvd,
  input [3:0] tl_i_a_user_instr_type,
  input [6:0] tl_i_a_user_cmd_intg,
  input [6:0] tl_i_a_user_data_intg,
  input tl_i_d_ready,
  input [3:0] en_ifetch_i,
  input gnt_i,
  input [255:0] rdata_i,
  input rvalid_i,
  input [1:0] rerror_i,
  output tl_o_d_valid,
  output [2:0] tl_o_d_opcode,
  output [2:0] tl_o_d_param,
  output [5:0] tl_o_d_size,
  output [9:0] tl_o_d_source,
  output tl_o_d_sink,
  output [255:0] tl_o_d_data,
  output [6:0] tl_o_d_user_rsp_intg,
  output [6:0] tl_o_d_user_data_intg,
  output tl_o_d_error,
  output tl_o_a_ready,
  output req_o,
  output [3:0] req_type_o,
  output we_o,
  output [16:0] addr_o,
  output [255:0] wdata_o,
  output [255:0] wmask_o,
  output intg_error_o
);

mubi4_t en_ifetch_i_ = mubi4_t'(en_ifetch_i);

tlul_adapter_sram #(
  .SramAw(17),
  .SramDw(256),
  .Outstanding(1),
  .ByteAccess(1),
  .ErrOnRead(0),
  .EnableDataIntgPt(0)
) u_tlul_adapter_sram (
  .clk_i(clk_i),
  .rst_ni(rst_ni),
  .tl_i(
    {
        tl_i_a_valid,
        tl_i_a_opcode,
        tl_i_a_param,
        tl_i_a_size,
        tl_i_a_source,
        tl_i_a_address,
        tl_i_a_mask,
        tl_i_a_data,
        tl_i_a_user_rsvd,
        tl_i_a_user_instr_type,
        tl_i_a_user_cmd_intg,
        tl_i_a_user_data_intg,
        tl_i_d_ready
    }),
  .tl_o({
    tl_o_d_valid,
    tl_o_d_opcode,
    tl_o_d_param,
    tl_o_d_size,
    tl_o_d_source,
    tl_o_d_sink,
    tl_o_d_data,
    tl_o_d_user_rsp_intg,
    tl_o_d_user_data_intg,
    tl_o_d_error,
    tl_o_a_ready
  }),
  .en_ifetch_i(en_ifetch_i_),
  .req_o(req_o),
  .req_type_o(req_type_o),
  .gnt_i(gnt_i),
  .we_o(we_o),
  .addr_o(addr_o),
  .wdata_o(wdata_o),
  .wmask_o(wmask_o),
  .intg_error_o(intg_error_o),
  .rdata_i(rdata_i),
  .rvalid_i(rvalid_i),
  .rerror_i(rerror_i)
);

endmodule