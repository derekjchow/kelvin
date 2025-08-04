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

package kelvin

import chisel3._
import bus._

class CoreTlul(p: Parameters, coreModuleName: String) extends RawModule {
    override val desiredName = coreModuleName + "Tlul"
    val memoryRegions = p.m
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
    val deviceBridge = withClockAndReset(io.clk, (!io.rst_ni.asBool).asAsyncReset) { Module(new TLUL2Axi(p, () => new OpenTitanTileLink_A_User, () => new OpenTitanTileLink_D_User)) }

    coreAxi.io.aclk := io.clk
    coreAxi.io.aresetn := io.rst_ni
    coreAxi.io.te := io.te
    coreAxi.io.irq := io.irq
    io.wfi := coreAxi.io.wfi
    io.fault := coreAxi.io.fault
    io.halted := coreAxi.io.halted

    hostBridge.io.axi <> coreAxi.io.axi_master
    deviceBridge.io.axi <> coreAxi.io.axi_slave

    io.tl_host.a <> hostBridge.io.tl_a
    hostBridge.io.tl_d <> io.tl_host.d

    deviceBridge.io.tl_a <> io.tl_device.a
    io.tl_device.d <> deviceBridge.io.tl_d
}