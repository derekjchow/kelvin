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

package coralnpu

class MatchaParameters(m: Seq[MemoryRegion] = Seq(),
        hartId: Int = 2) extends Parameters(m, hartId) {

  // Debug
  // tl_main_pkg::ADDR_SPACE_DBG + dm::HaltAddress
  val dbgBase = 0x4000
  val haltAddress = 0x800
  val dmHaltAddress = dbgBase + haltAddress

}
