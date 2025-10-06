/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package coralnpu

case class VDecodeOp() {
  // Format0
  val vadd = 0
  val vsub = 1
  val vrsub = 2
  val veq = 6
  val vne = 7
  val vlt = 8
  val vle = 10
  val vgt = 12
  val vge = 14
  val vabsd = 16
  val vmax = 18
  val vmin = 20
  val vadd3 = 24

  // Format1
  val vand = 0
  val vor = 1
  val vxor = 2
  val vnot = 3
  val vrev = 4
  val vror = 5
  val vclb = 8
  val vclz = 9
  val vcpop = 10
  val vmv = 12
  val vmvp = 13
  val acset = 16
  val actr = 17
  val adwinit = 18

  // Format2
  val vsll = 1
  val vsra = 2
  val vsrl = 3
  val vsha = 8
  val vshl = 9
  val vsrans = 16
  val vsraqs = 24

  // Format3
  val vmul = 0
  val vmuls = 2
  val vmulw = 4
  val vmulh = 8
  val vmulhu = 9
  val vdmulh = 16
  val vmacc = 20
  val vmadd = 21

  // Format4
  val vadds = 0
  val vsubs = 2
  val vaddw = 4
  val vsubw = 6
  val vacc = 10
  val vpadd = 12
  val vpsub = 14
  val vhadd = 16
  val vhsub = 20

  // Format6
  val vsliden = 0
  val vslidevn = 0
  val vslidehn = 4
  val vslidep = 8
  val vslidevp = 8
  val vslidehp = 12
  val vsel = 16
  val vevn = 24
  val vodd = 25
  val vevnodd = 26
  val vzip = 28

  // FormatVVV
  val aconv = 8
  val vdwconv = 10
}
