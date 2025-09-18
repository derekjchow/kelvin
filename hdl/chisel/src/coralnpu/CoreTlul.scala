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

package coralnpu

import chisel3._
import bus._

class CoreTlul(p: Parameters, coreModuleName: String) extends RawModule {
    override val desiredName = coreModuleName + "Tlul"
    val memoryRegions = p.m
    val tlul_p = new TLULParameters(p)
    val io = IO(new Bundle {
        val clk = Input(Clock())
        val rst_ni = Input(AsyncReset())

        val tl_host = new OpenTitanTileLink.Host2Device(new TLULParameters(p))
        val tl_device = new OpenTitanTileLink.Device2Host(new TLULParameters(p))

        // Core status interrupts
        val halted = Output(Bool())
        val fault = Output(Bool())
        val wfi = Output(Bool())
        val irq = Input(Bool())
        val te = Input(Bool())
    })
    dontTouch(io)

    val coreAxi = withClockAndReset(io.clk, io.rst_ni) { Module(new CoreAxi(p, coreModuleName)) }
    val hostBridge = withClockAndReset(io.clk, (!io.rst_ni.asBool).asAsyncReset) { Module(new Axi2TLUL(p, () => new OpenTitanTileLink_A_User, () => new OpenTitanTileLink_D_User)) }
    val deviceBridge = withClockAndReset(io.clk, (!io.rst_ni.asBool).asAsyncReset) { Module(new TLUL2Axi(p, p, () => new OpenTitanTileLink_A_User, () => new OpenTitanTileLink_D_User)) }

    coreAxi.io.aclk := io.clk
    coreAxi.io.aresetn := io.rst_ni
    coreAxi.io.te := io.te
    coreAxi.io.irq := io.irq
    io.wfi := coreAxi.io.wfi
    io.fault := coreAxi.io.fault
    io.halted := coreAxi.io.halted

    hostBridge.io.axi <> coreAxi.io.axi_master
    deviceBridge.io.axi <> coreAxi.io.axi_slave

    val host_req_intg_gen = withClockAndReset(io.clk, (!io.rst_ni.asBool).asAsyncReset) {
        Module(new RequestIntegrityGen(tlul_p))
    }
    io.tl_host.a.valid := hostBridge.io.tl_a.valid
    hostBridge.io.tl_a.ready := io.tl_host.a.ready
    host_req_intg_gen.io.a_i := hostBridge.io.tl_a.bits
    host_req_intg_gen.io.a_i.user.instr_type := 9.U // MuBi4False
    io.tl_host.a.bits := host_req_intg_gen.io.a_o
    hostBridge.io.tl_d <> io.tl_host.d

    val device_rsp_intg_gen = withClockAndReset(io.clk, (!io.rst_ni.asBool).asAsyncReset) {
        Module(new ResponseIntegrityGen(tlul_p))
    }
    deviceBridge.io.tl_a <> io.tl_device.a
    io.tl_device.d.valid := deviceBridge.io.tl_d.valid 
    deviceBridge.io.tl_d.ready := io.tl_device.d.ready 
    device_rsp_intg_gen.io.d_i := deviceBridge.io.tl_d.bits
    io.tl_device.d.bits := device_rsp_intg_gen.io.d_o
}