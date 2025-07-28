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

object GenerateAlignerSource {
    def apply[T <: Data](t: T, n: Int): String = {
        var moduleInterface =  "module Aligner_T_WIDTH_GENN(\n".replaceAll("T_WIDTH", t.getWidth.toString)
                                                                 .replaceAll("GENN", n.toString)
        for (i <- 0 until n) {
            moduleInterface += "  input logic in_GENI_valid,\n".replaceAll("GENI", i.toString)
        }
        for (i <- 0 until n) {
            moduleInterface += "  input logic [T_WIDTH-1:0] in_GENI_bits,\n".replaceAll("GENI", i.toString)
                                                                            .replaceAll("T_WIDTH", t.getWidth.toString)
        }
        for (i <- 0 until n) {
            moduleInterface += "  output logic out_GENI_valid,\n".replaceAll("GENI", i.toString)
        }
        for (i <- 0 until n) {
            moduleInterface += "  output logic [T_WIDTH-1:0] out_GENI_bits,\n".replaceAll("GENI", i.toString)
                                                                              .replaceAll("T_WIDTH", t.getWidth.toString)
        }
        moduleInterface = moduleInterface.dropRight(2)
        moduleInterface += ");\n\n"

        var coreInstantiation = "  logic [GENN-1:0] valid_in;\n".replaceAll("GENN", n.toString)
        for (i <- 0 until n) {
            coreInstantiation += "  assign valid_in[GENI] = in_GENI_valid;\n".replaceAll("GENI", i.toString)
        }
        coreInstantiation += "  logic [GENN-1:0][T_WIDTH-1:0] data_in;\n".replaceAll("GENN", n.toString)
                                                                         .replaceAll("T_WIDTH", t.getWidth.toString)
        for (i <- 0 until n) {
            coreInstantiation += "  assign data_in[GENI] = in_GENI_bits;\n".replaceAll("GENI", i.toString)
        }
        coreInstantiation += "  logic [GENN-1:0] valid_out;\n".replaceAll("GENN", n.toString)
        for (i <- 0 until n) {
            coreInstantiation += "  assign out_GENI_valid = valid_out[GENI];\n".replaceAll("GENI", i.toString)
        }
        coreInstantiation += "  logic [GENN-1:0][T_WIDTH-1:0] data_out;\n".replaceAll("GENN", n.toString)
                                                                         .replaceAll("T_WIDTH", t.getWidth.toString)
        for (i <- 0 until n) {
            coreInstantiation += "  assign out_GENI_bits = data_out[GENI];\n".replaceAll("GENI", i.toString)
        }
        coreInstantiation += """
        |  Aligner#(.T (logic [T_WIDTH-1:0]), .N(GENN)) aligner(
        |    valid_in,
        |    data_in,
        |    valid_out,
        |    data_out
        |  );
        |""".replaceAll("T_WIDTH", t.getWidth.toString)
            .replaceAll("GENN", n.toString)
            .stripMargin

        moduleInterface + coreInstantiation + "endmodule\n"
    }
}

class Aligner[T <: Data](t: T, n: Int) extends BlackBox with HasBlackBoxInline
                                 with HasBlackBoxResource {
    override val desiredName = "Aligner_T_WIDTH_GENN".replaceAll("T_WIDTH", t.getWidth.toString)
                                                       .replaceAll("GENN", n.toString)
    val io = IO(new Bundle {
        val in = Input(Vec(n, Valid(UInt(t.getWidth.W))))
        val out = Output(Vec(n, Valid(UInt(t.getWidth.W))))
    })
    addResource("hdl/verilog/rvv/design/Aligner.sv")
    setInline(s"$desiredName.sv", GenerateAlignerSource(t, n))
}

object Aligner {
    def apply[T <: Data](in: Seq[ValidIO[T]]): Vec[ValidIO[T]] = {
        val t = chiselTypeOf(in(0).bits)
        val aligner = Module(new Aligner(t, in.length))
        aligner.io.in := in.map(v => v.map(_.asUInt))
        VecInit(aligner.io.out.map(v => v.map(_.asTypeOf(t))))
    }
}