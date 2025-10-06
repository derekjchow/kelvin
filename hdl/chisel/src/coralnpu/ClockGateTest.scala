package coralnpu

import chisel3._
import chisel3.simulator.scalatest.ChiselSim
import chisel3.simulator.scalatest.HasCliOptions
import svsim.CommonCompilationSettings
import svsim.CommonCompilationSettings.VerilogPreprocessorDefine
import org.scalatest.freespec.AnyFreeSpec

class ClockGateTester extends Module with RequireAsyncReset {
  val io = IO(new Bundle {
    val enable = Input(Bool())  // '1' passthrough, '0' disable.
    val counter = Output(UInt(32.W))
  })
  val cg = Module(new ClockGate())
  cg.io.clk_i := clock
  cg.io.enable := io.enable
  cg.io.te := false.B

  withClock(cg.io.clk_o) {
    val counter = RegInit(0.U(32.W))
    counter := counter + 1.U
    io.counter := counter
  }
}

trait UseGeneric { this: HasCliOptions =>
  override implicit def commonSettingsModifications: svsim.CommonSettingsModifications = (original: CommonCompilationSettings) =>
  {
    original.copy(
      verilogPreprocessorDefines = original.verilogPreprocessorDefines :+ VerilogPreprocessorDefine("USE_GENERIC", "1")
    )
  }
}

class ClockGateSpec extends AnyFreeSpec with ChiselSim with UseGeneric {
  "Counting" in {
    simulate(new ClockGateTester) { dut =>
        dut.io.enable.poke(false)
        dut.clock.step()
        dut.io.counter.expect(0)
        dut.io.enable.poke(true)
        dut.clock.step()
        dut.io.counter.expect(1)
    }
  }
}