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

import chisel3.util.log2Ceil

// Opcode list will maintain unique IDs even if not populated in command queue.
case class VEncodeOp() {
  val undef       = 0

  // Duplicate
  val vdup        = 1

  // Load/Store
  val vld         = 2
  val vst         = 3
  val vstq        = 4

  // Misc
  val vcget       = 5

  // Format0
  val vadd        = 6
  val vsub        = 7
  val vrsub       = 8
  val veq         = 9
  val vne         = 10
  val vlt         = 11
  val vle         = 12
  val vgt         = 13
  val vge         = 14
  val vabsd       = 15
  val vmax        = 16
  val vmin        = 17
  val vadd3       = 18

  // Format1
  val vand        = 19
  val vor         = 20
  val vxor        = 21
  val vnot        = 22
  val vrev        = 23
  val vror        = 24
  val vclb        = 25
  val vclz        = 26
  val vcpop       = 27
  val vmv         = 28
  val vmv2        = 29
  val vmvp        = 30
  val acset       = 31
  val actr        = 32
  val adwinit     = 33

  // Format2
  val vshl        = 34
  val vshr        = 35
  val vshf        = 36
  val vsrans      = 37
  val vsraqs      = 38

  // Format3
  val vmul        = 39
  val vmul2       = 40
  val vmuls       = 41
  val vmuls2      = 42
  val vmulh       = 43
  val vmulh2      = 44
  val vdmulh      = 45
  val vdmulh2     = 46
  val vmulw       = 47
  val vmadd       = 48

  // Format4
  val vadds       = 49
  val vsubs       = 50
  val vaddw       = 51
  val vsubw       = 52
  val vacc        = 53
  val vpadd       = 54
  val vpsub       = 55
  val vhadd       = 56
  val vhsub       = 57

  // Format6
  val vslidevn    = 58
  val vslidehn    = 59
  val vslidehn2   = 60
  val vslidevp    = 61
  val vslidehp    = 62
  val vslidehp2   = 63
  val vsel        = 64
  val vevn        = 65
  val vodd        = 66
  val vevnodd     = 67
  val vzip        = 68

  // FormatVVV
  val aconv       = 69
  val vdwconv     = 70
  val adwconv     = 71

  // Entries
  val entries     = 72
  val bits = log2Ceil(entries)
}
