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

#define STRINGIZE(x) #x
#define STR(x) STRINGIZE(x)
#define MODEL_HEADER_SUFFIX .h
#define MODEL_HEADER STR(VERILATOR_MODEL MODEL_HEADER_SUFFIX)
#include MODEL_HEADER

#define PARAMS_HEADER_PREFIX hdl/chisel/src/kelvin/
#define PARAMS_HEADER_SUFFIX _parameters.h
#define PARAMS_HEADER STR(PARAMS_HEADER_PREFIX VERILATOR_MODEL PARAMS_HEADER_SUFFIX)
#include PARAMS_HEADER

#include "absl/flags/flag.h"
#include "absl/flags/parse.h"
#include "absl/flags/usage.h"
#include "tests/verilator_sim/kelvin/core_if.h"
#include "tests/verilator_sim/kelvin/debug_if.h"
#include "tests/verilator_sim/kelvin/kelvin_cfg.h"
#include "tests/verilator_sim/sysc_tb.h"
#include "tests/verilator_sim/util.h"

ABSL_FLAG(int, cycles, 100000000, "Simulation cycles");
ABSL_FLAG(bool, trace, false, "Dump VCD trace");

struct Core_tb : Sysc_tb {
  sc_in<bool> io_halted;
  sc_in<bool> io_fault;

  using Sysc_tb::Sysc_tb;  // constructor

  void posedge() {
    check(!io_fault, "io_fault");
    if (io_halted) sc_stop();
  }
};

static void Core_run(const char* name, const char* bin, const int cycles,
                     const bool trace) {
  VERILATOR_MODEL core(name);
  Core_tb tb("Core_tb", cycles, /* random= */ false);
  Core_if mif("Core_if", bin);
  Debug_if dbg("Debug_if", &mif);

  sc_signal<bool> io_halted;
  sc_signal<bool> io_fault;
  sc_signal<bool> io_debug_req;
  sc_signal<bool> io_ibus_valid;
  sc_signal<bool> io_ibus_ready;
  sc_signal<bool> io_dbus_valid;
  sc_signal<bool> io_dbus_ready;
  sc_signal<bool> io_dbus_write;
  sc_signal<bool> io_iflush_valid;
  sc_signal<bool> io_iflush_ready;
  sc_signal<bool> io_dflush_valid;
  sc_signal<bool> io_dflush_ready;
  sc_signal<bool> io_dflush_all;
  sc_signal<bool> io_dflush_clean;
  sc_signal<bool> io_slog_valid;
  sc_signal<sc_bv<32> > io_csr_in_value_0;
  sc_signal<sc_bv<32> > io_csr_in_value_1;
  sc_signal<sc_bv<32> > io_csr_in_value_2;
  sc_signal<sc_bv<32> > io_csr_in_value_3;
  sc_signal<sc_bv<32> > io_csr_in_value_4;
  sc_signal<sc_bv<32> > io_csr_in_value_5;
  sc_signal<sc_bv<32> > io_csr_in_value_6;
  sc_signal<sc_bv<32> > io_csr_in_value_7;
  sc_signal<sc_bv<32> > io_csr_in_value_8;
  sc_signal<sc_bv<32> > io_csr_in_value_9;
  sc_signal<sc_bv<32> > io_csr_in_value_10;
  sc_signal<sc_bv<32> > io_csr_in_value_11;
  sc_signal<sc_bv<32> > io_csr_in_value_12;
  sc_signal<sc_bv<32> > io_csr_out_value_0;
  sc_signal<sc_bv<32> > io_csr_out_value_1;
  sc_signal<sc_bv<32> > io_csr_out_value_2;
  sc_signal<sc_bv<32> > io_csr_out_value_3;
  sc_signal<sc_bv<32> > io_csr_out_value_4;
  sc_signal<sc_bv<32> > io_csr_out_value_5;
  sc_signal<sc_bv<32> > io_csr_out_value_6;
  sc_signal<sc_bv<32> > io_csr_out_value_7;
  sc_signal<sc_bv<32> > io_ibus_addr;
  sc_signal<sc_bv<KP_fetchDataBits> > io_ibus_rdata;
  sc_signal<sc_bv<32> > io_dbus_addr;
  sc_signal<sc_bv<32> > io_dbus_adrx;
  sc_signal<sc_bv<KP_dbusSize> > io_dbus_size;
  sc_signal<sc_bv<KP_lsuDataBits> > io_dbus_wdata;
  sc_signal<sc_bv<KP_lsuDataBits / 8> > io_dbus_wmask;
  sc_signal<sc_bv<KP_lsuDataBits> > io_dbus_rdata;
  sc_signal<sc_bv<5> > io_slog_addr;
  sc_signal<sc_bv<32> > io_slog_data;
  sc_signal<sc_bv<4> > io_debug_en;
  sc_signal<sc_bv<32> > io_debug_cycles;
#if KP_enableVector
  sc_signal<bool> io_axi0_write_addr_ready;
  sc_signal<bool> io_axi0_write_addr_valid;
  sc_signal<sc_bv<32> > io_axi0_write_addr_bits_addr;
  sc_signal<sc_bv<kUncId> > io_axi0_write_addr_bits_id;
  sc_signal<sc_bv<4> > io_axi0_write_addr_bits_region;
  sc_signal<sc_bv<4> > io_axi0_write_addr_bits_qos;
  sc_signal<sc_bv<3> > io_axi0_write_addr_bits_prot;
  sc_signal<sc_bv<4> > io_axi0_write_addr_bits_cache;
  sc_signal<sc_bv<2> > io_axi0_write_addr_bits_lock;
  sc_signal<sc_bv<2> > io_axi0_write_addr_bits_burst;
  sc_signal<sc_bv<3> > io_axi0_write_addr_bits_size;
  sc_signal<sc_bv<8> > io_axi0_write_addr_bits_len;
  sc_signal<bool> io_axi0_write_data_ready;
  sc_signal<bool> io_axi0_write_data_valid;
  sc_signal<sc_bv<KP_lsuDataBits> > io_axi0_write_data_bits_data;
  sc_signal<sc_bv<KP_lsuDataBits/8> > io_axi0_write_data_bits_strb;
  sc_signal<sc_bv<6> > io_axi0_write_data_bits_id;
  sc_signal<bool> io_axi0_write_data_bits_last;
  sc_signal<bool> io_axi0_write_resp_ready;
  sc_signal<bool> io_axi0_write_resp_valid;
  sc_signal<sc_bv<kUncId> > io_axi0_write_resp_bits_id;
  sc_signal<sc_bv<2> > io_axi0_write_resp_bits_resp;
  sc_signal<bool> io_axi0_read_addr_ready;
  sc_signal<bool> io_axi0_read_addr_valid;
  sc_signal<sc_bv<32> > io_axi0_read_addr_bits_addr;
  sc_signal<sc_bv<kUncId> > io_axi0_read_addr_bits_id;
  sc_signal<sc_bv<4> > io_axi0_read_addr_bits_region;
  sc_signal<sc_bv<4> > io_axi0_read_addr_bits_qos;
  sc_signal<sc_bv<3> > io_axi0_read_addr_bits_prot;
  sc_signal<sc_bv<4> > io_axi0_read_addr_bits_cache;
  sc_signal<sc_bv<2> > io_axi0_read_addr_bits_lock;
  sc_signal<sc_bv<2> > io_axi0_read_addr_bits_burst;
  sc_signal<sc_bv<3> > io_axi0_read_addr_bits_size;
  sc_signal<sc_bv<8> > io_axi0_read_addr_bits_len;
  sc_signal<bool> io_axi0_read_data_ready;
  sc_signal<bool> io_axi0_read_data_valid;
  sc_signal<sc_bv<2> > io_axi0_read_data_bits_resp;
  sc_signal<sc_bv<kUncId> > io_axi0_read_data_bits_id;
  sc_signal<sc_bv<KP_lsuDataBits> > io_axi0_read_data_bits_data;
  sc_signal<bool> io_axi0_read_data_bits_last;
#endif  // KP_enableVector
  sc_signal<bool> io_axi1_write_addr_ready;
  sc_signal<bool> io_axi1_write_addr_valid;
  sc_signal<sc_bv<32> > io_axi1_write_addr_bits_addr;
  sc_signal<sc_bv<kUncId> > io_axi1_write_addr_bits_id;
  sc_signal<sc_bv<4> > io_axi1_write_addr_bits_region;
  sc_signal<sc_bv<4> > io_axi1_write_addr_bits_qos;
  sc_signal<sc_bv<3> > io_axi1_write_addr_bits_prot;
  sc_signal<sc_bv<4> > io_axi1_write_addr_bits_cache;
  sc_signal<sc_bv<2> > io_axi1_write_addr_bits_lock;
  sc_signal<sc_bv<2> > io_axi1_write_addr_bits_burst;
  sc_signal<sc_bv<3> > io_axi1_write_addr_bits_size;
  sc_signal<sc_bv<8> > io_axi1_write_addr_bits_len;
  sc_signal<bool> io_axi1_write_data_ready;
  sc_signal<bool> io_axi1_write_data_valid;
  sc_signal<sc_bv<KP_lsuDataBits> > io_axi1_write_data_bits_data;
  sc_signal<sc_bv<KP_lsuDataBits/8> > io_axi1_write_data_bits_strb;
  sc_signal<sc_bv<6> > io_axi1_write_data_bits_id;
  sc_signal<bool> io_axi1_write_data_bits_last;
  sc_signal<bool> io_axi1_write_resp_ready;
  sc_signal<bool> io_axi1_write_resp_valid;
  sc_signal<sc_bv<kUncId> > io_axi1_write_resp_bits_id;
  sc_signal<sc_bv<2> > io_axi1_write_resp_bits_resp;
  sc_signal<bool> io_axi1_read_addr_ready;
  sc_signal<bool> io_axi1_read_addr_valid;
  sc_signal<sc_bv<32> > io_axi1_read_addr_bits_addr;
  sc_signal<sc_bv<kUncId> > io_axi1_read_addr_bits_id;
  sc_signal<sc_bv<4> > io_axi1_read_addr_bits_region;
  sc_signal<sc_bv<4> > io_axi1_read_addr_bits_qos;
  sc_signal<sc_bv<3> > io_axi1_read_addr_bits_prot;
  sc_signal<sc_bv<4> > io_axi1_read_addr_bits_cache;
  sc_signal<sc_bv<2> > io_axi1_read_addr_bits_lock;
  sc_signal<sc_bv<2> > io_axi1_read_addr_bits_burst;
  sc_signal<sc_bv<3> > io_axi1_read_addr_bits_size;
  sc_signal<sc_bv<8> > io_axi1_read_addr_bits_len;
  sc_signal<bool> io_axi1_read_data_ready;
  sc_signal<bool> io_axi1_read_data_valid;
  sc_signal<sc_bv<2> > io_axi1_read_data_bits_resp;
  sc_signal<sc_bv<kUncId> > io_axi1_read_data_bits_id;
  sc_signal<sc_bv<KP_lsuDataBits> > io_axi1_read_data_bits_data;
  sc_signal<bool> io_axi1_read_data_bits_last;

#define IO_DEBUG(x)                       \
  sc_signal<sc_bv<32> > io_debug_addr##x; \
  sc_signal<sc_bv<32> > io_debug_inst##x;
  REPEAT(IO_DEBUG, KP_instructionLanes);
#undef IO_DEBUG

  io_iflush_ready = 1;
  io_dflush_ready = 1;

  tb.io_halted(io_halted);
  tb.io_fault(io_fault);

  core.clock(tb.clock);
  core.reset(tb.reset);
  core.io_halted(io_halted);
  core.io_fault(io_fault);
  core.io_debug_req(io_debug_req);
  core.io_ibus_valid(io_ibus_valid);
  core.io_ibus_ready(io_ibus_ready);
  core.io_dbus_valid(io_dbus_valid);
  core.io_dbus_ready(io_dbus_ready);
  core.io_dbus_write(io_dbus_write);
  core.io_iflush_valid(io_iflush_valid);
  core.io_iflush_ready(io_iflush_ready);
  core.io_dflush_valid(io_dflush_valid);
  core.io_dflush_ready(io_dflush_ready);
  core.io_dflush_all(io_dflush_all);
  core.io_dflush_clean(io_dflush_clean);
  core.io_slog_valid(io_slog_valid);
  core.io_csr_in_value_0(io_csr_in_value_0);
  core.io_csr_in_value_1(io_csr_in_value_1);
  core.io_csr_in_value_2(io_csr_in_value_2);
  core.io_csr_in_value_3(io_csr_in_value_3);
  core.io_csr_in_value_4(io_csr_in_value_4);
  core.io_csr_in_value_5(io_csr_in_value_5);
  core.io_csr_in_value_6(io_csr_in_value_6);
  core.io_csr_in_value_7(io_csr_in_value_7);
  core.io_csr_in_value_8(io_csr_in_value_8);
  core.io_csr_in_value_9(io_csr_in_value_9);
  core.io_csr_in_value_10(io_csr_in_value_10);
  core.io_csr_in_value_11(io_csr_in_value_11);
  core.io_csr_in_value_12(io_csr_in_value_12);
  core.io_csr_out_value_0(io_csr_out_value_0);
  core.io_csr_out_value_1(io_csr_out_value_1);
  core.io_csr_out_value_2(io_csr_out_value_2);
  core.io_csr_out_value_3(io_csr_out_value_3);
  core.io_csr_out_value_4(io_csr_out_value_4);
  core.io_csr_out_value_5(io_csr_out_value_5);
  core.io_csr_out_value_6(io_csr_out_value_6);
  core.io_csr_out_value_7(io_csr_out_value_7);
  core.io_ibus_addr(io_ibus_addr);
  core.io_ibus_rdata(io_ibus_rdata);
  core.io_dbus_addr(io_dbus_addr);
  core.io_dbus_adrx(io_dbus_adrx);
  core.io_dbus_size(io_dbus_size);
  core.io_dbus_wdata(io_dbus_wdata);
  core.io_dbus_wmask(io_dbus_wmask);
  core.io_dbus_rdata(io_dbus_rdata);
  core.io_slog_addr(io_slog_addr);
  core.io_slog_data(io_slog_data);
  core.io_debug_en(io_debug_en);
  core.io_debug_cycles(io_debug_cycles);

#define BIND_DEBUG(x)                       \
  core.io_debug_addr_##x(io_debug_addr##x); \
  core.io_debug_inst_##x(io_debug_inst##x);
  REPEAT(BIND_DEBUG, KP_instructionLanes);
#undef BIND_DEBUG

  mif.clock(tb.clock);
  mif.reset(tb.reset);
  mif.io_ibus_valid(io_ibus_valid);
  mif.io_ibus_ready(io_ibus_ready);
  mif.io_ibus_addr(io_ibus_addr);
  mif.io_ibus_rdata(io_ibus_rdata);
  mif.io_dbus_valid(io_dbus_valid);
  mif.io_dbus_ready(io_dbus_ready);
  mif.io_dbus_write(io_dbus_write);
  mif.io_dbus_addr(io_dbus_addr);
  mif.io_dbus_adrx(io_dbus_adrx);
  mif.io_dbus_size(io_dbus_size);
  mif.io_dbus_wdata(io_dbus_wdata);
  mif.io_dbus_wmask(io_dbus_wmask);
  mif.io_dbus_rdata(io_dbus_rdata);

  dbg.clock(tb.clock);
  dbg.reset(tb.reset);
  dbg.io_slog_valid(io_slog_valid);
  dbg.io_slog_addr(io_slog_addr);
  dbg.io_slog_data(io_slog_data);

#define BINDAXI(a) \
  core.a(a);       \
  mif.a(a)
#if KP_enableVector
  BINDAXI(io_axi0_write_addr_ready);
  BINDAXI(io_axi0_write_addr_valid);
  BINDAXI(io_axi0_write_addr_bits_addr);
  BINDAXI(io_axi0_write_addr_bits_id);
  BINDAXI(io_axi0_write_addr_bits_region);
  BINDAXI(io_axi0_write_addr_bits_qos);
  BINDAXI(io_axi0_write_addr_bits_prot);
  BINDAXI(io_axi0_write_addr_bits_cache);
  BINDAXI(io_axi0_write_addr_bits_lock);
  BINDAXI(io_axi0_write_addr_bits_burst);
  BINDAXI(io_axi0_write_addr_bits_size);
  BINDAXI(io_axi0_write_addr_bits_len);
  BINDAXI(io_axi0_write_data_ready);
  BINDAXI(io_axi0_write_data_valid);
  BINDAXI(io_axi0_write_data_bits_data);
  BINDAXI(io_axi0_write_data_bits_strb);
  BINDAXI(io_axi0_write_data_bits_id);
  BINDAXI(io_axi0_write_data_bits_last);
  BINDAXI(io_axi0_write_resp_ready);
  BINDAXI(io_axi0_write_resp_valid);
  BINDAXI(io_axi0_write_resp_bits_id);
  BINDAXI(io_axi0_write_resp_bits_resp);
  BINDAXI(io_axi0_read_addr_ready);
  BINDAXI(io_axi0_read_addr_valid);
  BINDAXI(io_axi0_read_addr_bits_addr);
  BINDAXI(io_axi0_read_addr_bits_id);
  BINDAXI(io_axi0_read_addr_bits_region);
  BINDAXI(io_axi0_read_addr_bits_qos);
  BINDAXI(io_axi0_read_addr_bits_prot);
  BINDAXI(io_axi0_read_addr_bits_cache);
  BINDAXI(io_axi0_read_addr_bits_lock);
  BINDAXI(io_axi0_read_addr_bits_burst);
  BINDAXI(io_axi0_read_addr_bits_size);
  BINDAXI(io_axi0_read_addr_bits_len);
  BINDAXI(io_axi0_read_data_ready);
  BINDAXI(io_axi0_read_data_valid);
  BINDAXI(io_axi0_read_data_bits_resp);
  BINDAXI(io_axi0_read_data_bits_id);
  BINDAXI(io_axi0_read_data_bits_data);
  BINDAXI(io_axi0_read_data_bits_last);
#endif  // KP_enableVector
  BINDAXI(io_axi1_write_addr_ready);
  BINDAXI(io_axi1_write_addr_valid);
  BINDAXI(io_axi1_write_addr_bits_addr);
  BINDAXI(io_axi1_write_addr_bits_id);
  BINDAXI(io_axi1_write_addr_bits_region);
  BINDAXI(io_axi1_write_addr_bits_qos);
  BINDAXI(io_axi1_write_addr_bits_prot);
  BINDAXI(io_axi1_write_addr_bits_cache);
  BINDAXI(io_axi1_write_addr_bits_lock);
  BINDAXI(io_axi1_write_addr_bits_burst);
  BINDAXI(io_axi1_write_addr_bits_size);
  BINDAXI(io_axi1_write_addr_bits_len);
  BINDAXI(io_axi1_write_data_ready);
  BINDAXI(io_axi1_write_data_valid);
  BINDAXI(io_axi1_write_data_bits_data);
  BINDAXI(io_axi1_write_data_bits_strb);
  BINDAXI(io_axi1_write_data_bits_id);
  BINDAXI(io_axi1_write_data_bits_last);
  BINDAXI(io_axi1_write_resp_ready);
  BINDAXI(io_axi1_write_resp_valid);
  BINDAXI(io_axi1_write_resp_bits_id);
  BINDAXI(io_axi1_write_resp_bits_resp);
  BINDAXI(io_axi1_read_addr_ready);
  BINDAXI(io_axi1_read_addr_valid);
  BINDAXI(io_axi1_read_addr_bits_addr);
  BINDAXI(io_axi1_read_addr_bits_id);
  BINDAXI(io_axi1_read_addr_bits_region);
  BINDAXI(io_axi1_read_addr_bits_qos);
  BINDAXI(io_axi1_read_addr_bits_prot);
  BINDAXI(io_axi1_read_addr_bits_cache);
  BINDAXI(io_axi1_read_addr_bits_lock);
  BINDAXI(io_axi1_read_addr_bits_burst);
  BINDAXI(io_axi1_read_addr_bits_size);
  BINDAXI(io_axi1_read_addr_bits_len);
  BINDAXI(io_axi1_read_data_ready);
  BINDAXI(io_axi1_read_data_valid);
  BINDAXI(io_axi1_read_data_bits_resp);
  BINDAXI(io_axi1_read_data_bits_id);
  BINDAXI(io_axi1_read_data_bits_data);
  BINDAXI(io_axi1_read_data_bits_last);

  if (trace) {
    tb.trace(&core);
  }

  tb.start();
}

int sc_main(int argc, char *argv[]) {
  absl::SetProgramUsageMessage("Kelvin SystemC simulation tool");
  auto out_args = absl::ParseCommandLine(argc, argv);
  argc = out_args.size();
  argv = &out_args[0];
  if (argc != 2) {
    fprintf(stderr, "Need one binary input file\n");
    return 1;
  }
  const char* path = argv[1];

  Core_run(Sysc_tb::get_name(argv[0]), path, absl::GetFlag(FLAGS_cycles),
           absl::GetFlag(FLAGS_trace));
  return 0;
}
