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

package common

import chisel3._
import chisel3.experimental.BundleLiterals._

// Performs a (partial) assertion on a bundle as part of a test.
// - Accepts same input as bundle literals.
// - Prints a summary in case of failure.
// - Returns the result. It does not throw anything.
object AssertPartial {
  def apply[T <: Bundle](act: T, hint: String, printfn: String => Unit, exp: T => (Data, Data)*): Boolean = {
    val good = exp.map { e =>
      val (x, y) = e(act)
      x.litValue == y.litValue
    }
    val all_pass = good.fold(true)((x, y) => x & y)
    if (!all_pass) {
      val exp_bundle = chiselTypeOf(act).Lit(exp:_*)
      printfn(s"Assertion failure: $hint")
      printfn(s"Expected: $exp_bundle")
      printfn(s"Actual: $act")
    }
    all_pass
  }
}

// Prints a summary from a sequence of test results, and returns
// whether all cases are good.
object ProcessTestResults {
  def apply(good: Seq[Boolean], printfn: String => Unit) = {
    val good_count = good.count(x => x)
    val count = good.length
    printfn(s"$good_count / $count passed")
    good_count == good.length
  }
}
