// Copyright 2024 Google LLC
// Copyright lowRISC contributors
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

package top_pkg;

localparam int TL_AW=32;
localparam int TL_DW=256;    // = TL_DBW * 8; TL_DBW must be a power-of-two
localparam int TL_AIW=10;    // a_source, d_source
localparam int TL_DIW=1;    // d_sink
localparam int TL_AUW=21;   // a_user
localparam int TL_DUW=14;   // d_user
localparam int TL_DBW=(TL_DW>>3);
localparam int TL_SZW=6;

endpackage
