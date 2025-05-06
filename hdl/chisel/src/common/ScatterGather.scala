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

// Implements the vector gather operation such that:
// result[i] = data[indices[i]]
object Gather {
  def apply[T <: Data](indices: Vec[UInt], data: Vec[T]): Vec[T] = {
    assert((1 << indices(0).getWidth) == data.length)
    VecInit(indices.map(idx => data(idx)))
  }
}

// Performs a scatter operation.
//
// Scatter a vector of data elements into a result vector specified by an
// indices vector. A validity vector determines if the operation should be
// scattered or not.
//
// If two elements are scattered to the same location, the value of the first
// element is stored in the result vector. A selection vector is returned to
// indicate to the caller which elements were written.
//
// @param valid A `Vec[Bool]` where each element indicates if the corresponding
//              data element and index are valid for the current scatter
//              operation.
// @param indices A `Vec[UInt]` where each element `indices(i)` specifies the
//                target index in the output vector for the corresponding
//                `data(i)` element. The width of the elements in this vector
//                determines the number of entries in the output `result` vector
//                (r2^width). Must have the same length as the `valid` vector.
// @param data A `Vec[T]` where `T` is a subtype of `Data`. This vector contains
//             the input data elements to be scattered. Must have the same
//             length as the `valid` vector.
// @return A tuple containing three elements:
//    1. result (`Vec[T]`): The resulting vector after scattering the input
//        data.
//    2. resultMask (`Vec[Bool]`): A bitmask indicating which positions in the
//        `result` vector were written to during this scatter operation. Same
//        length as `result`.
//    3. `indicesSelected` (`Vec[Bool]`): A bitmask indicating which elements
//        from the input `data` (and `indices`) vector were successfully
//        written in this scatter operation. Same length as `valid`, `indices`
//        and `data` inputs.
object Scatter {
  def apply[T <: Data](valid: Vec[Bool],
                       indices: Vec[UInt],
                       data: Vec[T]): (Vec[T], Vec[Bool], Vec[Bool]) = {
    assert(valid.length == data.length)
    assert(indices.length == data.length)
    val dtype = chiselTypeOf(data(0))
    val indexWidth = indices(0).getWidth
    // Prevent scattering to a unreasonably wide vector. Limit to ~65k elements.
    assert(indexWidth <= 16)
    val resultLength = 1 << indexWidth


    // Generate resultMask and indicesSelected using a "selectionMatrix".
    // resultMask tracks which bytes of a busLine are active for this
    // transaction of a scatter operation.
    // indicesSelected specifies which elements of the data vector were used for
    // this transaction of a scatter operation.
    // The selection matrix is a indicesSelected.length row by resultMask.length
    // col binary matrix.
    val validMatrix = (0 until indices.length).map(idx =>
        Mux(valid(idx), UIntToOH(indices(idx)), 0.U(resultLength.W)))
    val valueSet = validMatrix.scan(0.U(resultLength.W))(_|_)
    val selectionMatrix = (0 until indices.length).map(
        idx => validMatrix(idx) & ~valueSet(idx))
    val resultMask = VecInit(selectionMatrix.reduce(_|_).asBools)
    val indicesSelected = VecInit(selectionMatrix.map(x => (x =/= 0.U)))

    // Assertions
    // Each row/column should have at most 1 element set. (Disabled for speed)
    // selectionMatrix.foreach(x => assert(PopCount(x) <= 1.U))
    // (0 until resultLength).foreach(
    //     i => assert(PopCount(selectionMatrix.map(_(i))) <= 1.U))
    // Check indicesSelected is contained in valid
    assert(PopCount((0 until indices.length).map(
        i => indicesSelected(i) & ~valid(i))) === 0.U)

    // TODO(derekjchow): Review semantics for "ordered" and "unordered", and
    // implement behaviours correctly.

    val result = Wire(Vec(resultLength, dtype))
    for (i <- 0 until resultLength) {
      result(i) := MuxCase(0.U.asTypeOf(dtype),
                           (0 until indices.length).map(idx =>
        (valid(idx) && (indices(idx) === i.U)) -> data(idx)
      ))
    }

    (result, resultMask, indicesSelected)
  }
}