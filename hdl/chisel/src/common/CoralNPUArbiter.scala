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

package common

import chisel3._
import chisel3.util._

// This file contains a forked version of Chisel's `LockingRRArbiter` and
// `RRArbiter`. This forked version differs from Chisel's by initializing the
// lastGrant register to address X-Prop issues.

object CoralNPUArbiterCtrl {
  def apply(request: Seq[Bool]): Seq[Bool] = request.length match {
    case 0 => Seq()
    case 1 => Seq(true.B)
    case _ => true.B +: request.tail.init.scanLeft(request.head)(_ || _).map(!_)
  }
}

class InitedLockingRRArbiter[T <: Data](gen: T, n: Int, count: Int, needsLock: Option[T => Bool] = None)
    extends LockingArbiterLike[T](gen, n, count, needsLock) {
  lazy val lastGrant = RegInit(0.U(log2Ceil(n).W))
  lastGrant := Mux(io.out.fire, io.chosen, lastGrant)

  lazy val grantMask = (0 until n).map(_.asUInt > lastGrant)
  lazy val validMask = io.in.zip(grantMask).map { case (in, g) => in.valid && g }

  override def grant: Seq[Bool] = {
    val ctrl = CoralNPUArbiterCtrl((0 until n).map(i => validMask(i)) ++ io.in.map(_.valid))
    (0 until n).map(i => ctrl(i) && grantMask(i) || ctrl(i + n))
  }

  override lazy val choice = WireDefault((n - 1).asUInt)
  for (i <- n - 2 to 0 by -1)
    when(io.in(i).valid) { choice := i.asUInt }
  for (i <- n - 1 to 1 by -1)
    when(validMask(i)) { choice := i.asUInt }
}

class CoralNPURRArbiter[T <: Data](val gen: T, val n: Int, moduleName: Option[String] = None) extends InitedLockingRRArbiter[T](gen, n, 1) {
  override val desiredName = moduleName.getOrElse(super.desiredName)
}
