package kelvin

import chisel3._
import chisel3.util._
import chiseltest._
import chiseltest.experimental.expose
import org.scalatest.freespec.AnyFreeSpec

class ClockGateTester extends Module {
  val io = IO(new Bundle {
    val enable = Input(Bool())  // '1' passthrough, '0' disable.
    val counter = Output(UInt(32.W))
  })
  val cg = Module(new ClockGate())
  cg.io.clk_i := clock
  cg.io.enable := io.enable

  withClock(cg.io.clk_o) {
    val counter = RegInit(0.U(32.W))
    counter := counter + 1.U
    io.counter := counter
  }
}

class ClockGateSpec extends AnyFreeSpec with ChiselScalatestTester {
  "Counting" in {
    test(new ClockGateTester)
    .withAnnotations(
        Seq(
            VerilatorBackendAnnotation,
        )) { dut =>
        dut.io.enable.poke(false.B)
        dut.clock.step()
        assertResult(0) { dut.io.counter.peekInt() }
        dut.io.enable.poke(true.B)
        dut.clock.step()
        assertResult(1) { dut.io.counter.peekInt() }
    }
  }
}