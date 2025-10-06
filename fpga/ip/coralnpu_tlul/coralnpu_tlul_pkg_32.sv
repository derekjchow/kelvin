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

package coralnpu_tlul_pkg_32;

  import tlul_pkg::*;
  import top_pkg::*;

  typedef struct packed {
    logic a_valid;
    tl_a_op_e a_opcode;
    logic [2 : 0] a_param;
    logic [TL_SZW - 1 : 0] a_size;
    logic [TL_AIW - 1 : 0] a_source;
    logic [TL_AW - 1 : 0] a_address;
    logic [TL_DBW - 1 : 0] a_mask;
    logic [TL_DW - 1 : 0] a_data;
    tl_a_user_t a_user;
    logic d_ready;
  } tl_h2d_t;

  typedef struct packed {
    logic d_valid;
    tl_d_op_e d_opcode;
    logic [2 : 0] d_param;
    logic [TL_SZW - 1 : 0] d_size;
    logic [TL_AIW - 1 : 0] d_source;
    logic [TL_DIW - 1 : 0] d_sink;
    logic [TL_DW - 1 : 0] d_data;
    tl_d_user_t d_user;
    logic d_error;
    logic a_ready;
  } tl_d2h_t;
endpackage
