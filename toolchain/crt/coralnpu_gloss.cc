// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Syscall stubs for newlib on CoralNPU
#include <sys/stat.h>
#include <unistd.h>

#include <cerrno>
#include <cstdint>
#include <cstdio>
#include <malloc.h>

// TODO(atv): CoralNPU V2 toolchain doesn't support the log family.
// #define flog(s) asm volatile("flog %0" : : "r"(s))

void* __dso_handle = reinterpret_cast<void*>(&__dso_handle);

extern "C" int _close(int file) { return -1; }

extern "C" int _fstat(int file, struct stat* st) {
  if (file != STDOUT_FILENO && file != STDERR_FILENO) {
    errno = EBADF;
    return -1;
  }

  if (st == NULL) {
    errno = EFAULT;
    return -1;
  }

  st->st_mode = S_IFCHR;
  return 0;
}

extern "C" int _isatty(int file) {
  errno = ENOTTY;
  return 1;
}

extern "C" int _lseek(int file, int ptr, int dir) {
  if (file != STDOUT_FILENO && file != STDERR_FILENO) {
    errno = EBADF;
    return -1;
  }

  return 0;
}

extern "C" int _read(int file, char* ptr, int len) {
  errno = EBADF;
  return -1;
}

#ifndef LOG_MAX_SZ
#define LOG_MAX_SZ 256
#endif
// TODO(lundong): Handle stdout and stderr separately
extern "C" int _write(int file, char* buf, int nbytes) {
  static int _write_line_buffer_len = 0;
  static char _write_line_buffer[LOG_MAX_SZ];

  if (file != STDOUT_FILENO && file != STDERR_FILENO) {
    errno = EBADF;
    return -1;
  }

  if (nbytes <= 0) {
    return 0;
  }

  if (buf == NULL) {
    errno = EFAULT;
    return -1;
  }

  int bytes_read = 0;
  char c;
  do {
    int len = _write_line_buffer_len;
    c = *(buf++);
    bytes_read++;

    _write_line_buffer[len++] = c;
    if (len == LOG_MAX_SZ - 1 || c == '\n') {
      _write_line_buffer[len] = '\0';
    }
    if ((_write_line_buffer[len] == '\0')) {
      // flog(_write_line_buffer);
      len = 0;
    }
    _write_line_buffer_len = len;
  } while (bytes_read < nbytes);

  return bytes_read;
}

extern "C" int _open(const char* path, int flags, ...) { return -1; }

extern "C" void _exit(int status) {
  asm volatile("ebreak");
  while (1) {
  }
}

extern "C" int _kill(int pid, int sig) {
  asm volatile("ebreak");
  return -1;
}

extern "C" int _getpid(void) {
  asm volatile("ebreak");
  return -1;
}

extern "C" void* _sbrk(int bytes) {
  extern char __heap_start__, __heap_end__;
  static char* _heap_ptr = &__heap_start__;
  char* prev_heap_end;
  if ((bytes < 0) || (_heap_ptr + bytes > &__heap_end__)) {
    errno = ENOMEM;
    return reinterpret_cast<void*>(-1);
  }

  prev_heap_end = _heap_ptr;
  _heap_ptr += bytes;

  return reinterpret_cast<void*>(prev_heap_end);
}

void* operator new(size_t n) { return malloc(n); }
void* operator new[](size_t n) { return malloc(n); }

void operator delete(void* p) noexcept { free(p); }
void operator delete(void* p, size_t c) noexcept { operator delete(p); }
void operator delete[](void* p) noexcept { free(p); }
