# RISC-V Performance Monitoring: Cycle and Instruction Counters

This document explains the use of the Machine Cycle Counter CSRs (mcycle/mcycleh)
and Machine Instruction Retirement Counter (minstret/minstreth) in Coralnpu for
performance monitoring and measurement.

## Overview

Cycle counter CSRs (mcycle/mcycleh): Tracks the number of clock cycles the
processor has executed since reset.

Instruction Retirement Counter (minstret/minstreth): Tracks the total number of
instructions retired (successfully completed) by the processor.

Cycles and instructions are read from registers via assembly interface for example
```
read cycles and store.

asm volatile(
      "1:"
      "  csrr %0, mcycleh;"  // Read `mcycleh`.
      "  csrr %1, mcycle;"   // Read `mcycle`.
      "  csrr %2, mcycleh;"  // Read `mcycleh` again.
      "  bne  %0, %2, 1b;"
      : "=r"(cycle_high), "=r"(cycle_low), "=r"(cycle_high_2)
      :);

```c

Refer to sw/utils/utils.h cycle read and reset definition. Pseudo code to read
cycles and instructions below.

```
cycle_counter_reset();
cycle_start = mcycle_read();
// define compute workload to be measured
cycle_end = mcycle_read();
uint64_t cycle_count = cycle_end - cycle_start;
// store cycle_count to a buffer.
// A similar steps above can used to read number of instructions using
// instrut_counter_reset() minstret_read()
```c

## Run the example

```
$ bazel run -c opt tests/cocotb/tutorial/counters:cocotb_counter_test
```c