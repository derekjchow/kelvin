// Copyright 2023 Google LLC
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

#include "tests/verilator_sim/sysc_tb.h"

#define STRINGIZE(x) #x
#define STR(x) STRINGIZE(x)

#define MODEL_HEADER_SUFFIX .h
#define MODEL_HEADER STR(VERILATOR_MODEL MODEL_HEADER_SUFFIX)
#include MODEL_HEADER

#define PARAMS_HEADER_PREFIX hdl/chisel/src/matcha/
#define PARAMS_HEADER_SUFFIX _parameters.h
#define PARAMS_HEADER STR(PARAMS_HEADER_PREFIX VERILATOR_MODEL PARAMS_HEADER_SUFFIX)
#include PARAMS_HEADER

#include "absl/flags/flag.h"
#include "absl/flags/parse.h"
#include "absl/flags/usage.h"
#include "tests/verilator_sim/matcha/coralnpu_if.h"
#include "tests/verilator_sim/coralnpu/debug_if.h"

ABSL_FLAG(int, cycles, 100000000, "Simulation cycles");
ABSL_FLAG(bool, trace, false, "Dump VCD trace");

struct CoralNPU_tb : Sysc_tb {
  sc_in<bool> io_halted;
  sc_in<bool> io_fault;

  using Sysc_tb::Sysc_tb;  // constructor

  void posedge() {
    check(!io_fault, "io_fault");
    if (io_halted) sc_stop();
  }
};

static void CoralNPU_run(const char* name, const char* bin, const int cycles,
                       const bool trace) {
  VERILATOR_MODEL core(name);
  CoralNPU_tb tb("CoralNPU_tb", cycles, /* random= */ false);
  CoralNPU_if mif("CoralNPU_if", bin);
  Debug_if dbg("Debug_if", &mif);

  sc_signal<bool> host_req;
  sc_signal<bool> finish;
  sc_signal<bool> fault;
  sc_signal<bool> clk_freeze;
  sc_signal<bool> ml_reset;
  sc_signal<bool> volt_sel;
  sc_signal<bool> debug_req;
  sc_signal<bool> slog_valid;
  sc_signal<sc_bv<5> > slog_addr;
  sc_signal<sc_bv<32> > slog_data;
  sc_signal<sc_bv<32> > pc_start;
  sc_signal<bool> cvalid;
  sc_signal<bool> cready;
  sc_signal<bool> cwrite;
  sc_signal<sc_bv<32> > caddr;
  sc_signal<sc_bv<7> > cid;
  sc_signal<sc_bv<KP_lsuDataBits> > wdata;
  sc_signal<sc_bv<KP_lsuDataBits / 8> > wmask;
  sc_signal<bool> rvalid;
  sc_signal<sc_bv<7> > rid;
  sc_signal<sc_bv<KP_lsuDataBits> > rdata;

  ml_reset = 0;
  clk_freeze = 0;
  pc_start = 0x00000000;
  volt_sel = 0;
  debug_req = 0;

  tb.io_halted(finish);
  tb.io_fault(fault);

  core.clk_i(tb.clock);
  core.rst_ni(tb.resetn);
  core.ml_reset(ml_reset);
  core.clk_freeze(clk_freeze);
  core.pc_start(pc_start);
  core.volt_sel(volt_sel);
  core.finish(finish);
  core.fault(fault);
  core.host_req(host_req);
  core.debug_req(debug_req);
  core.slog_valid(slog_valid);
  core.slog_addr(slog_addr);
  core.slog_data(slog_data);

  core.mem_cvalid(cvalid);
  core.mem_cready(cready);
  core.mem_cwrite(cwrite);
  core.mem_caddr(caddr);
  core.mem_cid(cid);
  core.mem_wdata(wdata);
  core.mem_wmask(wmask);
  core.mem_rvalid(rvalid);
  core.mem_rid(rid);
  core.mem_rdata(rdata);

  mif.clock(tb.clock);
  mif.reset(tb.reset);
  mif.io_bus_cvalid(cvalid);
  mif.io_bus_cready(cready);
  mif.io_bus_cwrite(cwrite);
  mif.io_bus_caddr(caddr);
  mif.io_bus_cid(cid);
  mif.io_bus_wdata(wdata);
  mif.io_bus_wmask(wmask);
  mif.io_bus_rvalid(rvalid);
  mif.io_bus_rid(rid);
  mif.io_bus_rdata(rdata);

  dbg.clock(tb.clock);
  dbg.reset(tb.reset);
  dbg.io_slog_valid(slog_valid);
  dbg.io_slog_addr(slog_addr);
  dbg.io_slog_data(slog_data);

  if (trace) {
    tb.trace(&core);
  }

  tb.start();
}

int sc_main(int argc, char *argv[]) {
  absl::SetProgramUsageMessage("CoralNPU SystemC simulation tool");
  auto out_args = absl::ParseCommandLine(argc, argv);
  argc = out_args.size();
  argv = &out_args[0];
  if (argc != 2) {
    fprintf(stderr, "Need one binary input file\n");
    return 1;
  }
  const char* path = argv[1];

  CoralNPU_run(Sysc_tb::get_name(argv[0]), path,
    absl::GetFlag(FLAGS_cycles),
    absl::GetFlag(FLAGS_trace));
  return 0;
}
