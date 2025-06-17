#include <elf.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <systemc.h>
#include <unistd.h>

#include <functional>
#include <memory>
#include <optional>
#include <string>

#include "tests/systemc/Xbar.h"
#include "tests/verilator_sim/elf.h"
#include "top.h"

/* clang-format off */

#include <tlm>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

#include "checkers/pc-axi.h"
#include "tlm-bridges/tlm2axi-bridge.h"
#include "tlm-bridges/axi2tlm-bridge.h"
#include "traffic-generators/tg-tlm.h"
#include "traffic-generators/traffic-desc.h"

#include "tests/test-modules/signals-axi.h"
#include "tests/test-modules/utils.h"
/* clang-format on */

std::unique_ptr<TrafficDesc> bin_transfer;
std::unique_ptr<TrafficDesc> disable_cg_transfer;
std::unique_ptr<TrafficDesc> release_reset_transfer;
std::unique_ptr<TrafficDesc> status_read_transfer;

static void disable_cg_transfer_done_cb(TLMTrafficGenerator* gen,
                                        int threadId) {
  gen->addTransfers(release_reset_transfer.get(), 0);
}

static void bin_transfer_done_cb(TLMTrafficGenerator* gen, int threadId) {
  gen->addTransfers(disable_cg_transfer.get(), 0, disable_cg_transfer_done_cb);
}

int sc_main(int argc, char** argv) {
  sc_top top("top");
  sc_clock clock("clock", 100, SC_NS);

  Xbar xbar("xbar");
  tlm2axi_bridge<KP_axi2AddrBits, KP_lsuDataBits, KP_axi2IdBits, 8, 1, 0, 0, 0,
                 0, 0>
      tlm2axi_bridge("tlm2axi_bridge");
  axi2tlm_bridge<KP_axi2AddrBits, KP_lsuDataBits, KP_axi2IdBits, 8, 1, 0, 0, 0,
                 0, 0>
      axi2tlm_bridge("axi2tlm_bridge");

  typedef AXIProtocolChecker<KP_axi2AddrBits, KP_lsuDataBits, KP_axi2IdBits, 8,
                             1, 0, 0, 0, 0, 0>
      CoreMiniAxiProtocolChecker;
  CoreMiniAxiProtocolChecker tlm2axi_checker("tlm2axi_checker");
  CoreMiniAxiProtocolChecker axi2tlm_checker("axi2tlm_checker");
  typedef AXISignals<KP_axi2AddrBits,  // ADDR_WIDTH
                     KP_lsuDataBits,   // DATA_WIDTH
                     KP_axi2IdBits,    // ID_WIDTH
                     8,                // AxLEN_WIDTH
                     1,                // AxLOCK_WIDTH
                     0, 0, 0, 0, 0     // User
                     >
      CoreMiniAxiSignals;

  top.clock(clock);

  tlm2axi_bridge.clk(clock);
  tlm2axi_bridge.resetn(top.resetn);
  tlm2axi_checker.clk(clock);
  tlm2axi_checker.resetn(top.resetn);

  axi2tlm_bridge.clk(clock);
  axi2tlm_bridge.resetn(top.resetn);
  axi2tlm_checker.clk(clock);
  axi2tlm_checker.resetn(top.resetn);

  CoreMiniAxiSignals tlm2axi_signals("tlm2axi_signals");
  tlm2axi_signals.connect(tlm2axi_bridge);
  tlm2axi_signals.connect(tlm2axi_checker);

  top.slave_rready(tlm2axi_signals.rready);
  top.slave_rvalid(tlm2axi_signals.rvalid);
  top.slave_rdata(tlm2axi_signals.rdata);
  top.slave_rid(tlm2axi_signals.rid);
  top.slave_rresp(tlm2axi_signals.rresp);
  top.slave_rlast(tlm2axi_signals.rlast);

  top.slave_arready(tlm2axi_signals.arready);
  top.slave_arvalid(tlm2axi_signals.arvalid);
  top.slave_araddr(tlm2axi_signals.araddr);
  top.slave_arprot(tlm2axi_signals.arprot);
  top.slave_arid(tlm2axi_signals.arid);
  top.slave_arlen(tlm2axi_signals.arlen);
  top.slave_arsize(tlm2axi_signals.arsize);
  top.slave_arburst(tlm2axi_signals.arburst);
  top.slave_arlock(tlm2axi_signals.arlock);
  top.slave_arcache(tlm2axi_signals.arcache);
  top.slave_arqos(tlm2axi_signals.arqos);
  top.slave_arregion(tlm2axi_signals.arregion);

  top.slave_awready(tlm2axi_signals.awready);
  top.slave_awvalid(tlm2axi_signals.awvalid);
  top.slave_awaddr(tlm2axi_signals.awaddr);
  top.slave_awprot(tlm2axi_signals.awprot);
  top.slave_awid(tlm2axi_signals.awid);
  top.slave_awlen(tlm2axi_signals.awlen);
  top.slave_awsize(tlm2axi_signals.awsize);
  top.slave_awburst(tlm2axi_signals.awburst);
  top.slave_awlock(tlm2axi_signals.awlock);
  top.slave_awcache(tlm2axi_signals.awcache);
  top.slave_awqos(tlm2axi_signals.awqos);
  top.slave_awregion(tlm2axi_signals.awregion);

  top.slave_wready(tlm2axi_signals.wready);
  top.slave_wvalid(tlm2axi_signals.wvalid);
  top.slave_wdata(tlm2axi_signals.wdata);
  top.slave_wlast(tlm2axi_signals.wlast);
  top.slave_wstrb(tlm2axi_signals.wstrb);

  top.slave_bready(tlm2axi_signals.bready);
  top.slave_bvalid(tlm2axi_signals.bvalid);
  top.slave_bid(tlm2axi_signals.bid);
  top.slave_bresp(tlm2axi_signals.bresp);

  CoreMiniAxiSignals axi2tlm_signals("axi2tlm_signals");
  axi2tlm_signals.connect(axi2tlm_bridge);
  axi2tlm_signals.connect(axi2tlm_checker);

  top.master_rready(axi2tlm_signals.rready);
  top.master_rvalid(axi2tlm_signals.rvalid);
  top.master_rdata(axi2tlm_signals.rdata);
  top.master_rid(axi2tlm_signals.rid);
  top.master_rresp(axi2tlm_signals.rresp);
  top.master_rlast(axi2tlm_signals.rlast);

  top.master_arready(axi2tlm_signals.arready);
  top.master_arvalid(axi2tlm_signals.arvalid);
  top.master_araddr(axi2tlm_signals.araddr);
  top.master_arprot(axi2tlm_signals.arprot);
  top.master_arid(axi2tlm_signals.arid);
  top.master_arlen(axi2tlm_signals.arlen);
  top.master_arsize(axi2tlm_signals.arsize);
  top.master_arburst(axi2tlm_signals.arburst);
  top.master_arlock(axi2tlm_signals.arlock);
  top.master_arcache(axi2tlm_signals.arcache);
  top.master_arqos(axi2tlm_signals.arqos);
  top.master_arregion(axi2tlm_signals.arregion);

  top.master_awready(axi2tlm_signals.awready);
  top.master_awvalid(axi2tlm_signals.awvalid);
  top.master_awaddr(axi2tlm_signals.awaddr);
  top.master_awprot(axi2tlm_signals.awprot);
  top.master_awid(axi2tlm_signals.awid);
  top.master_awlen(axi2tlm_signals.awlen);
  top.master_awsize(axi2tlm_signals.awsize);
  top.master_awburst(axi2tlm_signals.awburst);
  top.master_awlock(axi2tlm_signals.awlock);
  top.master_awcache(axi2tlm_signals.awcache);
  top.master_awqos(axi2tlm_signals.awqos);
  top.master_awregion(axi2tlm_signals.awregion);

  top.master_wready(axi2tlm_signals.wready);
  top.master_wvalid(axi2tlm_signals.wvalid);
  top.master_wdata(axi2tlm_signals.wdata);
  top.master_wlast(axi2tlm_signals.wlast);
  top.master_wstrb(axi2tlm_signals.wstrb);

  top.master_bready(axi2tlm_signals.bready);
  top.master_bvalid(axi2tlm_signals.bvalid);
  top.master_bid(axi2tlm_signals.bid);
  top.master_bresp(axi2tlm_signals.bresp);

  TLMTrafficGenerator tg("tg");
  tg.socket.bind(tlm2axi_bridge.tgt_socket);
  tg.setStartDelay(sc_time(5, SC_NS));

  axi2tlm_bridge.socket.bind(xbar.socket());

  constexpr int kRetNoFilename = -1;
  constexpr int kRetFileNotExist = -2;
  constexpr int kRetFstatError = -3;
  constexpr int kRetMmapFailed = -4;
  constexpr int kRetSemihostError = -5;

  if (!hdl_elaboration_only()) {
    bool instr_trace = false;
    const char* kKeyInstrTrace = "--instr_trace";
    for (int i = 0; i < argc; ++i) {
      if (strncmp(kKeyInstrTrace, argv[i], strlen(kKeyInstrTrace)) == 0) {
        instr_trace = true;
        break;
      }
    }
    top.instr_trace_ = instr_trace;

    const char* kKeyFilename = "--filename";
    std::optional<std::string> filename;
    for (int i = 0; i < argc; ++i) {
      if (strncmp(kKeyFilename, argv[i], strlen(kKeyFilename)) == 0) {
        if (i + 1 < argc) {
          filename = std::string(argv[i + 1]);
          break;
        }
      }
    }
    if (!filename) {
      printf("Usage: $s --filename <bin|elf>\n", argv[0]);
      return kRetNoFilename;
    }
    int fd = open(filename.value().c_str(), 0);
    if (fd <= 0) {
      return kRetFileNotExist;
    }
    struct stat sb;
    if (fstat(fd, &sb) != 0) {
      return kRetFstatError;
    }
    auto file_size_ = sb.st_size;
    auto file_data_ = mmap(nullptr, file_size_, PROT_READ, MAP_PRIVATE, fd, 0);

    if (file_data_ == MAP_FAILED) {
      return kRetMmapFailed;
    }
    close(fd);

    uint32_t csr_addr_ = 0x30000;
    uint32_t elf_magic = 0x464c457f;
    uint8_t* data8 = reinterpret_cast<uint8_t*>(file_data_);
    if (memcmp(file_data_, &elf_magic, sizeof(elf_magic)) == 0) {
      std::vector<DataTransfer> elf_transfers;
      const Elf32_Ehdr* elf_header = reinterpret_cast<Elf32_Ehdr*>(file_data_);
      auto entry_point = elf_header->e_entry;
      elf_transfers.reserve(3 * elf_header->e_phnum + 1);
      LoadElf(data8,
              [&elf_transfers](void* dest, const void* src, size_t count) {
                elf_transfers.push_back(utils::Write(
                    reinterpret_cast<uint64_t>(dest),
                    reinterpret_cast<uint8_t*>(const_cast<void*>(src)), count));
                elf_transfers.push_back(
                    utils::Read(reinterpret_cast<uint64_t>(dest), count));
                elf_transfers.push_back(utils::Expect(
                    reinterpret_cast<uint8_t*>(const_cast<void*>(src)), count));
                return dest;
              });
      elf_transfers.push_back(utils::Write(
        csr_addr_ + 0x4, reinterpret_cast<uint8_t*>(&entry_point), sizeof(entry_point)
      ));
      bin_transfer = std::make_unique<TrafficDesc>(utils::merge(elf_transfers));
      uint32_t tohost;
      if (::LookupSymbol(data8, "tohost", &tohost)) {
        if ((tohost & 0xFFFFFFF0L) != tohost) {
          return kRetSemihostError;
        }
        top.tohost_addr_ = tohost;
      }
      uint32_t fromhost;
      if (::LookupSymbol(data8, "fromhost", &fromhost)) {
        top.fromhost_addr_ = fromhost;
      }
    } else {
      // Transaction to fill ITCM with the provided binary.
      bin_transfer =
          std::make_unique<TrafficDesc>(utils::merge(std::vector<DataTransfer>(
              {utils::Write(0, data8, file_size_), utils::Read(0, file_size_),
               utils::Expect(data8, file_size_)})));
    }

    disable_cg_transfer =
        std::make_unique<TrafficDesc>(utils::merge(std::vector<DataTransfer>(
            {utils::Write(csr_addr_, DATA(1, 0, 0, 0)),
             utils::Read(csr_addr_, 4), utils::Expect(DATA(1, 0, 0, 0), 4)})));
    release_reset_transfer =
        std::make_unique<TrafficDesc>(utils::merge(std::vector<DataTransfer>(
            {utils::Write(csr_addr_, DATA(0, 0, 0, 0)),
             utils::Read(csr_addr_, 4), utils::Expect(DATA(0, 0, 0, 0), 4)})));
    status_read_transfer = std::make_unique<TrafficDesc>(utils::merge(
        std::vector<DataTransfer>({utils::Read(csr_addr_ + 0x8, 4),
                                   utils::Expect(DATA(1, 0, 0, 0), 4)})));

    tg.addTransfers(bin_transfer.get(), 0, bin_transfer_done_cb);
  }

  sc_start();
  return 0;
}
