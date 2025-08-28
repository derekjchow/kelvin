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
import chisel3.reflect.DataMirror

object GenerateInterface {
  def apply(interface: Data, baseName: String = ""): String = {
    def getLeafPortNames(name: String, data: Data): Seq[(String, Data)] = {
      data match {
        case _: Element => Seq((name, data))
        case r: Record => {
          r.elements.toList.reverse.map({ case (n, d) => {
            getLeafPortNames(s"${name}_${n}", d)
          }}).reduce(_ ++ _)
        }
        case v: Vec[_] => v.zipWithIndex.flatMap { case (d, i) =>
          getLeafPortNames(s"${name}_${i}", d)
        }
      }
    }

    val leafs = getLeafPortNames(baseName, interface)
    var ios: Seq[String] = Seq()
    for ((leafName, leafData) <- leafs) {
      val direction = DataMirror.directionOf(leafData) match {
        case chisel3.ActualDirection.Input => "input "
        case chisel3.ActualDirection.Output => "output"
        case _ => "unknown"
      }

      val ioLine = leafData match {
        case b: Bool => Some(s"$direction logic $leafName")
        case u: UInt => Some(s"$direction logic [${u.getWidth-1}:0] $leafName")
        case s: SInt => Some(s"$direction logic [${s.getWidth-1}:0] $leafName")
        case c: Clock => Some(s"$direction logic $leafName")
        case c: Reset => Some(s"$direction logic $leafName")
        // Assume remaining element is a ChiselEnum
        case e: Element =>
            Some(s"$direction logic [${e.getWidth-1}:0] $leafName")
        case _ => None
      }

      ios = ios ++ ioLine
    }

    ios.map("  " ++ _).mkString(",\n")
  }
}
