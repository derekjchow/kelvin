// Copyright 2023 Google LLC
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

module ClockGate(
  input         clk_i,
  input         enable,  // '1' passthrough, '0' disable.
  output        clk_o
);

prim_clock_gating u_cg(
  .clk_i(clk_i),
  .en_i(enable),
  .test_en_i('0),
  .clk_o(clk_o)
);

endmodule  // ClockGate
