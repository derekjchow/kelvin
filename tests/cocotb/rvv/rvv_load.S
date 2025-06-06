/*
 * Copyright 2025 Google LLC
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

.section .data
.align 16

.global input_nothing
input_nothing:
    .space 16

.global input_1
input_1:
    .space 16

.global output_1
output_1:
    .space 16

.section .text
.global main
.option norelax

main:

    la t2, input_1
    la t3, output_1

    vsetivli x0, 16, e8, m1, ta, ma

    # loop variables
    li t0, 1
    li t1, 0
    loop8 :  bge t1, t0, loop8_exit // bge t1 <= t0 loop_exit
            vle8.v v1, (t2)
            addi t2, t2, 16 # updating input address
            addi t1, t1, 1
            j loop8
    loop8_exit:
    wfi


    la t2, input_1
    la t3, output_1
    vsetivli x0, 8, e16, m1, ta, ma
    # loop variables
    li t0, 1
    li t1, 0
    loop16 :  bge t1, t0, loop16_exit
            vle8.v v1, (t2)
            addi t2, t2, 8 # updating input address
            addi t1, t1, 1
            j loop16
    loop16_exit:
    wfi

    la t2, input_1
    la t3, output_1
    vsetivli x0, 4, e32, m1, ta, ma
    # loop variables
    li t0, 1
    li t1, 0
    loop32 :  bge t1, t0, loop32_exit
            vle8.v v1, (t2)
            addi t2, t2, 4 # updating input address
            addi t1, t1, 1
            j loop32
    loop32_exit:
    wfi
    ret