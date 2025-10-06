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

#ifndef TESTS_VERILATOR_SIM_CORALNPU_DEBUG_IF_H_
#define TESTS_VERILATOR_SIM_CORALNPU_DEBUG_IF_H_

#include <stdint.h>
#include <stdio.h>
#include <sys/time.h>

#include "tests/verilator_sim/sysc_module.h"
#include "tests/verilator_sim/coralnpu/memory_if.h"

// A core debug model.
struct Debug_if : Sysc_module {
  sc_in<bool>       io_slog_valid;
  sc_in<sc_bv<5> >  io_slog_addr;
  sc_in<sc_bv<32> > io_slog_data;

  Debug_if(sc_module_name n, Memory_if* mm) : Sysc_module(n), mm_(mm) {
    gettimeofday(&start_, NULL);
  }

  ~Debug_if() {
    gettimeofday(&stop_, NULL);
    const float time_s =
        static_cast<float>(stop_.tv_sec - start_.tv_sec) +
        static_cast<float>(stop_.tv_usec - start_.tv_usec) / 1000000.0f;

    // Integer with commas.
    auto s = std::to_string(cycle_);
    int n = s.length() - 3;
    while (n > 0) {
      s.insert(n, ",");
      n -= 3;
    }

    printf("Info: %s cycles  @%.2fK/s\n", s.c_str(), cycle_ / time_s / 1000.0f);
  }

  void eval() {
    if (reset) {
      cycle_ = 0;
    } else if (clock->posedge()) {
      cycle_++;
      if (io_slog_valid) {
        Slog(io_slog_addr.read().get_word(0), io_slog_data.read().get_word(0));
      }
    }
  }

 private:
#ifndef TIME_DISABLE
  const char* KNRM = "\x1B[0m";
  const char* KRED = "\x1B[31m";
  const char* KGRN = "\x1B[32m";
  const char* KYEL = "\x1B[33m";
  const char* KBLU = "\x1B[34m";
  const char* KMAG = "\x1B[35m";
  const char* KCYN = "\x1B[36m";
  const char* KWHT = "\x1B[37m";
  const char* KRST = "\033[0m";
#endif  // TIME_DISABLE

  static const int ARGMAX = 16;
  static const int BUFFERLIMIT = 100;
  int argpos_;
  uint64_t arg_[ARGMAX];
  uint8_t str_[ARGMAX][BUFFERLIMIT];
  uint8_t pos_[ARGMAX] = {0};

  struct timeval stop_, start_;

  Memory_if* mm_;

  bool newline_ = false;
  int cycle_ = 0;

  void Slog(const uint8_t cmd, const uint32_t data) {
    constexpr int FLOG = 0;
    constexpr int SLOG = 1;
    constexpr int CLOG = 2;
    constexpr int KLOG = 3;

    if (cmd == FLOG) {
      char buf[BUFFERLIMIT];
      char sbuf[ARGMAX * BUFFERLIMIT];

      mm_->Read(data, BUFFERLIMIT, reinterpret_cast<uint8_t*>(buf));
      buf[sizeof(buf) - 1] = '\0';

      snprintf(sbuf, sizeof(sbuf), buf, arg_[0], arg_[1], arg_[2], arg_[3],
               arg_[4], arg_[5], arg_[6], arg_[7], arg_[8], arg_[9], arg_[10],
               arg_[11], arg_[12], arg_[13], arg_[14], arg_[15]);  // ARGMAX

      int len = strlen(sbuf);
#ifndef TIME_DISABLE
      printf("%s", KGRN);
#endif  // TIME_DISABLE
      for (int i = 0; i < len; ++i) {
        if (!newline_) {
          newline_ = true;
#ifndef TIME_DISABLE
          printf("%s[%7d] %s", KCYN, cycle_, KGRN);
#endif  // TIME_DISABLE
        }
        const char ch = sbuf[i];
        putc(ch, stdout);
        if (ch == '\n') {
          newline_ = false;
          fflush(stdout);
        }
      }
#ifndef TIME_DISABLE
      printf("%s", KRST);
#endif  // TIME_DISABLE

      memset(pos_, 0, sizeof(pos_));
      argpos_ = 0;
      return;
    }

    assert(argpos_ < ARGMAX);

    if (cmd == SLOG) {
      arg_[argpos_] = data;
      argpos_++;
    } else if (cmd == CLOG) {
      arg_[argpos_] = (uint64_t) str_[argpos_];
      const uint8_t *ptr = (const uint8_t*) &data;
      uint8_t *buf = str_[argpos_];
      for (int i = 0; i < 4; ++i) {
        const int p = pos_[argpos_]++;
        const char c = ptr[i];
        assert(p + 1 < BUFFERLIMIT);
        buf[p] = c;
        buf[p + 1] = '\0';
        if (!c) {
          argpos_++;
          break;
        }
      }
    } else if (cmd == KLOG) {
      arg_[argpos_] = (uint64_t) str_[argpos_];
      uint8_t* buf = str_[argpos_];
      mm_->Read(data, BUFFERLIMIT, buf);
      argpos_++;
    } else {
      printf("\n**error: RV32L SLOG unknown cmd=%d\n", cmd);
      exit(-1);
    }
  }
};

#endif  // TESTS_VERILATOR_SIM_CORALNPU_DEBUG_IF_H_
