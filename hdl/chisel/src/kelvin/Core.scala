package kelvin

import chisel3._
import chisel3.util._
import common._

object Core {
  def apply(p: Parameters): Core = {
    return Module(new Core(p))
  }
}

class Core(p: Parameters) extends Module {
  val io = IO(new Bundle {
    val csr = new CsrInOutIO(p)
    val halted = Output(Bool())
    val fault = Output(Bool())

    val ibus = new IBusIO(p)
    val dbus = new DBusIO(p)
    val axi0 = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
    val axi1 = new AxiMasterIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)

    val iflush = new IFlushIO(p)
    val dflush = new DFlushIO(p)
    val slog = new SLogIO(p)

    val debug = new DebugIO(p)
  })

  val score = SCore(p)
  val vcore = VCore(p)
  val dbusmux = DBusMux(p)

  // ---------------------------------------------------------------------------
  // Scalar Core outputs.
  io.csr    <> score.io.csr
  io.ibus   <> score.io.ibus
  io.halted := score.io.halted
  io.fault  := score.io.fault
  io.iflush <> score.io.iflush
  io.dflush <> score.io.dflush
  io.slog   := score.io.slog
  io.debug  := score.io.debug

  // ---------------------------------------------------------------------------
  // Vector core.
  score.io.vcore <> vcore.io.score

  // ---------------------------------------------------------------------------
  // Local Data Bus Port
  dbusmux.io.vldst := score.io.vldst
  dbusmux.io.vlast := vcore.io.last

  dbusmux.io.vcore <> vcore.io.dbus
  dbusmux.io.score <> score.io.dbus

  io.dbus <> dbusmux.io.dbus

  // ---------------------------------------------------------------------------
  // Scalar DBus to AXI.
  val dbus2axi = DBus2Axi(p)
  dbus2axi.io.dbus <> score.io.ubus

  // ---------------------------------------------------------------------------
  // AXI ports.
  io.axi0.read  <> vcore.io.ld
  io.axi0.write <> vcore.io.st

  io.axi1 <> dbus2axi.io.axi
}

object EmitCore extends App {
  val p = new Parameters
  (new chisel3.stage.ChiselStage).emitVerilog(new Core(p), args)
}
