/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// A starting functions for simple coralnpu programs.

.extern coralnpu_exception_handler

/**
 * Entry point.
 */
        .section ._init
        .balign 4
        .global _start
        .type _start, @function
_start:
        ###############################################
        # Put all scalar registers into a known state #
        ###############################################
.option norelax
        la   sp, __stack_end__
        la   gp, _global_pointer
.option relax
        mv   tp, zero
        mv   t1, zero
        mv   t2, zero
        mv   s0, zero
        mv   s1, zero
        mv   a1, zero
        mv   a2, zero
        mv   a3, zero
        mv   a4, zero
        mv   a5, zero
        mv   a6, zero
        mv   a7, zero
        mv   s2, zero
        mv   s3, zero
        mv   s4, zero
        mv   s5, zero
        mv   s6, zero
        mv   s7, zero
        mv   s8, zero
        mv   s9, zero
        mv   s10, zero
        mv   s11, zero
        mv   t3, zero
        mv   t4, zero
        mv   t5, zero
        mv   t6, zero

        # Zero out the bss section
        la   a0, __bss_start__
        la   a1, __bss_end__
        call crt_section_clear

        # Initialize arrays
        la   s0, __init_array_start__
        la   s1, __init_array_end__
        bgeu s0, s1, init_array_loop_end
init_array_loop:
        lw   t0, 0(s0)
        jalr t0
        addi s0, s0, 0x4
        bltu s0, s1, init_array_loop
init_array_loop_end:

        # Set up a default trap vector, which will
        # simply call ebreak.
        # Users who require real trap handling should
        # install their own trap vector.
        la t0, coralnpu_exception_handler
        csrw mtvec, t0

        # Set up sentinel value in _ret
        # If we see this after an ebreak,
        # the break source is unlikely to
        # be a clean return from main.
        la   t0, _ret
        li   a0, 0x0badd00d
        sw   a0, 0(t0)

        #############
        # Call main #
        #############
        li   a0, 0  # argv
        li   a1, 0  # argc
        la   ra, main
        jalr ra, ra
        # Store the application's return value at _ret
        la   t0, _ret
        sw   a0, 0(t0)
        beqz a0, success
failure:
        ebreak
        j    loop
success:
        .word 0x08000073 # mpause
loop:
        j    loop
