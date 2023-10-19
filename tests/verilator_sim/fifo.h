// Copyright 2023 Google LLC
#ifndef TESTS_VERILATOR_SIM_FIFO_H_
#define TESTS_VERILATOR_SIM_FIFO_H_

#include <vector>

// A SystemC CRT transaction queue.

template <typename T>
class fifo_t {
 public:
  bool empty() { return entries_.empty(); }

  void write(T v) { entries_.emplace_back(v); }

  bool read(T& v) {
    if (entries_.empty()) return false;
    v = entries_.at(0);
    entries_.erase(entries_.begin());
    return true;
  }

  bool next(T& v, int index = 0) {
    if (index >= count()) return false;
    v = entries_.at(index);
    return true;
  }

  bool rand(T& v) {
    if (entries_.empty()) return false;
    int index = ::rand() % count();
    v = entries_.at(index);
    return true;
  }

  void clear() { entries_.clear(); }

  bool remove(int index = 0) {
    if (index >= count()) return false;
    entries_.erase(entries_.begin() + index);
    return true;
  }

  void shuffle() {
    const int count = entries_.size();
    if (count < 2) return;
    for (int i = 0; i < count; ++i) {
      const int index = ::rand() % count;
      T v = entries_.at(index);
      entries_.erase(entries_.begin() + index);
      entries_.emplace_back(v);
    }
  }

  int count() { return entries_.size(); }

 private:
  std::vector<T> entries_;
};

#endif  // TESTS_VERILATOR_SIM_FIFO_H_
