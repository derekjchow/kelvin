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

//----------------------------------------------------------------------------
// Interface: coralnpu_axi_slave_if
// Description: AXI4 interface for the TB component acting as Slave
//              (Connects to DUT's Master Port)
//----------------------------------------------------------------------------
interface coralnpu_axi_slave_if #(
    parameter int unsigned AWIDTH = 32,
    parameter int unsigned DWIDTH = 128, // Matches DUT Master port
    parameter int unsigned IDWIDTH = 6   // Matches DUT Master port
  ) (input logic clk, input logic resetn);

  // Signal declarations (Slave receives AW, W, AR; drives B, R)
  // Write Address Channel
  logic                 awvalid;
  logic [IDWIDTH-1:0]   awid;
  logic [AWIDTH-1:0]    awaddr;
  logic [7:0]           awlen;
  logic [2:0]           awsize;
  logic [1:0]           awburst;
  logic                 awlock;
  logic [3:0]           awcache;
  logic [2:0]           awprot;
  logic [3:0]           awqos;
  logic [3:0]           awregion;
  logic                 awready;

  // Write Data Channel
  logic                 wvalid;
  logic [IDWIDTH-1:0]   wid;
  logic [DWIDTH-1:0]    wdata;
  logic [DWIDTH/8-1:0]  wstrb;
  logic                 wlast;
  logic                 wready;

  // Write Response Channel
  logic                 bvalid;
  logic [IDWIDTH-1:0]   bid;
  logic [1:0]           bresp;
  logic                 bready;

  // Read Address Channel
  logic                 arvalid;
  logic [IDWIDTH-1:0]   arid;
  logic [AWIDTH-1:0]    araddr;
  logic [7:0]           arlen;
  logic [2:0]           arsize;
  logic [1:0]           arburst;
  logic                 arlock;
  logic [3:0]           arcache;
  logic [2:0]           arprot;
  logic [3:0]           arqos;
  logic [3:0]           arregion;
  logic                 arready;

  // Read Data Channel
  logic                 rvalid;
  logic [IDWIDTH-1:0]   rid;
  logic [DWIDTH-1:0]    rdata;
  logic [1:0]           rresp;
  logic                 rlast;
  logic                 rready;

  // Clocking block for Testbench Slave Model
  clocking tb_slave_cb @(posedge clk);
    default input #1step output #2ns;
    // Inputs sampled by TB Slave
    input  awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion;
    input  awvalid;
    input  wid, wdata, wstrb, wlast;
    input  wvalid;
    input  bready;
    input  arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion;
    input  arvalid;
    input  rready;
    // Outputs driven by TB Slave
    output awready;
    output wready;
    output bid, bresp, bvalid;
    output arready;
    output rid, rdata, rresp, rlast, rvalid;
  endclocking : tb_slave_cb

  // Modport for Testbench Slave Model component
  modport TB_SLAVE_MODEL (clocking tb_slave_cb, input clk, input resetn);

  // Modport for connecting to the DUT's Master port
  modport DUT_MASTER_PORT (
    input  clk, resetn,

    output awvalid,
    output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion,
    input  awready,

    output wvalid,
    output wid, wdata, wstrb, wlast,
    input  wready,

    input  bvalid,
    input  bid, bresp,
    input  bready,

    output arvalid,
    output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion,
    input  arready,

    input  rvalid,
    input  rid, rdata, rresp, rlast,
    input  rready
  );

endinterface : coralnpu_axi_slave_if
