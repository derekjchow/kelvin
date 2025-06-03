#ifndef TESTS_VCS_SIM_TOP_H_
#define TESTS_VCS_SIM_TOP_H_

#include <stdio.h>
#include <systemc.h>
#include <systemc_user.h>

#include <deque>
#include <optional>
#include <vector>

#include "CoreMiniAxi.h"
#include "VCoreMiniAxi_parameters.h"

#include "tests/systemc/instruction_trace.h"

struct SlogIO {
  sc_signal<sc_logic> valid;
  sc_signal<sc_lv<5>> addr;
  sc_signal<sc_lv<32>> data;
};

struct DebugIO {
  sc_signal<sc_lv<4>> en;
  sc_signal<sc_lv<32>> cycles;
  sc_signal<sc_lv<32>> addr_0;
  sc_signal<sc_lv<32>> addr_1;
  sc_signal<sc_lv<32>> addr_2;
  sc_signal<sc_lv<32>> addr_3;
  sc_signal<sc_lv<32>> inst_0;
  sc_signal<sc_lv<32>> inst_1;
  sc_signal<sc_lv<32>> inst_2;
  sc_signal<sc_lv<32>> inst_3;
  sc_signal<sc_logic> dbus_valid;
  sc_signal<sc_lv<32>> dbus_bits_addr;
  sc_signal<sc_lv<128>> dbus_bits_wdata;
  sc_signal<sc_logic> dbus_bits_write;
  sc_signal<sc_logic> dispatch_0_instFire;
  sc_signal<sc_logic> dispatch_1_instFire;
  sc_signal<sc_logic> dispatch_2_instFire;
  sc_signal<sc_logic> dispatch_3_instFire;
  sc_signal<sc_lv<32>> dispatch_0_instAddr;
  sc_signal<sc_lv<32>> dispatch_1_instAddr;
  sc_signal<sc_lv<32>> dispatch_2_instAddr;
  sc_signal<sc_lv<32>> dispatch_3_instAddr;
  sc_signal<sc_lv<32>> dispatch_0_instInst;
  sc_signal<sc_lv<32>> dispatch_1_instInst;
  sc_signal<sc_lv<32>> dispatch_2_instInst;
  sc_signal<sc_lv<32>> dispatch_3_instInst;
  // Regfile signals
  sc_signal<sc_logic> regfile_writeAddr_0_valid;
  sc_signal<sc_logic> regfile_writeAddr_1_valid;
  sc_signal<sc_logic> regfile_writeAddr_2_valid;
  sc_signal<sc_logic> regfile_writeAddr_3_valid;
  sc_signal<sc_lv<5>> regfile_writeAddr_0_bits;
  sc_signal<sc_lv<5>> regfile_writeAddr_1_bits;
  sc_signal<sc_lv<5>> regfile_writeAddr_2_bits;
  sc_signal<sc_lv<5>> regfile_writeAddr_3_bits;
  sc_signal<sc_logic> regfile_writeData_0_valid;
  sc_signal<sc_logic> regfile_writeData_1_valid;
  sc_signal<sc_logic> regfile_writeData_2_valid;
  sc_signal<sc_logic> regfile_writeData_3_valid;
  sc_signal<sc_logic> regfile_writeData_4_valid;
  sc_signal<sc_logic> regfile_writeData_5_valid;
  sc_signal<sc_lv<5>> regfile_writeData_0_bits_addr;
  sc_signal<sc_lv<5>> regfile_writeData_1_bits_addr;
  sc_signal<sc_lv<5>> regfile_writeData_2_bits_addr;
  sc_signal<sc_lv<5>> regfile_writeData_3_bits_addr;
  sc_signal<sc_lv<5>> regfile_writeData_4_bits_addr;
  sc_signal<sc_lv<5>> regfile_writeData_5_bits_addr;
  sc_signal<sc_lv<32>> regfile_writeData_0_bits_data;
  sc_signal<sc_lv<32>> regfile_writeData_1_bits_data;
  sc_signal<sc_lv<32>> regfile_writeData_2_bits_data;
  sc_signal<sc_lv<32>> regfile_writeData_3_bits_data;
  sc_signal<sc_lv<32>> regfile_writeData_4_bits_data;
  sc_signal<sc_lv<32>> regfile_writeData_5_bits_data;
#if (KP_enableFloat == true)
  sc_signal<sc_logic> float_writeAddr_valid;
  sc_signal<sc_lv<5>> float_writeAddr_bits;
  sc_signal<sc_logic> float_writeData_0_valid;
  sc_signal<sc_logic> float_writeData_1_valid;
  sc_signal<sc_lv<32>> float_writeData_0_bits_addr;
  sc_signal<sc_lv<32>> float_writeData_1_bits_addr;
  sc_signal<sc_lv<32>> float_writeData_0_bits_data;
  sc_signal<sc_lv<32>> float_writeData_1_bits_data;
#endif
};

struct DebugModuleIO {
  sc_signal<sc_logic> req_valid;
  sc_signal<sc_logic> req_ready;
  sc_signal<sc_lv<32>> req_bits_address;
  sc_signal<sc_lv<32>> req_bits_data;
  sc_signal<sc_lv<2>> req_bits_op;
  sc_signal<sc_logic> rsp_valid;
  sc_signal<sc_logic> rsp_ready;
  sc_signal<sc_lv<32>> rsp_bits_data;
  sc_signal<sc_lv<2>> rsp_bits_op;
};

SC_MODULE(sc_top) {
  SC_CTOR(sc_top);

  void negedge();
  struct Instruction {
    uint32_t pc;
    uint32_t inst;
    uint32_t data;
    int reg;
    bool completed;
  };
  std::vector<Instruction> committed_insts_;
  std::deque<Instruction> retirement_buffer_;
  void TraceInstructions();

  void start_of_simulation() override;

  sc_in_clk clock;
  sc_signal<bool> resetn;
  sc_signal<sc_logic> halted;
  sc_signal<sc_logic> fault;
  sc_signal<sc_logic> wfi;
  sc_signal<sc_logic> irq;
  sc_signal<bool> te;

  SlogIO slog;
  DebugIO debug;
  DebugModuleIO dm;
  CoreMiniAxi core;

  sc_signal<sc_logic> slave_awready_4;
  sc_signal<sc_logic> slave_awvalid_4;
  sc_signal<sc_lv<32>> slave_awaddr_4;
  sc_signal<sc_lv<3>> slave_awprot_4;
  sc_signal<sc_lv<6>> slave_awid_4;
  sc_signal<sc_lv<8>> slave_awlen_4;
  sc_signal<sc_lv<3>> slave_awsize_4;
  sc_signal<sc_lv<2>> slave_awburst_4;
  sc_signal<sc_logic> slave_awlock_4;
  sc_signal<sc_lv<4>> slave_awcache_4;
  sc_signal<sc_lv<4>> slave_awqos_4;
  sc_signal<sc_lv<4>> slave_awregion_4;

  sc_out<bool> slave_awready;
  sc_in<bool> slave_awvalid;
  sc_in<sc_bv<32>> slave_awaddr;
  sc_in<sc_bv<3>> slave_awprot;
  sc_in<sc_bv<6>> slave_awid;
  sc_in<sc_bv<8>> slave_awlen;
  sc_in<sc_bv<3>> slave_awsize;
  sc_in<sc_bv<2>> slave_awburst;
  sc_in<bool> slave_awlock;
  sc_in<sc_bv<4>> slave_awcache;
  sc_in<sc_bv<4>> slave_awqos;
  sc_in<sc_bv<4>> slave_awregion;

  sc_signal<sc_logic> slave_wready_4;
  sc_signal<sc_logic> slave_wvalid_4;
  sc_signal<sc_lv<128>> slave_wdata_4;
  sc_signal<sc_lv<16>> slave_wstrb_4;
  sc_signal<sc_logic> slave_wlast_4;

  sc_out<bool> slave_wready;
  sc_in<bool> slave_wvalid;
  sc_in<sc_bv<128>> slave_wdata;
  sc_in<sc_bv<16>> slave_wstrb;
  sc_in<bool> slave_wlast;

  sc_signal<sc_logic> slave_bready_4;
  sc_signal<sc_logic> slave_bvalid_4;
  sc_signal<sc_lv<6>> slave_bid_4;
  sc_signal<sc_lv<2>> slave_bresp_4;

  sc_in<bool> slave_bready;
  sc_out<bool> slave_bvalid;
  sc_out<sc_bv<6>> slave_bid;
  sc_out<sc_bv<2>> slave_bresp;

  sc_signal<sc_logic> slave_arready_4;
  sc_signal<sc_logic> slave_arvalid_4;
  sc_signal<sc_lv<32>> slave_araddr_4;
  sc_signal<sc_lv<3>> slave_arprot_4;
  sc_signal<sc_lv<6>> slave_arid_4;
  sc_signal<sc_lv<8>> slave_arlen_4;
  sc_signal<sc_lv<3>> slave_arsize_4;
  sc_signal<sc_lv<2>> slave_arburst_4;
  sc_signal<sc_logic> slave_arlock_4;
  sc_signal<sc_lv<4>> slave_arcache_4;
  sc_signal<sc_lv<4>> slave_arqos_4;
  sc_signal<sc_lv<4>> slave_arregion_4;

  sc_out<bool> slave_arready;
  sc_in<bool> slave_arvalid;
  sc_in<sc_bv<32>> slave_araddr;
  sc_in<sc_bv<3>> slave_arprot;
  sc_in<sc_bv<6>> slave_arid;
  sc_in<sc_bv<8>> slave_arlen;
  sc_in<sc_bv<3>> slave_arsize;
  sc_in<sc_bv<2>> slave_arburst;
  sc_in<bool> slave_arlock;
  sc_in<sc_bv<4>> slave_arcache;
  sc_in<sc_bv<4>> slave_arqos;
  sc_in<sc_bv<4>> slave_arregion;

  sc_signal<sc_logic> slave_rready_4;
  sc_signal<sc_logic> slave_rvalid_4;
  sc_signal<sc_lv<128>> slave_rdata_4;
  sc_signal<sc_lv<6>> slave_rid_4;
  sc_signal<sc_lv<2>> slave_rresp_4;
  sc_signal<sc_logic> slave_rlast_4;

  sc_in<bool> slave_rready;
  sc_out<bool> slave_rvalid;
  sc_out<sc_bv<128>> slave_rdata;
  sc_out<sc_bv<6>> slave_rid;
  sc_out<sc_bv<2>> slave_rresp;
  sc_out<bool> slave_rlast;

  sc_in<bool> master_awready;
  sc_out<bool> master_awvalid;
  sc_out<sc_bv<32>> master_awaddr;
  sc_out<sc_bv<3>> master_awprot;
  sc_out<sc_bv<6>> master_awid;
  sc_out<sc_bv<8>> master_awlen;
  sc_out<sc_bv<3>> master_awsize;
  sc_out<sc_bv<2>> master_awburst;
  sc_out<bool> master_awlock;
  sc_out<sc_bv<4>> master_awcache;
  sc_out<sc_bv<4>> master_awqos;
  sc_out<sc_bv<4>> master_awregion;

  sc_signal<sc_logic> master_awready_4;
  sc_signal<sc_logic> master_awvalid_4;
  sc_signal<sc_lv<32>> master_awaddr_4;
  sc_signal<sc_lv<3>> master_awprot_4;
  sc_signal<sc_lv<6>> master_awid_4;
  sc_signal<sc_lv<8>> master_awlen_4;
  sc_signal<sc_lv<3>> master_awsize_4;
  sc_signal<sc_lv<2>> master_awburst_4;
  sc_signal<sc_logic> master_awlock_4;
  sc_signal<sc_lv<4>> master_awcache_4;
  sc_signal<sc_lv<4>> master_awqos_4;
  sc_signal<sc_lv<4>> master_awregion_4;

  sc_in<bool> master_wready;
  sc_out<bool> master_wvalid;
  sc_out<sc_bv<128>> master_wdata;
  sc_out<sc_bv<16>> master_wstrb;
  sc_out<bool> master_wlast;

  sc_signal<sc_logic> master_wready_4;
  sc_signal<sc_logic> master_wvalid_4;
  sc_signal<sc_lv<128>> master_wdata_4;
  sc_signal<sc_lv<16>> master_wstrb_4;
  sc_signal<sc_logic> master_wlast_4;

  sc_out<bool> master_bready;
  sc_in<bool> master_bvalid;
  sc_in<sc_bv<6>> master_bid;
  sc_in<sc_bv<2>> master_bresp;

  sc_signal<sc_logic> master_bready_4;
  sc_signal<sc_logic> master_bvalid_4;
  sc_signal<sc_lv<6>> master_bid_4;
  sc_signal<sc_lv<2>> master_bresp_4;

  sc_in<bool> master_arready;
  sc_out<bool> master_arvalid;
  sc_out<sc_bv<32>> master_araddr;
  sc_out<sc_bv<3>> master_arprot;
  sc_out<sc_bv<6>> master_arid;
  sc_out<sc_bv<8>> master_arlen;
  sc_out<sc_bv<3>> master_arsize;
  sc_out<sc_bv<2>> master_arburst;
  sc_out<bool> master_arlock;
  sc_out<sc_bv<4>> master_arcache;
  sc_out<sc_bv<4>> master_arqos;
  sc_out<sc_bv<4>> master_arregion;

  sc_signal<sc_logic> master_arready_4;
  sc_signal<sc_logic> master_arvalid_4;
  sc_signal<sc_lv<32>> master_araddr_4;
  sc_signal<sc_lv<3>> master_arprot_4;
  sc_signal<sc_lv<6>> master_arid_4;
  sc_signal<sc_lv<8>> master_arlen_4;
  sc_signal<sc_lv<3>> master_arsize_4;
  sc_signal<sc_lv<2>> master_arburst_4;
  sc_signal<sc_logic> master_arlock_4;
  sc_signal<sc_lv<4>> master_arcache_4;
  sc_signal<sc_lv<4>> master_arqos_4;
  sc_signal<sc_lv<4>> master_arregion_4;

  sc_out<bool> master_rready;
  sc_in<bool> master_rvalid;
  sc_in<sc_bv<128>> master_rdata;
  sc_in<sc_bv<6>> master_rid;
  sc_in<sc_bv<2>> master_rresp;
  sc_in<bool> master_rlast;

  sc_signal<sc_logic> master_rready_4;
  sc_signal<sc_logic> master_rvalid_4;
  sc_signal<sc_lv<128>> master_rdata_4;
  sc_signal<sc_lv<6>> master_rid_4;
  sc_signal<sc_lv<2>> master_rresp_4;
  sc_signal<sc_logic> master_rlast_4;

  std::optional<uint32_t> tohost_addr_;
  std::optional<uint32_t> fromhost_addr_;
  bool instr_trace_;
  InstructionTrace tracer_;
};

#endif  // TESTS_VCS_SIM_TOP_H_
