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
#include "src/buses/axi-slave.h"
#include "src/buses/axi.h"
#include "src/buses/axilite.h"
#if VM_TRACE
#include <verilated_fst_c.h>
#endif

#include <thread>
#include <signal.h>

#include "tests/renode/coralnpu.grpc.pb.h"
#include <grpcpp/grpcpp.h>

RenodeAgent* coralnpu_slave;
RenodeAgent* coralnpu_master;
auto* axi_slave = new Axi(128, 32);
auto* axi_master = new AxiSlave(128, 32);
VCoreMiniAxi* top = new VCoreMiniAxi;

uint8_t uint8_dummy;
VerilatedFstC* tfp;
vluint64_t main_time = 0;
vluint64_t last_tick = 0;


void tick() {
  if (!top) {
    return;
  }

  // First cycle, always evaluate regardless of what role asked.
  if (main_time == 0) {
    top->io_irq = false;
    top->eval();
    main_time++;
    return;
  }

  // If we've already done this tick, skip. Otherwise, tick and update `last_tick`.
  if (main_time == last_tick) {
    return;
  } else {
    // On rising-edges, check if the core is in WFI.
    // If so, generate an interrupt pulse to wake it.
    static bool irq_state = false;
    if (top->io_aclk) {
      if (top->io_wfi && !irq_state) {
        irq_state = true;
      }
      if (!top->io_wfi && irq_state) {
        irq_state = false;
      }
    }
    top->io_irq = irq_state;
    top->eval();
    last_tick = main_time;
    main_time++;
  }

#if VM_TRACE
  tfp->dump(main_time);
  static bool flushed_on_halt = false;
  if ((top->io_halted == 1 && !flushed_on_halt) || ((main_time % 1000) == 0)) {
    flushed_on_halt = top->io_halted;
    tfp->flush();
  }
#endif
}

void axiSlaveEval() {
  tick();
  if (coralnpu_slave) {
    coralnpu_slave->handleInterrupts();
  }
}

void axiMasterEval() {
  tick();
  if (coralnpu_master) {
    coralnpu_master->handleInterrupts();
  }
}

RenodeAgent* Init(bool slave) {
  if (slave) {
    coralnpu_slave = new RenodeAgent(axi_slave);
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
    return coralnpu_slave;
  } else {
    coralnpu_master = new RenodeAgent(axi_master);
    coralnpu_slave->addBus(axi_master);
    axi_master->aclk = &top->io_aclk;
    axi_master->aresetn = &top->io_aresetn;

    axi_master->awid = &top->io_axi_master_write_addr_bits_id;
    axi_master->awaddr = &top->io_axi_master_write_addr_bits_addr;
    axi_master->awlen = &top->io_axi_master_write_addr_bits_len;
    axi_master->awsize = &top->io_axi_master_write_addr_bits_size;
    axi_master->awburst = &top->io_axi_master_write_addr_bits_burst;
    axi_master->awlock = &top->io_axi_master_write_addr_bits_lock;
    axi_master->awcache = &top->io_axi_master_write_addr_bits_cache;
    axi_master->awprot = &top->io_axi_master_write_addr_bits_prot;
    axi_master->awqos = &top->io_axi_master_write_addr_bits_qos;
    axi_master->awregion = &top->io_axi_master_write_addr_bits_region;
    axi_master->awuser = &uint8_dummy;
    axi_master->awvalid = &top->io_axi_master_write_addr_valid;
    axi_master->awready = &top->io_axi_master_write_addr_ready;

    axi_master->wdata = (uint32_t*)&top->io_axi_master_write_data_bits_data;
    axi_master->wstrb = (uint8_t*)&top->io_axi_master_write_data_bits_strb;
    axi_master->wlast = &top->io_axi_master_write_data_bits_last;
    axi_master->wuser = &uint8_dummy;
    axi_master->wvalid = &top->io_axi_master_write_data_valid;
    axi_master->wready = &top->io_axi_master_write_data_ready;

    axi_master->bid = &top->io_axi_master_write_resp_bits_id;
    axi_master->bresp = &top->io_axi_master_write_resp_bits_resp;
    axi_master->buser = &uint8_dummy;
    axi_master->bvalid = &top->io_axi_master_write_resp_valid;
    axi_master->bready = &top->io_axi_master_write_resp_ready;

    axi_master->arid = &top->io_axi_master_read_addr_bits_id;
    axi_master->araddr = &top->io_axi_master_read_addr_bits_addr;
    axi_master->arlen = &top->io_axi_master_read_addr_bits_len;
    axi_master->arsize = &top->io_axi_master_read_addr_bits_size;
    axi_master->arburst = &top->io_axi_master_read_addr_bits_burst;
    axi_master->arlock = &top->io_axi_master_read_addr_bits_lock;
    axi_master->arcache = &top->io_axi_master_read_addr_bits_cache;
    axi_master->arprot = &top->io_axi_master_read_addr_bits_prot;
    axi_master->arqos = &top->io_axi_master_read_addr_bits_qos;
    axi_master->arregion = &top->io_axi_master_read_addr_bits_region;
    axi_master->aruser = &uint8_dummy;
    axi_master->arvalid = &top->io_axi_master_read_addr_valid;
    axi_master->arready = &top->io_axi_master_read_addr_ready;

    axi_master->rid = &top->io_axi_master_read_data_bits_id;
    axi_master->rdata = (uint32_t*)&top->io_axi_master_read_data_bits_data;
    axi_master->rresp = &top->io_axi_master_read_data_bits_resp;
    axi_master->rlast = &top->io_axi_master_read_data_bits_last;
    axi_master->ruser = &uint8_dummy;
    axi_master->rvalid = &top->io_axi_master_read_data_valid;
    axi_master->rready = &top->io_axi_master_read_data_ready;
    axi_master->evaluateModel = &axiMasterEval;
    return coralnpu_master;
  }
}

// Stub to support linking with Renode's integration library.
// Only used for the shared library version, which we do not support.
RenodeAgent* Init() {
  abort();
  return nullptr;
}

std::thread coralnpu_slave_thread;
std::thread coralnpu_master_thread;
std::string coralnpu_slave_address;
std::string coralnpu_master_address;

class CoralNPUServiceImpl final : public coralnpu::CoralNPU::Service {
  grpc::Status StartAgent(
    grpc::ServerContext* context,
    const coralnpu::StartAgentRequest* request,
    coralnpu::StartAgentResponse* response) override {
      auto type = request->type();
      auto receiverPort = request->receiverport();
      auto senderPort = request->senderport();
      auto address = request->address().c_str();
      switch (type) {
        case coralnpu::AgentType::Slave: {
          coralnpu_slave_address = address;
          Init(true);
          coralnpu_slave_thread = std::thread([=]() {
            coralnpu_slave->simulate(receiverPort, senderPort, coralnpu_slave_address.c_str());
          });
        }
          break;
        case coralnpu::AgentType::Master: {
          coralnpu_master_address = address;
          Init(false);
          coralnpu_master_thread = std::thread([=]() {
            coralnpu_master->simulate(receiverPort, senderPort, coralnpu_master_address.c_str());
          });
        }
          break;
        default:
          break;
      }
      return grpc::Status::OK;
    }
};

std::unique_ptr<grpc::Server> server;
// SIGTERM handler to shut down gRPC.
// NB: We spawn a new thread to call shutdown, as
// it must not be on the same thread as the server.
void sigterm_handler(int signo, siginfo_t* info, void* context) {
  std::thread([]() {
    server->Shutdown();
  }).join();
}

extern "C" int main(int argc, char** argv) {
#if VM_TRACE
  Verilated::traceEverOn(true);
  tfp = new VerilatedFstC;
  top->trace(tfp, 99);
  tfp->open("/tmp/core_mini_axi.fst");
#endif

  // TODO(atv): How to fix this port?
  std::string server_address = "127.0.0.1:9003";
  CoralNPUServiceImpl service;

  grpc::ServerBuilder builder;
  builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
  builder.RegisterService(&service);
  server = builder.BuildAndStart();

  Verilated::commandArgs(argc, argv);

  // Setup a SIGTERM handler to shut down gRPC.
  struct sigaction act = {0};
  act.sa_flags = SA_SIGINFO;
  act.sa_sigaction = sigterm_handler;
  sigaction(SIGTERM, &act, NULL);

  server->Wait();
  if (coralnpu_master_thread.joinable())
    coralnpu_master_thread.join();
  if (coralnpu_slave_thread.joinable())
    coralnpu_slave_thread.join();

  top->final();
#if VM_TRACE
  if (tfp) {
    tfp->close();
    tfp = nullptr;
  }
#endif

  return 0;
}