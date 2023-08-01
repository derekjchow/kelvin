package kelvin

import chisel3._
import chisel3.util._
import common._

object VCore {
  def apply(p: Parameters): VCore = {
    return Module(new VCore(p))
  }
}

// object VCore {
//   def apply(p: Parameters): VCoreEmpty = {
//     return Module(new VCoreEmpty(p))
//   }
// }

class VCoreIO(p: Parameters) extends Bundle {
  // Decode cycle.
  val vinst = Vec(4, new VInstIO)

  // Execute cycle.
  val rs = Vec(8, Flipped(new RegfileReadDataIO))
  val rd = Vec(4, Flipped(new RegfileWriteDataIO))

  // Status.
  val mactive = Output(Bool())

  // Faults.
  val undef = Output(Bool())
}

class VCore(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Score <> VCore
    val score = new VCoreIO(p)

    // Data bus interface.
    val dbus = new DBusIO(p)
    val last = Output(Bool())

    // AXI interface.
    val ld = new AxiMasterReadIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
    val st = new AxiMasterWriteIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
  })

  // Decode    : VInst.in
  // Execute+0 : VInst.slice
  // Execute+1 : VInst.out <> VDec::Fifo.in
  // Execute+2 : VDec::Fifo.out <> VDec::Shuffle.in
  // Execute+3 : VDec::Shuffle.out <> VCmdq::Fifo.in
  // Execute+4 : VCmdq::Fifo.out <> VCmdq::Reg.in
  // Execute+5 : VCmdq::Reg.out <> {VLdSt, VAlu, ...}

  val vinst  = VInst(p)
  val vdec   = VDecode(p)
  val valu   = VAlu(p)
  val vconv  = VConvCtrl(p)
  val vldst  = VLdSt(p)
  val vld    = VLd(p)
  val vst    = VSt(p)
  val vrf    = VRegfile(p)

  vinst.io.in <> io.score.vinst
  vinst.io.rs <> io.score.rs
  vinst.io.rd <> io.score.rd

  assert(PopCount(Cat(vst.io.read.valid && vst.io.read.ready,
                      vldst.io.read.valid && vldst.io.read.ready)) <= 1.U)

  // ---------------------------------------------------------------------------
  // VDecode.
  vdec.io.vrfsb <> vrf.io.vrfsb

  vdec.io.active := valu.io.active | vconv.io.active | vldst.io.active | vst.io.active

  vdec.io.in.valid := vinst.io.out.valid
  vinst.io.out.ready := vdec.io.in.ready
  assert(!(vdec.io.in.valid && !vdec.io.in.ready))

  vinst.io.out.stall := vdec.io.stall  // decode backpressure

  for (i <- 0 until 4) {
    vdec.io.in.bits(i) := vinst.io.out.lane(i)
  }

  io.score.undef := vdec.io.undef

  // ---------------------------------------------------------------------------
  // VRegfile.
  for (i <- 0 until 7) {
    vrf.io.read(i).valid := false.B
    vrf.io.read(i).addr := 0.U
    vrf.io.read(i).tag := 0.U
  }

  for (i <- 0 until 6) {
    vrf.io.write(i).valid := false.B
    vrf.io.write(i).addr := 0.U
    vrf.io.write(i).data := 0.U
  }

  for (i <- 0 until 4) {
    vrf.io.whint(i).valid := false.B
    vrf.io.whint(i).addr := 0.U
  }

  for (i <- 0 until 2) {
    vrf.io.scalar(i).valid := false.B
    vrf.io.scalar(i).data := 0.U
  }

  vrf.io.transpose.valid := false.B
  vrf.io.transpose.index := 0.U
  vrf.io.transpose.addr  := 0.U

  // ---------------------------------------------------------------------------
  // VALU.
  val aluvalid = Cat(vdec.io.out(3).valid && vdec.io.cmdq(3).alu,
                     vdec.io.out(2).valid && vdec.io.cmdq(2).alu,
                     vdec.io.out(1).valid && vdec.io.cmdq(1).alu,
                     vdec.io.out(0).valid && vdec.io.cmdq(0).alu)

  val aluready = Cat(valu.io.in.ready && vdec.io.cmdq(3).alu,
                     valu.io.in.ready && vdec.io.cmdq(2).alu,
                     valu.io.in.ready && vdec.io.cmdq(1).alu,
                     valu.io.in.ready && vdec.io.cmdq(0).alu)

  valu.io.in.valid := aluvalid =/= 0.U

  for (i <- 0 until 4) {
    valu.io.in.bits(i).valid := aluvalid(i)
    valu.io.in.bits(i).bits := vdec.io.out(i).bits
  }

  for (i <- 0 until 7) {
    vrf.io.read(i).valid := valu.io.read(i).valid
    vrf.io.read(i).addr := valu.io.read(i).addr
    vrf.io.read(i).tag  := valu.io.read(i).tag
  }

  for (i <- 0 until 7) {
    valu.io.read(i).data := vrf.io.read(i).data
  }

  for (i <- 0 until 4) {
    vrf.io.write(i).valid := valu.io.write(i).valid
    vrf.io.write(i).addr := valu.io.write(i).addr
    vrf.io.write(i).data := valu.io.write(i).data

    vrf.io.whint(i).valid := valu.io.whint(i).valid
    vrf.io.whint(i).addr := valu.io.whint(i).addr
  }

  for (i <- 0 until 2) {
    vrf.io.scalar(i).valid := valu.io.scalar(i).valid
    vrf.io.scalar(i).data := valu.io.scalar(i).data
  }

  valu.io.vrfsb := vrf.io.vrfsb.data

  // ---------------------------------------------------------------------------
  // VCONV.
  val convvalid = Cat(vdec.io.out(3).valid && vdec.io.cmdq(3).conv,
                      vdec.io.out(2).valid && vdec.io.cmdq(2).conv,
                      vdec.io.out(1).valid && vdec.io.cmdq(1).conv,
                      vdec.io.out(0).valid && vdec.io.cmdq(0).conv)

  val convready = Cat(vconv.io.in.ready && vdec.io.cmdq(3).conv,
                      vconv.io.in.ready && vdec.io.cmdq(2).conv,
                      vconv.io.in.ready && vdec.io.cmdq(1).conv,
                      vconv.io.in.ready && vdec.io.cmdq(0).conv)

  vconv.io.in.valid := convvalid =/= 0.U

  for (i <- 0 until 4) {
    vconv.io.in.bits(i).valid := convvalid(i)
    vconv.io.in.bits(i).bits := vdec.io.out(i).bits
  }

  vrf.io.conv := vconv.io.out

  vconv.io.vrfsb := vrf.io.vrfsb.data

  // ---------------------------------------------------------------------------
  // VLdSt.
  val ldstvalid = Cat(vdec.io.out(3).valid && vdec.io.cmdq(3).ldst,
                      vdec.io.out(2).valid && vdec.io.cmdq(2).ldst,
                      vdec.io.out(1).valid && vdec.io.cmdq(1).ldst,
                      vdec.io.out(0).valid && vdec.io.cmdq(0).ldst)

  val ldstready = Cat(vldst.io.in.ready && vdec.io.cmdq(3).ldst,
                      vldst.io.in.ready && vdec.io.cmdq(2).ldst,
                      vldst.io.in.ready && vdec.io.cmdq(1).ldst,
                      vldst.io.in.ready && vdec.io.cmdq(0).ldst)

  vldst.io.in.valid := ldstvalid =/= 0.U

  for (i <- 0 until 4) {
    vldst.io.in.bits(i).valid := ldstvalid(i)
    vldst.io.in.bits(i).bits := vdec.io.out(i).bits
  }

  vldst.io.read.ready := !vst.io.read.valid
  vldst.io.read.data := vrf.io.read(6).data

  vldst.io.vrfsb := vrf.io.vrfsb.data

  io.dbus <> vldst.io.dbus
  io.last := vldst.io.last

  // ---------------------------------------------------------------------------
  // VLd.
  val ldvalid = Wire(UInt(4.W))
  val ldready = Wire(UInt(4.W))

  ldvalid := Cat(vdec.io.cmdq(3).ld && vdec.io.out(3).valid,
                 vdec.io.cmdq(2).ld && vdec.io.out(2).valid,
                 vdec.io.cmdq(1).ld && vdec.io.out(1).valid,
                 vdec.io.cmdq(0).ld && vdec.io.out(0).valid)

  ldready := Cat(vdec.io.cmdq(3).ld && vld.io.in.ready,
                 vdec.io.cmdq(2).ld && vld.io.in.ready,
                 vdec.io.cmdq(1).ld && vld.io.in.ready,
                 vdec.io.cmdq(0).ld && vld.io.in.ready)

  vld.io.in.valid := ldvalid =/= 0.U

  for (i <- 0 until 4) {
    vld.io.in.bits(i).valid := ldvalid(i)
    vld.io.in.bits(i).bits := vdec.io.out(i).bits
  }

  io.ld <> vld.io.axi

  // ---------------------------------------------------------------------------
  // VSt.
  val stvalid = Wire(UInt(4.W))
  val stready = Wire(UInt(4.W))

  stvalid := Cat(vdec.io.out(3).valid && vdec.io.cmdq(3).st,
                 vdec.io.out(2).valid && vdec.io.cmdq(2).st,
                 vdec.io.out(1).valid && vdec.io.cmdq(1).st,
                 vdec.io.out(0).valid && vdec.io.cmdq(0).st)

  stready := Cat(vst.io.in.ready && vdec.io.cmdq(3).st,
                 vst.io.in.ready && vdec.io.cmdq(2).st,
                 vst.io.in.ready && vdec.io.cmdq(1).st,
                 vst.io.in.ready && vdec.io.cmdq(0).st)

  vst.io.in.valid := stvalid =/= 0.U

  for (i <- 0 until 4) {
    vst.io.in.bits(i).valid := stvalid(i)
    vst.io.in.bits(i).bits := vdec.io.out(i).bits
  }

  io.st <> vst.io.axi

  vst.io.vrfsb := vrf.io.vrfsb.data

  vst.io.read.ready := true.B
  vst.io.read.data := vrf.io.read(6).data

  // ---------------------------------------------------------------------------
  // Load write.
  vrf.io.write(4).valid := vldst.io.write.valid
  vrf.io.write(4).addr := vldst.io.write.addr
  vrf.io.write(4).data := vldst.io.write.data

  vrf.io.write(5).valid := vld.io.write.valid
  vrf.io.write(5).addr := vld.io.write.addr
  vrf.io.write(5).data := vld.io.write.data

  // ---------------------------------------------------------------------------
  // Store read.
  vrf.io.read(6).valid := vst.io.read.valid || vldst.io.read.valid
  vrf.io.read(6).addr := Mux(vst.io.read.valid, vst.io.read.addr,
                             vldst.io.read.addr)
  vrf.io.read(6).tag := Mux(vst.io.read.valid, vst.io.read.tag,
                            vldst.io.read.tag)

  // ---------------------------------------------------------------------------
  // VDecode.
  for (i <- 0 until 4) {
    vdec.io.out(i).ready := aluready(i) || convready(i) || ldstready(i) ||
                            ldready(i) || stready(i)
  }

  // ---------------------------------------------------------------------------
  // Memory active status.
  io.score.mactive := vinst.io.nempty || vdec.io.nempty ||
                      vld.io.nempty || vst.io.nempty
}

class VCoreEmpty(p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Score <> VCore
    val score = new VCoreIO(p)

    // Data bus interface.
    val dbus = new DBusIO(p)
    val last = Output(Bool())

    // AXI interface.
    val ld = new AxiMasterReadIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
    val st = new AxiMasterWriteIO(p.axi2AddrBits, p.axi2DataBits, p.axi2IdBits)
  })

  io.score.undef := io.score.vinst(0).valid || io.score.vinst(1).valid ||
                    io.score.vinst(2).valid || io.score.vinst(3).valid

  io.score.mactive := false.B

  io.dbus.valid := false.B
  io.dbus.write := false.B
  io.dbus.size := 0.U
  io.dbus.addr := 0.U
  io.dbus.adrx := 0.U
  io.dbus.wdata := 0.U
  io.dbus.wmask := 0.U
  io.last := false.B

  for (i <- 0 until 4) {
    io.score.vinst(i).ready := true.B
    io.score.rd(i).valid := false.B
    io.score.rd(i).addr := 0.U
    io.score.rd(i).data := 0.U
  }

  io.ld.addr.valid := false.B
  io.ld.addr.bits.addr := 0.U
  io.ld.addr.bits.id := 0.U
  io.ld.data.ready := false.B

  io.st.addr.valid := false.B
  io.st.addr.bits.addr := 0.U
  io.st.addr.bits.id := 0.U
  io.st.data.valid := false.B
  io.st.data.bits.data := 0.U
  io.st.data.bits.strb := 0.U
  io.st.resp.ready := false.B
}
