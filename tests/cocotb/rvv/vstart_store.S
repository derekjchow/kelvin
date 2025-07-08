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

.global input_data
input_data:
    .space 64

.global output_data
output_data:
    .space 64

.section .text
.global main
.option norelax

main:
    la t0, input_data
    la t1, output_data

    vsetivli x0, 16, e8, m1, ta, ma
    vle8.v v1, (t0)

    li t2, 4
    csrw vstart, t2

    vse8.v v1, (t1)

    wfi
    ret
