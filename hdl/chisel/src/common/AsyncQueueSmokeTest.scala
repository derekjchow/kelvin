package common

import chisel3._
import chisel3.util._
import chisel3.simulator.scalatest.ChiselSim
import org.scalatest.freespec.AnyFreeSpec
import freechips.rocketchip.util._
import chisel3.simulator.scalatest.HasCliOptions
import svsim.verilator.Backend
import svsim.CommonCompilationSettings

trait WithVcd { this: HasCliOptions =>
  override implicit def backendSettingsModifications: svsim.BackendSettingsModifications =
    (original: svsim.Backend.Settings) => {
      original match {
        case settings: Backend.CompilationSettings =>
          settings.copy(
            traceStyle = Some(
              Backend.CompilationSettings.TraceStyle.Vcd(filename = "trace.vcd")
            )
          )
        case other => other
      }
    }

  override implicit def commonSettingsModifications: svsim.CommonSettingsModifications =
    (original: CommonCompilationSettings) => {
      original.copy(
        simulationSettings = original.simulationSettings.copy(enableWavesAtTimeZero = true)
      )
    }
}

class AsyncQueueSmokeTest extends Module {
  val io = IO(new Bundle {
    val enq = Flipped(Decoupled(UInt(32.W)))
    val deq = Decoupled(UInt(32.W))
  })

  // Create two asynchronous clock sources from the single test clock
  val enq_clock_wire = Wire(Clock())
  val deq_clock_wire = Wire(Clock())
  val enq_reset_wire = Wire(Bool())
  val deq_reset_wire = Wire(Bool())

  // A simple clock divider to create a slower enqueue clock (half frequency).
  val enq_clock_divider = RegInit(false.B)
  enq_clock_divider := !enq_clock_divider
  enq_clock_wire := enq_clock_divider.asClock

  // A different divider to create an even slower dequeue clock (quarter frequency)
  // that is phase-shifted relative to the enqueue clock.
  val deq_clock_divider = RegInit(0.U(2.W))
  deq_clock_divider := deq_clock_divider + 1.U
  deq_clock_wire := deq_clock_divider(1).asClock

  // Tie resets to the main test harness reset
  enq_reset_wire := reset.asBool
  deq_reset_wire := reset.asBool

  // safe=false is used for performance in this simple test. For production,
  // safe=true is recommended to prevent metastability issues when the queue
  // is nearly full or empty.
  val queue = Module(new AsyncQueue(UInt(32.W), AsyncQueueParams.singleton(safe = false)))

  queue.io.enq_clock := enq_clock_wire
  queue.io.enq_reset := enq_reset_wire
  queue.io.deq_clock := deq_clock_wire
  queue.io.deq_reset := deq_reset_wire

  queue.io.enq <> io.enq
  io.deq <> queue.io.deq
}

class AsyncQueueSmokeSpec extends AnyFreeSpec with ChiselSim with WithVcd {
  "AsyncQueueSmokeTest should pass a value across clock domains" in {
    simulate(new AsyncQueueSmokeTest) { dut =>
      val resetCycles = 2
      val initialDelayCycles = 5
      val enqHoldCycles = 3
      val deqValidTimeoutCycles = 50

      // Initialize inputs
      dut.io.enq.valid.poke(false.B)
      dut.io.deq.ready.poke(false.B)

      // Reset the DUT
      dut.reset.poke(true.B)
      dut.clock.step(resetCycles)
      dut.reset.poke(false.B)
      dut.clock.step(initialDelayCycles)

      // Enqueue an item
      dut.io.enq.valid.poke(true.B)
      dut.io.enq.bits.poke(123.U)
      dut.io.enq.ready.expect(true.B) // Should be ready immediately after reset
      // Hold valid for enough cycles to guarantee a rising edge on the slower enq_clock
      dut.clock.step(enqHoldCycles)
      dut.io.enq.valid.poke(false.B)

      // Wait for deq.valid to go high, with a timeout
      var timeout = deqValidTimeoutCycles
      while (!dut.io.deq.valid.peek().litToBoolean && timeout > 0) {
        dut.clock.step()
        timeout -= 1
      }
      if (timeout == 0) {
        fail(s"Timed out after ${deqValidTimeoutCycles} cycles waiting for deq.valid to go high")
      }

      // Dequeue the item
      dut.io.deq.ready.poke(true.B)
      dut.io.deq.valid.expect(true.B)
      dut.io.deq.bits.expect(123.U)
      dut.clock.step()
    }
  }
}