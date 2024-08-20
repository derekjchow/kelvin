// Copyright 2024 Google LLC
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

#include <verilated.h>
#include "VCoreMiniAxi.h"
#include "src/buses/axi.h"
#include "src/buses/axilite.h"
#include "src/buses/axi-slave.h"
#if VM_TRACE
# include <verilated_fst_c.h>
#endif

RenodeAgent* kelvin;
VCoreMiniAxi* top = new VCoreMiniAxi;

uint8_t uint8_dummy;
VerilatedFstC *tfp;
vluint64_t main_time = 0;

void axiSlaveEval() {
  main_time++;
#if VM_TRACE
  if (tfp) {
    tfp->dump(main_time);
    if ((main_time % 1000000) == 0) {
      tfp->flush();
    }
  }
#endif
  top->eval();
  if (kelvin) {
    kelvin->handleInterrupts();
  }
}

void atexit_handler(void) {
#if VM_TRACE
  if (tfp) {
    tfp->dump(main_time);
    tfp->flush();
  }
#endif
}

RenodeAgent* Init() {
#if VM_TRACE
  Verilated::traceEverOn(true);
  tfp = new VerilatedFstC;
  top->trace(tfp, 99);
  tfp->open("/tmp/core_mini_axi.fst");
#endif
  auto* axi_slave = new Axi(128, 32);

  kelvin = new RenodeAgent(axi_slave);

  axi_slave->aclk = &top->io_aclk;
  axi_slave->aresetn = &top->io_aresetn;

  axi_slave->awid = &top->io_axi_slave_write_addr_bits_id;
  axi_slave->awaddr = &top->io_axi_slave_write_addr_bits_addr;
  axi_slave->awlen = &top->io_axi_slave_write_addr_bits_len;
  axi_slave->awsize = &top->io_axi_slave_write_addr_bits_size;
  axi_slave->awburst = &top->io_axi_slave_write_addr_bits_burst;
  axi_slave->awlock = &top->io_axi_slave_write_addr_bits_lock;
  axi_slave->awcache = &top->io_axi_slave_write_addr_bits_cache;
  axi_slave->awprot = &top->io_axi_slave_write_addr_bits_prot;
  axi_slave->awqos = &top->io_axi_slave_write_addr_bits_qos;
  axi_slave->awregion = &top->io_axi_slave_write_addr_bits_region;
  axi_slave->awuser = &uint8_dummy;
  axi_slave->awvalid = &top->io_axi_slave_write_addr_valid;
  axi_slave->awready = &top->io_axi_slave_write_addr_ready;

  axi_slave->wdata = (uint32_t*)&top->io_axi_slave_write_data_bits_data;
  axi_slave->wstrb = (uint8_t*)&top->io_axi_slave_write_data_bits_strb;
  axi_slave->wlast = &top->io_axi_slave_write_data_bits_last;
  axi_slave->wuser = &uint8_dummy;
  axi_slave->wvalid = &top->io_axi_slave_write_data_valid;
  axi_slave->wready = &top->io_axi_slave_write_data_ready;

  axi_slave->bid = &top->io_axi_slave_write_resp_bits_id;
  axi_slave->bresp = &top->io_axi_slave_write_resp_bits_resp;
  axi_slave->buser = &uint8_dummy;
  axi_slave->bvalid = &top->io_axi_slave_write_resp_valid;
  axi_slave->bready = &top->io_axi_slave_write_resp_ready;

  axi_slave->arid = &top->io_axi_slave_read_addr_bits_id;
  axi_slave->araddr = &top->io_axi_slave_read_addr_bits_addr;
  axi_slave->arlen = &top->io_axi_slave_read_addr_bits_len;
  axi_slave->arsize = &top->io_axi_slave_read_addr_bits_size;
  axi_slave->arburst = &top->io_axi_slave_read_addr_bits_burst;
  axi_slave->arlock = &top->io_axi_slave_read_addr_bits_lock;
  axi_slave->arcache = &top->io_axi_slave_read_addr_bits_cache;
  axi_slave->arprot = &top->io_axi_slave_read_addr_bits_prot;
  axi_slave->arqos = &top->io_axi_slave_read_addr_bits_qos;
  axi_slave->arregion = &top->io_axi_slave_read_addr_bits_region;
  axi_slave->aruser = &uint8_dummy;
  axi_slave->arvalid = &top->io_axi_slave_read_addr_valid;
  axi_slave->arready = &top->io_axi_slave_read_addr_ready;

  axi_slave->rid = &top->io_axi_slave_read_data_bits_id;
  axi_slave->rdata = (uint32_t*)&top->io_axi_slave_read_data_bits_data;
  axi_slave->rresp = &top->io_axi_slave_read_data_bits_resp;
  axi_slave->rlast = &top->io_axi_slave_read_data_bits_last;
  axi_slave->ruser = &uint8_dummy;
  axi_slave->rvalid = &top->io_axi_slave_read_data_valid;
  axi_slave->rready = &top->io_axi_slave_read_data_ready;

  axi_slave->evaluateModel = &axiSlaveEval;

  atexit(atexit_handler);

  return kelvin;
}
