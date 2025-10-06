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

import chisel3._
import chisel3.util._

// Convert register port into a onehot w/wo stripmining.
object RegActive {
  def apply(m: Bool, step: UInt, regnum: UInt): UInt = {
    assert(step.getWidth == 3)
    assert(regnum.getWidth == 6)
    assert(step <= 4.U)

    val oh = UIntToOH(regnum(5,2), 16)

    val oh0 = Cat(0.U(3.W), oh(15),
                  0.U(3.W), oh(14),
                  0.U(3.W), oh(13),
                  0.U(3.W), oh(12),
                  0.U(3.W), oh(11),
                  0.U(3.W), oh(10),
                  0.U(3.W), oh(9),
                  0.U(3.W), oh(8),
                  0.U(3.W), oh(7),
                  0.U(3.W), oh(6),
                  0.U(3.W), oh(5),
                  0.U(3.W), oh(4),
                  0.U(3.W), oh(3),
                  0.U(3.W), oh(2),
                  0.U(3.W), oh(1),
                  0.U(3.W), oh(0))

    val oh1 = Cat(0.U(2.W), oh(15), 0.U(1.W),
                  0.U(2.W), oh(14), 0.U(1.W),
                  0.U(2.W), oh(13), 0.U(1.W),
                  0.U(2.W), oh(12), 0.U(1.W),
                  0.U(2.W), oh(11), 0.U(1.W),
                  0.U(2.W), oh(10), 0.U(1.W),
                  0.U(2.W), oh(9), 0.U(1.W),
                  0.U(2.W), oh(8), 0.U(1.W),
                  0.U(2.W), oh(7), 0.U(1.W),
                  0.U(2.W), oh(6), 0.U(1.W),
                  0.U(2.W), oh(5), 0.U(1.W),
                  0.U(2.W), oh(4), 0.U(1.W),
                  0.U(2.W), oh(3), 0.U(1.W),
                  0.U(2.W), oh(2), 0.U(1.W),
                  0.U(2.W), oh(1), 0.U(1.W),
                  0.U(2.W), oh(0), 0.U(1.W))

    val oh2 = Cat(0.U(1.W), oh(15), 0.U(2.W),
                  0.U(1.W), oh(14), 0.U(2.W),
                  0.U(1.W), oh(13), 0.U(2.W),
                  0.U(1.W), oh(12), 0.U(2.W),
                  0.U(1.W), oh(11), 0.U(2.W),
                  0.U(1.W), oh(10), 0.U(2.W),
                  0.U(1.W), oh(9), 0.U(2.W),
                  0.U(1.W), oh(8), 0.U(2.W),
                  0.U(1.W), oh(7), 0.U(2.W),
                  0.U(1.W), oh(6), 0.U(2.W),
                  0.U(1.W), oh(5), 0.U(2.W),
                  0.U(1.W), oh(4), 0.U(2.W),
                  0.U(1.W), oh(3), 0.U(2.W),
                  0.U(1.W), oh(2), 0.U(2.W),
                  0.U(1.W), oh(1), 0.U(2.W),
                  0.U(1.W), oh(0), 0.U(2.W))

    val oh3 = Cat(oh(15), 0.U(3.W),
                  oh(14), 0.U(3.W),
                  oh(13), 0.U(3.W),
                  oh(12), 0.U(3.W),
                  oh(11), 0.U(3.W),
                  oh(10), 0.U(3.W),
                  oh(9), 0.U(3.W),
                  oh(8), 0.U(3.W),
                  oh(7), 0.U(3.W),
                  oh(6), 0.U(3.W),
                  oh(5), 0.U(3.W),
                  oh(4), 0.U(3.W),
                  oh(3), 0.U(3.W),
                  oh(2), 0.U(3.W),
                  oh(1), 0.U(3.W),
                  oh(0), 0.U(3.W))

    assert(oh.getWidth == 16)
    assert(oh0.getWidth == 64)
    assert(oh1.getWidth == 64)
    assert(oh2.getWidth == 64)
    assert(oh3.getWidth == 64)

    val idx = regnum(1,0)

    val active = MuxOR(!m && idx === 0.U || m && step <= 0.U, oh0) |
                 MuxOR(!m && idx === 1.U || m && step <= 1.U, oh1) |
                 MuxOR(!m && idx === 2.U || m && step <= 2.U, oh2) |
                 MuxOR(!m && idx === 3.U || m && step <= 3.U, oh3)
    assert(active.getWidth == 64)

    active
  }
}

// Convert tagged address into register file format.
object OutTag {
  def apply(v: VAddrTag): UInt = {
    OutTag(v.addr, v.tag)
  }

  def apply(addr: UInt, tag: UInt): UInt = {
    assert(addr.getWidth == 6)
    assert(tag.getWidth == 4)
    tag(addr(1,0))
  }
}

object ScoreboardReady {
  def apply(a: VAddrTag, sb: UInt): Bool = {
    assert(a.addr.getWidth == 6)
    assert(a.tag.getWidth == 4)
    assert(sb.getWidth == 128)
    val tag = a.tag(a.addr(1,0))
    val idx = Cat(tag, a.addr)
    assert(idx.getWidth == 7)
    (!a.valid || !sb(idx))
  }
}
