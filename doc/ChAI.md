# What is ChAI?

ChAI is a reference implementation of an embedded system, build around the CoralNPU CPU.
It is intended as a starting point for either building out a more complete system, or integrating
into an existing system

## Building ChAI RTL

The SystemVerilog for ChAI can be built with the following command:

```
bazel build //hdl/chisel/src/chai:chai_cc_library_emit_verilog
```

The generated file will be in `bazel-bin/hdl/chisel/src/chai/ChAI.sv`

## Running a simulating ChAI

You can run program on the ChAI verilator sim with:

```
bazel run //tests/verilator_sim:chai_sim -- \
    --cycles 2000 \
    /path/to/program.bin
```

## Components
- CoralNPU CPU
- TileLink-UL crossbar
- UART (from lowRISC)
- SRAM (from Chisel, and using an adapter from lowRISC)

## Limitations
- Can only address memory at 32B / 256b offsets (existing peripherals may require modifications due to this)
- No interrupt support

## Adding a new peripheral
In ChAI.scala, add a new entry to the memoryRegions table for your peripheral:
```scala
  val memoryRegions = Seq(
    new coralnpu.MemoryRegion(0, 4 * 1024 * 1024, MemoryType.DMEM), // SRAM
    new coralnpu.MemoryRegion(4 * 1024 * 1024, 4 * 1024 * 1024, MemoryType.Peripheral) // UART
    new coralnpu.MemoryRegion(8 * 1024 * 1024, 1 * 1024 * 1024, MemoryType.Peripheral) // My New Peripheral
  )
```
A MemoryRegion consists of a starting address (in bytes), a size (in bytes), and the region type (IMEM, DMEM, Peripheral).

In ChAI.scala, connect your device's TileLink I/O to the crossbar:
```scala
val crossbar =
  Module(new coralnpu.TileLinkUL(tlul_p, coralnpu_p.m, /* hosts= */ 1))
crossbar.io.hosts_a(0) <> coralnpu_to_tlul.io.tl_o
crossbar.io.hosts_d(0) <> coralnpu_to_tlul.io.tl_i
crossbar.io.devices_a(0) <> tlul_adapter_sram.io.tl_i
crossbar.io.devices_d(0) <> tlul_adapter_sram.io.tl_o
crossbar.io.devices_a(1) <> uart.io.tl_i
crossbar.io.devices_d(1) <> uart.io.tl_o
crossbar.io.devices_a(2) <> my_new_peripheral.io.tl_i
crossbar.io.devices_d(2) <> my_new_peripheral.io.tl_o
```

Here's a skeleton of a peripheral that has a single register that can be
read or written.
```scala
package chai

import chisel3._
import chisel3.util._

object DummyPeripheral {
    def apply(tlul_p: coralnpu.TLULParameters): DummyPeripheral = {
        return Module(new DummyPeripheral(tlul_p))
    }
}

class DummyPeripheral(tlul_p: coralnpu.TLULParameters) extends Module {
    val io = IO(new Bundle {
        val tl_i = Input(new coralnpu.TileLinkULIO_H2D(tlul_p))
        val tl_o = Output(new coralnpu.TileLinkULIO_D2H(tlul_p))
    })

    io.tl_o := 0.U.asTypeOf(new coralnpu.TileLinkULIO_D2H(tlul_p))
    val saved_value = RegInit(0.U(32.W))

    val tl_i_reg = Reg(new coralnpu.TileLinkULIO_H2D(tlul_p))
    tl_i_reg := io.tl_i

    io.tl_o.a_ready := true.B
    when (tl_i_reg.a_valid) {
        io.tl_o.d_valid := true.B
        switch (tl_i_reg.a_opcode) {
            is (4.U /* coralnpu.TLULOpcodesA.Get.asUInt */) {
                io.tl_o.d_opcode := coralnpu.TLULOpcodesD.AccessAckData.asUInt
                io.tl_o.d_param := 0.U
                io.tl_o.d_size := tl_i_reg.a_size
                io.tl_o.d_source := tl_i_reg.a_source
                io.tl_o.d_sink := 1.U
                io.tl_o.d_data := saved_value
                io.tl_o.d_error := false.B
            }
            is (0.U /* PutFullData */) {
                saved_value := tl_i_reg.a_data
                io.tl_o.d_opcode := coralnpu.TLULOpcodesD.AccessAck.asUInt
                io.tl_o.d_param := 0.U
                io.tl_o.d_size := tl_i_reg.a_size
                io.tl_o.d_source := tl_i_reg.a_source
                io.tl_o.d_sink := 1.U
                io.tl_o.d_data := 0.U
                io.tl_o.d_error := false.B
            }
            is (1.U /* PutPartialData */) {
                /* no-op */
            }
        }
    }
}
```
