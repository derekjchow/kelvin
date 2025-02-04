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

#ifndef TESTS_SYSTEMC_XBAR_H_
#define TESTS_SYSTEMC_XBAR_H_

#include <cstdint>
#include <cstdio>

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>

// "Crossbar" containing a memory and a UART.
class Xbar : sc_core::sc_module {
 public:
  Xbar(sc_core::sc_module_name name) : sc_core::sc_module(std::move(name)) {
    memset(memory_, 0xa5, kMemorySizeBytes);
    socket_.register_b_transport(this, &Xbar::b_transport);
  }

  tlm_utils::simple_target_socket<Xbar>& socket() { return socket_; }

  void b_transport(tlm::tlm_generic_payload& trans, sc_core::sc_time& delay) {
    sc_dt::uint64 addr = trans.get_address();
    unsigned int len = trans.get_data_length();

    if (((addr & kMemoryAddr) == kMemoryAddr) &&
        (addr + len < kMemoryAddr + kMemorySizeBytes)) {
      memory_b_transport_(trans, delay);
    } else if (addr == kUartAddr) {
      uart_b_transport_(trans, delay);
    } else {
      trans.set_response_status(tlm::TLM_ADDRESS_ERROR_RESPONSE);
      return;
    }
  }

 private:
  void memory_b_transport_(tlm::tlm_generic_payload& trans, sc_core::sc_time& delay) {
    sc_dt::uint64 addr = trans.get_address() & ~kMemoryAddr;
    unsigned char* ptr = trans.get_data_ptr();
    unsigned int len = trans.get_data_length();
    unsigned int streaming_width = trans.get_streaming_width();
    unsigned char* be = trans.get_byte_enable_ptr();
    unsigned int be_len = trans.get_byte_enable_length();
    if (streaming_width == 0) {
      streaming_width = len;
    }
    if (be_len || streaming_width != len) {
      for (unsigned int pos = 0; pos < len; ++pos) {
        bool do_access = true;
        if (be_len) {
          do_access = be[pos % be_len] == TLM_BYTE_ENABLED;
        }
        if (do_access) {
          if ((addr + (pos % streaming_width)) >= sc_dt::uint64(kMemorySizeBytes)) {
            trans.set_response_status(tlm::TLM_ADDRESS_ERROR_RESPONSE);
            SC_REPORT_FATAL("Memory", "Bad address\n");
            return;
          }

          if (trans.is_read()) {
            ptr[pos] = memory_[addr + pos];
          } else {
            memory_[addr + pos] = ptr[pos];
          }
        }
      }
    } else {
      if ((addr + len) > sc_dt::uint64(kMemorySizeBytes)) {
        trans.set_response_status(tlm::TLM_ADDRESS_ERROR_RESPONSE);
        SC_REPORT_FATAL("Memory", "Bad address\n");
        return;
      }

      if (trans.is_read()) {
        memcpy(ptr, memory_ + addr, len);
      } else if (trans.is_write()) {
        memcpy(memory_ + addr, ptr, len);
      } else {
        trans.set_response_status(tlm::TLM_GENERIC_ERROR_RESPONSE);
        SC_REPORT_FATAL("Memory", "Bad command\n");
        return;
      }
    }
    trans.set_response_status(tlm::TLM_OK_RESPONSE);
  }

  void uart_b_transport_(tlm::tlm_generic_payload& trans, sc_core::sc_time& delay) {
    sc_dt::uint64 addr = trans.get_address() & ~kUartAddr;
    unsigned char* ptr = trans.get_data_ptr();
    unsigned int len = trans.get_data_length();
    unsigned int streaming_width = trans.get_streaming_width();
    unsigned char* be = trans.get_byte_enable_ptr();
    unsigned int be_len = trans.get_byte_enable_length();
    if (streaming_width == 0) {
      streaming_width = len;
    }

    if (!be_len && streaming_width == len) {
      for (unsigned int pos = 0; pos < len; ++pos) {
        if (ptr[pos] == '\n') {
          uart_buffer_.push_back('\0');
          printf("%s\n", uart_buffer_.data());
          uart_buffer_.clear();
        } else {
          uart_buffer_.push_back(ptr[pos]);
        }
      }
    } else {
      for (unsigned int pos = 0; pos < len / 8; ++pos) {
        if (be_len && be[pos % (be_len / 8)] != TLM_BYTE_ENABLED) {
          continue;
        }

        if (addr != 0 || trans.is_read()) {
          trans.set_response_status(tlm::TLM_ADDRESS_ERROR_RESPONSE);
          SC_REPORT_FATAL("Uart", "Unsupported access\n");
          return;
        }

        if (ptr[pos] == '\n') {
          uart_buffer_.push_back('\0');
          printf("%s\n", uart_buffer_.data());
          uart_buffer_.clear();
        } else {
          uart_buffer_.push_back(ptr[pos]);
        }
      }
    }
    trans.set_response_status(tlm::TLM_OK_RESPONSE);
  }

  static constexpr uint32_t kMemoryAddr = 0x20000000;
  static constexpr size_t kMemorySizeBytes = 0x400000;
  static constexpr uint32_t kUartAddr = 0x54000000;
  uint8_t memory_[kMemorySizeBytes];
  std::vector<char> uart_buffer_;
  tlm_utils::simple_target_socket<Xbar> socket_;
};

#endif  // TESTS_SYSTEMC_XBAR_H_