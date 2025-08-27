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

module RvvCore #(parameter N = 4,
                 parameter BUSLENB = 128,
                 parameter BUSLENBYTES = BUSLENB/8,
                 parameter NLSU = 2,
                 type XDataT=logic [31:0],
                 type XAddrT=logic [31:0],
                 type XRegAddrT=logic [4:0])
(
  input clk,
  input rstn,

  input logic [N-1:0] req_valid,
  input LsuCmd req_data,
  output logic [N-1:0] req_ready,

  input XDataT [N-1:0] xdata,
  input XAddrT [N-1:0] xaddr,

  input XDataT [N-1:0] fdata,
  input XAddrT [N-1:0] faddr,

  input logic rd_valid,
  input XDataT rd_data,

  input logic flt_rd_valid,
  input XDataT flt_rd_data,

  // IBus
  output logic ibus_valid,
  output XAddrT ibus_addr,
  input logic ibus_ready,
  input logic [BUSLENB-1:0] ibus_rdata,  // Arrives one cycle after valid&ready
  input logic ibus_fault_valid,
  input logic ibus_fault_write,
  input XAddrT ibus_fault_addr,
  input XAddrT ibus_fault_epc,

  // DBus
  output logic dbus_valid,
  output logic dbus_write,
  output XAddrT dbus_pc,
  output XAddrT dbus_addr,
  output XAddrT dbus_adrx,
  output logic [$clog2(BUSLENBYTES):0] dbus_size,
  output logic [BUSLENB-1:0] dbus_wdata,
  output logic [BUSLENBYTES-1:0] dbus_wmask,
  input logic dbus_ready,
  input logic[BUSLENB-1:0] dbus_rdata,  // Arrives one cycle after valid&ready

  // EBus
  output logic ebus_valid,
  output logic ebus_write,
  output XAddrT ebus_pc,
  output XAddrT ebus_addr,
  output XAddrT ebus_adrx,
  output logic [$clog2(BUSLENBYTES):0] ebus_size,
  output logic [BUSLENB-1:0] ebus_wdata,
  output logic [BUSLENBYTES-1:0] ebus_wmask,
  input logic ebus_ready,
  input logic[BUSLENB-1:0] ebus_rdata,  // Arrives one cycle after valid&ready
  output logic ebus_external,
  input logic ebus_fault_valid,
  input logic ebus_fault_write,
  input XAddrT ebus_fault_addr,
  input XAddrT ebus_fault_epc,

  // RVV to LSU
  input  logic     [NLSU-1:0] uop_lsu_valid_rvv2lsu,
  input  logic     [NLSU-1:0] uop_lsu_idx_valid_rvv2lsu,
  input  RegAddrT  [NLSU-1:0] uop_lsu_idx_addr_rvv2lsu,
  input  VRegDataT [NLSU-1:0] uop_lsu_idx_data_rvv2lsu,
  input  logic     [NLSU-1:0] uop_lsu_vregfile_valid_rvv2lsu,
  input  RegAddrT  [NLSU-1:0] uop_lsu_vregfile_addr_rvv2lsu,
  input  VRegDataT [NLSU-1:0] uop_lsu_vregfile_data_rvv2lsu,
  input  logic     [NLSU-1:0] uop_lsu_v0_valid_rvv2lsu,
  input  MaskT     [NLSU-1:0] uop_lsu_v0_data_rvv2lsu,
  output logic     [NLSU-1:0] uop_lsu_ready_lsu2rvv,

  // LSU to RVV
  output logic     [NLSU-1:0] uop_lsu_valid_lsu2rvv,
  output RegAddrT  [NLSU-1:0] uop_lsu_addr_lsu2rvv,
  output VRegDataT [NLSU-1:0] uop_lsu_wdata_lsu2rvv,
  output logic     [NLSU-1:0] uop_lsu_last_lsu2rvv,
  input  logic     [NLSU-1:0] uop_lsu_ready_rvv2lsu,

  // Config state
  input logic config_state_valid,
  input RVVConfigState config_state,

  output logic [1:0] store_count,
  output logic [3:0] queue_capacity,
  output logic active,
  output logic vldst,
);

  assign vldst = 0;

endmodule;
