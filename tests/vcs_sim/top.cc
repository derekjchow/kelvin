#include "top.h"

#include <systemc.h>

sc_top::sc_top(sc_core::sc_module_name name)
    : clock("clock"), core("core_mini_axi") {
  core.io_aclk(clock);
  core.io_aresetn(resetn);
  core.io_halted(halted);
  core.io_fault(fault);
  core.io_wfi(wfi);
  core.io_irq(irq);
  core.io_te(te);

  core.io_slog_valid(slog.valid);
  core.io_slog_addr(slog.addr);
  core.io_slog_data(slog.data);
  core.io_debug_en(debug.en);
  core.io_debug_cycles(debug.cycles);
  core.io_debug_addr_0(debug.addr_0);
  core.io_debug_addr_1(debug.addr_1);
  core.io_debug_addr_2(debug.addr_2);
  core.io_debug_addr_3(debug.addr_3);
  core.io_debug_inst_0(debug.inst_0);
  core.io_debug_inst_1(debug.inst_1);
  core.io_debug_inst_2(debug.inst_2);
  core.io_debug_inst_3(debug.inst_3);
  core.io_debug_dbus_valid(debug.dbus_valid);
  core.io_debug_dbus_bits_addr(debug.dbus_bits_addr);
  core.io_debug_dbus_bits_wdata(debug.dbus_bits_wdata);
  core.io_debug_dbus_bits_write(debug.dbus_bits_write);
  core.io_debug_dispatch_0_instFire(debug.dispatch_0_instFire);
  core.io_debug_dispatch_1_instFire(debug.dispatch_1_instFire);
  core.io_debug_dispatch_2_instFire(debug.dispatch_2_instFire);
  core.io_debug_dispatch_3_instFire(debug.dispatch_3_instFire);
  core.io_debug_dispatch_0_instAddr(debug.dispatch_0_instAddr);
  core.io_debug_dispatch_1_instAddr(debug.dispatch_1_instAddr);
  core.io_debug_dispatch_2_instAddr(debug.dispatch_2_instAddr);
  core.io_debug_dispatch_3_instAddr(debug.dispatch_3_instAddr);
  core.io_debug_dispatch_0_instInst(debug.dispatch_0_instInst);
  core.io_debug_dispatch_1_instInst(debug.dispatch_1_instInst);
  core.io_debug_dispatch_2_instInst(debug.dispatch_2_instInst);
  core.io_debug_dispatch_3_instInst(debug.dispatch_3_instInst);
  core.io_debug_regfile_writeAddr_0_valid(debug.regfile_writeAddr_0_valid);
  core.io_debug_regfile_writeAddr_1_valid(debug.regfile_writeAddr_1_valid);
  core.io_debug_regfile_writeAddr_2_valid(debug.regfile_writeAddr_2_valid);
  core.io_debug_regfile_writeAddr_3_valid(debug.regfile_writeAddr_3_valid);
  core.io_debug_regfile_writeAddr_0_bits(debug.regfile_writeAddr_0_bits);
  core.io_debug_regfile_writeAddr_1_bits(debug.regfile_writeAddr_1_bits);
  core.io_debug_regfile_writeAddr_2_bits(debug.regfile_writeAddr_2_bits);
  core.io_debug_regfile_writeAddr_3_bits(debug.regfile_writeAddr_3_bits);
  core.io_debug_regfile_writeData_0_valid(debug.regfile_writeData_0_valid);
  core.io_debug_regfile_writeData_1_valid(debug.regfile_writeData_1_valid);
  core.io_debug_regfile_writeData_2_valid(debug.regfile_writeData_2_valid);
  core.io_debug_regfile_writeData_3_valid(debug.regfile_writeData_3_valid);
  core.io_debug_regfile_writeData_4_valid(debug.regfile_writeData_4_valid);
  core.io_debug_regfile_writeData_5_valid(debug.regfile_writeData_5_valid);
  core.io_debug_regfile_writeData_0_bits_addr(debug.regfile_writeData_0_bits_addr);
  core.io_debug_regfile_writeData_1_bits_addr(debug.regfile_writeData_1_bits_addr);
  core.io_debug_regfile_writeData_2_bits_addr(debug.regfile_writeData_2_bits_addr);
  core.io_debug_regfile_writeData_3_bits_addr(debug.regfile_writeData_3_bits_addr);
  core.io_debug_regfile_writeData_4_bits_addr(debug.regfile_writeData_4_bits_addr);
  core.io_debug_regfile_writeData_5_bits_addr(debug.regfile_writeData_5_bits_addr);
  core.io_debug_regfile_writeData_0_bits_data(debug.regfile_writeData_0_bits_data);
  core.io_debug_regfile_writeData_1_bits_data(debug.regfile_writeData_1_bits_data);
  core.io_debug_regfile_writeData_2_bits_data(debug.regfile_writeData_2_bits_data);
  core.io_debug_regfile_writeData_3_bits_data(debug.regfile_writeData_3_bits_data);
  core.io_debug_regfile_writeData_4_bits_data(debug.regfile_writeData_4_bits_data);
  core.io_debug_regfile_writeData_5_bits_data(debug.regfile_writeData_5_bits_data);
#if (KP_enableFloat == true)
  core.io_debug_float_writeAddr_valid(debug.float_writeAddr_valid);
  core.io_debug_float_writeAddr_bits(debug.float_writeAddr_bits);
  core.io_debug_float_writeData_0_valid(debug.float_writeData_0_valid);
  core.io_debug_float_writeData_1_valid(debug.float_writeData_1_valid);
  core.io_debug_float_writeData_0_bits_addr(debug.float_writeData_0_bits_addr);
  core.io_debug_float_writeData_1_bits_addr(debug.float_writeData_1_bits_addr);
  core.io_debug_float_writeData_0_bits_data(debug.float_writeData_0_bits_data);
  core.io_debug_float_writeData_1_bits_data(debug.float_writeData_1_bits_data);
#endif
#if (KP_useDebugModule == true)
  core.io_dm_req_valid(dm.req_valid);
  core.io_dm_req_ready(dm.req_valid);
  core.io_dm_req_bits_address(dm.req_bits_address);
  core.io_dm_req_bits_data(dm.req_bits_data);
  core.io_dm_req_bits_op(dm.req_bits_op);
  core.io_dm_rsp_valid(dm.rsp_valid);
  core.io_dm_rsp_ready(dm.rsp_valid);
  core.io_dm_rsp_bits_data(dm.rsp_bits_data);
  core.io_dm_rsp_bits_op(dm.rsp_bits_op);
#endif
  // AR
  core.io_axi_master_read_addr_ready(master_arready_4);
  core.io_axi_master_read_addr_valid(master_arvalid_4);
  core.io_axi_master_read_addr_bits_addr(master_araddr_4);
  core.io_axi_master_read_addr_bits_prot(master_arprot_4);
  core.io_axi_master_read_addr_bits_id(master_arid_4);
  core.io_axi_master_read_addr_bits_len(master_arlen_4);
  core.io_axi_master_read_addr_bits_size(master_arsize_4);
  core.io_axi_master_read_addr_bits_burst(master_arburst_4);
  core.io_axi_master_read_addr_bits_lock(master_arlock_4);
  core.io_axi_master_read_addr_bits_cache(master_arcache_4);
  core.io_axi_master_read_addr_bits_qos(master_arqos_4);
  core.io_axi_master_read_addr_bits_region(master_arregion_4);
  // B
  core.io_axi_master_read_data_ready(master_rready_4);
  core.io_axi_master_read_data_valid(master_rvalid_4);
  core.io_axi_master_read_data_bits_data(master_rdata_4);
  core.io_axi_master_read_data_bits_id(master_rid_4);
  core.io_axi_master_read_data_bits_resp(master_rresp_4);
  core.io_axi_master_read_data_bits_last(master_rlast_4);
  // AW
  core.io_axi_master_write_addr_ready(master_awready_4);
  core.io_axi_master_write_addr_valid(master_awvalid_4);
  core.io_axi_master_write_addr_bits_addr(master_awaddr_4);
  core.io_axi_master_write_addr_bits_prot(master_awprot_4);
  core.io_axi_master_write_addr_bits_id(master_awid_4);
  core.io_axi_master_write_addr_bits_len(master_awlen_4);
  core.io_axi_master_write_addr_bits_size(master_awsize_4);
  core.io_axi_master_write_addr_bits_burst(master_awburst_4);
  core.io_axi_master_write_addr_bits_lock(master_awlock_4);
  core.io_axi_master_write_addr_bits_cache(master_awcache_4);
  core.io_axi_master_write_addr_bits_qos(master_awqos_4);
  core.io_axi_master_write_addr_bits_region(master_awregion_4);
  // W
  core.io_axi_master_write_data_ready(master_wready_4);
  core.io_axi_master_write_data_valid(master_wvalid_4);
  core.io_axi_master_write_data_bits_data(master_wdata_4);
  core.io_axi_master_write_data_bits_last(master_wlast_4);
  core.io_axi_master_write_data_bits_strb(master_wstrb_4);
  // B
  core.io_axi_master_write_resp_ready(master_bready_4);
  core.io_axi_master_write_resp_valid(master_bvalid_4);
  core.io_axi_master_write_resp_bits_id(master_bid_4);
  core.io_axi_master_write_resp_bits_resp(master_bresp_4);

  // AR
  core.io_axi_slave_read_addr_ready(slave_arready_4);
  core.io_axi_slave_read_addr_valid(slave_arvalid_4);
  core.io_axi_slave_read_addr_bits_addr(slave_araddr_4);
  core.io_axi_slave_read_addr_bits_prot(slave_arprot_4);
  core.io_axi_slave_read_addr_bits_id(slave_arid_4);
  core.io_axi_slave_read_addr_bits_len(slave_arlen_4);
  core.io_axi_slave_read_addr_bits_size(slave_arsize_4);
  core.io_axi_slave_read_addr_bits_burst(slave_arburst_4);
  core.io_axi_slave_read_addr_bits_lock(slave_arlock_4);
  core.io_axi_slave_read_addr_bits_cache(slave_arcache_4);
  core.io_axi_slave_read_addr_bits_qos(slave_arqos_4);
  core.io_axi_slave_read_addr_bits_region(slave_arregion_4);
  // R
  core.io_axi_slave_read_data_ready(slave_rready_4);
  core.io_axi_slave_read_data_valid(slave_rvalid_4);
  core.io_axi_slave_read_data_bits_data(slave_rdata_4);
  core.io_axi_slave_read_data_bits_id(slave_rid_4);
  core.io_axi_slave_read_data_bits_resp(slave_rresp_4);
  core.io_axi_slave_read_data_bits_last(slave_rlast_4);
  // AW
  core.io_axi_slave_write_addr_ready(slave_awready_4);
  core.io_axi_slave_write_addr_valid(slave_awvalid_4);
  core.io_axi_slave_write_addr_bits_addr(slave_awaddr_4);
  core.io_axi_slave_write_addr_bits_prot(slave_awprot_4);
  core.io_axi_slave_write_addr_bits_id(slave_awid_4);
  core.io_axi_slave_write_addr_bits_len(slave_awlen_4);
  core.io_axi_slave_write_addr_bits_size(slave_awsize_4);
  core.io_axi_slave_write_addr_bits_burst(slave_awburst_4);
  core.io_axi_slave_write_addr_bits_lock(slave_awlock_4);
  core.io_axi_slave_write_addr_bits_cache(slave_awcache_4);
  core.io_axi_slave_write_addr_bits_qos(slave_awqos_4);
  core.io_axi_slave_write_addr_bits_region(slave_awregion_4);
  // W
  core.io_axi_slave_write_data_ready(slave_wready_4);
  core.io_axi_slave_write_data_valid(slave_wvalid_4);
  core.io_axi_slave_write_data_bits_data(slave_wdata_4);
  core.io_axi_slave_write_data_bits_last(slave_wlast_4);
  core.io_axi_slave_write_data_bits_strb(slave_wstrb_4);
  // B
  core.io_axi_slave_write_resp_ready(slave_bready_4);
  core.io_axi_slave_write_resp_valid(slave_bvalid_4);
  core.io_axi_slave_write_resp_bits_id(slave_bid_4);
  core.io_axi_slave_write_resp_bits_resp(slave_bresp_4);

  SC_METHOD(negedge);
  sensitive << clock.neg();
}

void sc_top::start_of_simulation() {
  resetn = 0;
  te = 0;
  irq = sc_dt::Log_0;
}

void sc_top::negedge() {
  if (hdl_elaboration_only()) {
    return;
  }

  // Check for halt/fault, and if either are seen
  // report the state and stop the simulation.
  bool faulted = false;
  bool halt = false;
  if (halted.read().is_01() && halted.read().to_bool()) {
    if (fault.read().is_01() && fault.read().to_bool()) {
      faulted = true;
    } else {
      halt = true;
    }
  }

  // Generate a reset pulse in the first few cycles.
  static int edge_count = 0;
  if (edge_count == 1) {
    resetn = 1;
  }
  if (edge_count == 3) {
    resetn = 0;
  } else if (edge_count == 5) {
    resetn = 1;
  }
  if (edge_count <= 5) {
    edge_count++;
    return;
  }

  bool tohost_halt = false;
  if (tohost_addr_.has_value()) {
    sc_logic dbus_valid = debug.dbus_valid.read();
    if (dbus_valid.is_01() && dbus_valid.to_bool()) {
      sc_lv<32> dbus_addr = debug.dbus_bits_addr.read();
      if (dbus_addr.get_word(0) == tohost_addr_.value()) {
        sc_lv<128> dbus_wdata = debug.dbus_bits_wdata.read();
        if (dbus_wdata.get_word(0) & 1) {
          tohost_halt = true;
        }
      }
    }
  }

  if (instr_trace_) {
    TraceInstructions();
  }

  if (tohost_halt || halt || faulted) {
    if (instr_trace_) {
      tracer_.PrintTrace();
    }
  }

  if (tohost_halt) {
    printf("DUT requested halt.\n");
    sc_stop();
  }

  if (halt) {
    if (faulted) {
      printf("Fault detected, halting.\n");
    } else {
      printf("Halted successfully (via mpause).\n");
    }
    sc_stop();
  }

  // The below sections move data between the SystemC world
  // and RTL world, and convert between 2-state and 4-state
  // logic.

  // S - R
  tli_set_logic(sc_logic(slave_rready),
                "top.core_mini_axi.io_axi_slave_read_data_ready");
  if (slave_rvalid_4.read().is_01()) {
    slave_rvalid = slave_rvalid_4.read().to_bool();
  }
  if (slave_rdata_4.read().is_01()) {
    slave_rdata = slave_rdata_4.read();
  }
  if (slave_rid_4.read().is_01()) {
    slave_rid = slave_rid_4.read();
  }
  if (slave_rresp_4.read().is_01()) {
    slave_rresp = slave_rresp_4.read();
  }
  if (slave_rlast_4.read().is_01()) {
    slave_rlast = slave_rlast_4.read().to_bool();
  }

  // S - AR
  if (slave_arready_4.read().is_01()) {
    slave_arready = slave_arready_4.read().to_bool();
  }
  tli_set_logic(sc_logic(slave_arvalid),
                "top.core_mini_axi.io_axi_slave_read_addr_valid");
  tli_set_lv(sc_lv<32>(slave_araddr.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_read_addr_bits_addr");
  tli_set_lv(sc_lv<3>(slave_arprot.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_read_addr_bits_prot");
  tli_set_lv(sc_lv<6>(slave_arid.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_read_addr_bits_id");
  tli_set_lv(sc_lv<8>(slave_arlen.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_read_addr_bits_len");
  tli_set_lv(sc_lv<3>(slave_arsize.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_read_addr_bits_size");
  tli_set_lv(sc_lv<2>(slave_arburst.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_read_addr_bits_burst");
  tli_set_logic(sc_logic(slave_arlock),
             "top.core_mini_axi.io_axi_slave_read_addr_bits_lock");
  tli_set_lv(sc_lv<4>(slave_arcache.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_read_addr_bits_cache");
  tli_set_lv(sc_lv<4>(slave_arqos.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_read_addr_bits_qos");
  tli_set_lv(sc_lv<4>(slave_arregion.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_read_addr_bits_region");

  // S - AW
  if (slave_awready_4.read().is_01()) {
    slave_awready = slave_awready_4.read().to_bool();
  }
  tli_set_logic(sc_logic(slave_awvalid),
                "top.core_mini_axi.io_axi_slave_write_addr_valid");
  tli_set_lv(sc_lv<32>(slave_awaddr.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_write_addr_bits_addr");
  tli_set_lv(sc_lv<3>(slave_awprot.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_write_addr_bits_prot");
  tli_set_lv(sc_lv<6>(slave_awid.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_write_addr_bits_id");
  tli_set_lv(sc_lv<8>(slave_awlen.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_write_addr_bits_len");
  tli_set_lv(sc_lv<3>(slave_awsize.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_write_addr_bits_size");
  tli_set_lv(sc_lv<2>(slave_awburst.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_write_addr_bits_burst");
  tli_set_logic(sc_logic(slave_awlock),
             "top.core_mini_axi.io_axi_slave_write_addr_bits_lock");
  tli_set_lv(sc_lv<4>(slave_awcache.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_write_addr_bits_cache");
  tli_set_lv(sc_lv<4>(slave_awqos.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_write_addr_bits_qos");
  tli_set_lv(sc_lv<4>(slave_awregion.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_write_addr_bits_region");

  // S - B
  tli_set_logic(sc_logic(slave_bready),
                "top.core_mini_axi.io_axi_slave_write_resp_ready");
  if (slave_bvalid_4.read().is_01()) {
    slave_bvalid = slave_bvalid_4.read().to_bool();
  }
  if (slave_bid_4.read().is_01()) {
    slave_bid = slave_bid_4.read();
  }
  if (slave_bresp_4.read().is_01()) {
    slave_bresp = slave_bresp_4.read();
  }

  // S - W
  if (slave_wready_4.read().is_01()) {
    slave_wready = slave_wready_4.read().to_bool();
  }
  tli_set_logic(sc_logic(slave_wvalid),
                "top.core_mini_axi.io_axi_slave_write_data_valid");
  tli_set_lv(sc_lv<128>(slave_wdata.read()),
             "top.core_mini_axi.io_axi_slave_write_data_bits_data");
  tli_set_lv(sc_lv<16>(slave_wstrb.read().get_word(0)),
             "top.core_mini_axi.io_axi_slave_write_data_bits_strb");
  tli_set_logic(sc_logic(slave_wlast),
                "top.core_mini_axi.io_axi_slave_write_data_bits_last");

  // M - B
  tli_set_logic(sc_logic(master_bvalid),
                "top.core_mini_axi.io_axi_master_write_resp_valid");
  tli_set_lv(sc_lv<6>(master_bid.read()),
             "top.core_mini_axi.io_axi_master_write_resp_bits_id");
  tli_set_lv(sc_lv<2>(master_bresp.read()),
             "top.core_mini_axi.io_axi_master_write_resp_bits_resp");
  if (master_bready_4.read().is_01()) {
    master_bready = master_bready_4.read().to_bool();
  }

  // M - W
  tli_set_logic(sc_logic(master_wready),
                "top.core_mini_axi.io_axi_master_write_data_ready");
  if (master_wvalid_4.read().is_01()) {
    master_wvalid = master_wvalid_4.read().to_bool();
  }
  if (master_wdata_4.read().is_01()) {
    master_wdata = master_wdata_4.read();
  }
  if (master_wstrb_4.read().is_01()) {
    master_wstrb = master_wstrb_4.read();
  }
  if (master_wlast_4.read().is_01()) {
    master_wlast = master_wlast_4.read().to_bool();
  }

  // M - AW
  if (master_awvalid_4.read().is_01()) {
    master_awvalid = master_awvalid_4.read().to_bool();
  }
  tli_set_logic(sc_logic(master_awready),
                "top.core_mini_axi.io_axi_master_write_addr_ready");
  if (master_awaddr_4.read().is_01()) {
    master_awaddr = master_awaddr_4.read();
  }
  if (master_awprot_4.read().is_01()) {
    master_awprot = master_awprot_4.read();
  }
  if (master_awid_4.read().is_01()) {
    master_awid = master_awid_4.read();
  }
  if (master_awlen_4.read().is_01()) {
    master_awlen = master_awlen_4.read();
  }
  if (master_awsize_4.read().is_01()) {
    master_awsize = master_awsize_4.read();
  }
  if (master_awburst_4.read().is_01()) {
    master_awburst = master_awburst_4.read();
  }
  if (master_awlock_4.read().is_01()) {
    master_awlock = master_awlock_4.read().to_bool();
  }
  if (master_awcache_4.read().is_01()) {
    master_awcache = master_awcache_4.read();
  }
  if (master_awqos_4.read().is_01()) {
    master_awqos = master_awqos_4.read();
  }
  if (master_awregion_4.read().is_01()) {
    master_awregion = master_awregion_4.read();
  }

  // M - AR
  if (master_arvalid_4.read().is_01()) {
    master_arvalid = master_arvalid_4.read().to_bool();
  }
  tli_set_logic(sc_logic(master_arready),
                "top.core_mini_axi.io_axi_master_read_addr_ready");
  if (master_araddr_4.read().is_01()) {
    master_araddr = master_araddr_4.read();
  }
  if (master_arprot_4.read().is_01()) {
    master_arprot = master_arprot_4.read();
  }
  if (master_arid_4.read().is_01()) {
    master_arid = master_arid_4.read();
  }
  if (master_arlen_4.read().is_01()) {
    master_arlen = master_arlen_4.read();
  }
  if (master_arsize_4.read().is_01()) {
    master_arsize = master_arsize_4.read();
  }
  if (master_arburst_4.read().is_01()) {
    master_arburst = master_arburst_4.read();
  }
  if (master_arlock_4.read().is_01()) {
    master_arlock = master_arlock_4.read().to_bool();
  }
  if (master_arcache_4.read().is_01()) {
    master_arcache = master_arcache_4.read();
  }
  if (master_arqos_4.read().is_01()) {
    master_arqos = master_arqos_4.read();
  }
  if (master_arregion_4.read().is_01()) {
    master_arregion = master_arregion_4.read();
  }

  // M - R
  tli_set_logic(sc_logic(master_rvalid),
                "top.core_mini_axi.io_axi_master_read_data_valid");
  if (master_rready_4.read().is_01()) {
    master_rready = master_rready_4.read().to_bool();
  }
  tli_set_lv(sc_lv<128>(master_rdata.read()),
             "top.core_mini_axi.io_axi_master_read_data_bits_data");
  tli_set_lv(sc_lv<6>(master_rid.read().get_word(0)),
             "top.core_mini_axi.io_axi_master_read_data_bits_id");
  tli_set_lv(sc_lv<2>(master_rresp.read().get_word(0)),
             "top.core_mini_axi.io_axi_master_read_data_bits_resp");
  tli_set_logic(sc_logic(master_rlast.read()),
                "top.core_mini_axi.io_axi_master_read_data_bits_last");

  // Generate an IRQ when we see that the core is in WFI.
  static bool wfi_seen = false;
  if (wfi.read().is_01() && wfi.read().to_bool() && !wfi_seen) {
    irq = sc_dt::Log_1;
    wfi_seen = true;
  } else if (wfi.read().is_01() && !wfi.read().to_bool() && wfi_seen) {
    irq = sc_dt::Log_0;
    wfi_seen = false;
  } else {
    irq = sc_dt::Log_0;
  }

  edge_count++;
}

void sc_top::TraceInstructions() {
  std::vector<bool> instFires = {
    debug.dispatch_0_instFire.read().is_01() && debug.dispatch_0_instFire.read().to_bool(),
    debug.dispatch_1_instFire.read().is_01() && debug.dispatch_1_instFire.read().to_bool(),
    debug.dispatch_2_instFire.read().is_01() && debug.dispatch_2_instFire.read().to_bool(),
    debug.dispatch_3_instFire.read().is_01() && debug.dispatch_3_instFire.read().to_bool()
  };
  std::vector<uint32_t> instAddrs = {
    debug.dispatch_0_instAddr.read().is_01() ? debug.dispatch_0_instAddr.read().get_word(0) : 0,
    debug.dispatch_1_instAddr.read().is_01() ? debug.dispatch_1_instAddr.read().get_word(0) : 0,
    debug.dispatch_2_instAddr.read().is_01() ? debug.dispatch_2_instAddr.read().get_word(0) : 0,
    debug.dispatch_3_instAddr.read().is_01() ? debug.dispatch_3_instAddr.read().get_word(0) : 0,
  };
  std::vector<uint32_t> instInsts = {
    debug.dispatch_0_instInst.read().is_01() ? debug.dispatch_0_instInst.read().get_word(0) : 0,
    debug.dispatch_1_instInst.read().is_01() ? debug.dispatch_1_instInst.read().get_word(0) : 0,
    debug.dispatch_2_instInst.read().is_01() ? debug.dispatch_2_instInst.read().get_word(0) : 0,
    debug.dispatch_3_instInst.read().is_01() ? debug.dispatch_3_instInst.read().get_word(0) : 0
  };

  std::vector<bool> scalarWriteAddrValids = {
    debug.regfile_writeAddr_0_valid.read().is_01() && debug.regfile_writeAddr_0_valid.read().to_bool(),
    debug.regfile_writeAddr_1_valid.read().is_01() && debug.regfile_writeAddr_1_valid.read().to_bool(),
    debug.regfile_writeAddr_2_valid.read().is_01() && debug.regfile_writeAddr_2_valid.read().to_bool(),
    debug.regfile_writeAddr_3_valid.read().is_01() && debug.regfile_writeAddr_3_valid.read().to_bool()
  };
  std::vector<uint32_t> scalarWriteAddrAddrs = {
    debug.regfile_writeAddr_0_bits.read().is_01() ? debug.regfile_writeAddr_0_bits.read().get_word(0) : 0,
    debug.regfile_writeAddr_1_bits.read().is_01() ? debug.regfile_writeAddr_1_bits.read().get_word(0) : 0,
    debug.regfile_writeAddr_2_bits.read().is_01() ? debug.regfile_writeAddr_2_bits.read().get_word(0) : 0,
    debug.regfile_writeAddr_3_bits.read().is_01() ? debug.regfile_writeAddr_3_bits.read().get_word(0) : 0
  };
  std::vector<bool> floatWriteAddrValids = {
    debug.float_writeAddr_valid.read().is_01() && debug.float_writeAddr_valid.read().to_bool()
  };
  std::vector<uint32_t> floatWriteAddrAddrs = {
    debug.float_writeAddr_bits.read().is_01() ? debug.float_writeAddr_bits.read().get_word(0) : 0
  };

  std::vector<bool> writeDataValids = {
    debug.regfile_writeData_0_valid.read().is_01() && debug.regfile_writeData_0_valid.read().to_bool(),
    debug.regfile_writeData_1_valid.read().is_01() && debug.regfile_writeData_1_valid.read().to_bool(),
    debug.regfile_writeData_2_valid.read().is_01() && debug.regfile_writeData_2_valid.read().to_bool(),
    debug.regfile_writeData_3_valid.read().is_01() && debug.regfile_writeData_3_valid.read().to_bool(),
    debug.regfile_writeData_4_valid.read().is_01() && debug.regfile_writeData_4_valid.read().to_bool(),
    debug.regfile_writeData_5_valid.read().is_01() && debug.regfile_writeData_5_valid.read().to_bool(),
    debug.float_writeData_0_valid.read().is_01() && debug.float_writeData_0_valid.read().to_bool(),
    debug.float_writeData_1_valid.read().is_01() && debug.float_writeData_1_valid.read().to_bool(),
  };

  std::vector<uint32_t> writeDataAddrs = {
    debug.regfile_writeData_0_bits_addr.read().is_01() ? debug.regfile_writeData_0_bits_addr.read().get_word(0) : 0,
    debug.regfile_writeData_1_bits_addr.read().is_01() ? debug.regfile_writeData_1_bits_addr.read().get_word(0) : 0,
    debug.regfile_writeData_2_bits_addr.read().is_01() ? debug.regfile_writeData_2_bits_addr.read().get_word(0) : 0,
    debug.regfile_writeData_3_bits_addr.read().is_01() ? debug.regfile_writeData_3_bits_addr.read().get_word(0) : 0,
    debug.regfile_writeData_4_bits_addr.read().is_01() ? debug.regfile_writeData_4_bits_addr.read().get_word(0) : 0,
    debug.regfile_writeData_5_bits_addr.read().is_01() ? debug.regfile_writeData_5_bits_addr.read().get_word(0) : 0,
    debug.float_writeData_0_bits_addr.read().is_01() ? debug.float_writeData_0_bits_addr.read().get_word(0) : 0,
    debug.float_writeData_1_bits_addr.read().is_01() ? debug.float_writeData_1_bits_addr.read().get_word(0) : 0
  };

  std::vector<uint32_t> writeDataDatas = {
    debug.regfile_writeData_0_bits_data.read().is_01() ? debug.regfile_writeData_0_bits_data.read().get_word(0) : 0,
    debug.regfile_writeData_1_bits_data.read().is_01() ? debug.regfile_writeData_1_bits_data.read().get_word(0) : 0,
    debug.regfile_writeData_2_bits_data.read().is_01() ? debug.regfile_writeData_2_bits_data.read().get_word(0) : 0,
    debug.regfile_writeData_3_bits_data.read().is_01() ? debug.regfile_writeData_3_bits_data.read().get_word(0) : 0,
    debug.regfile_writeData_4_bits_data.read().is_01() ? debug.regfile_writeData_4_bits_data.read().get_word(0) : 0,
    debug.regfile_writeData_5_bits_data.read().is_01() ? debug.regfile_writeData_5_bits_data.read().get_word(0) : 0,
    debug.float_writeData_0_bits_data.read().is_01() ? debug.float_writeData_0_bits_data.read().get_word(0) : 0,
    debug.float_writeData_1_bits_data.read().is_01() ? debug.float_writeData_1_bits_data.read().get_word(0) : 0
  };

  std::vector<int> executeRegBases = {
    InstructionTrace::kScalarBaseReg,
    InstructionTrace::kScalarBaseReg,
    InstructionTrace::kScalarBaseReg,
    InstructionTrace::kScalarBaseReg,
    InstructionTrace::kScalarBaseReg,
    InstructionTrace::kScalarBaseReg,
    InstructionTrace::kFloatBaseReg,
    InstructionTrace::kFloatBaseReg
  };

  tracer_.TraceInstruction(
    instFires,
    instAddrs,
    instInsts,
    scalarWriteAddrValids,
    scalarWriteAddrAddrs,
    floatWriteAddrValids,
    floatWriteAddrAddrs,
    writeDataValids,
    writeDataAddrs,
    writeDataDatas,
    executeRegBases
  );
}
