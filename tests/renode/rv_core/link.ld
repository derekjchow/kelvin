/* Copyright 2024 Google LLC. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

MEMORY {
    RAM(rwx) : ORIGIN = 0x20000000, LENGTH = 0x400000
}

STACK_SIZE = DEFINED(__stack_size__) ? __stack_size__ : 0x4000;

ENTRY(_start)

SECTIONS {
    . = ORIGIN(RAM);
    .text : ALIGN(4) {
        *(.text)
        *(.text.*)
        . = ALIGN(4);
    } > RAM

    .stack : ALIGN(4) {
      __stack_start__ = .;
      . += STACK_SIZE;
      __stack_end__ = .;
    } > RAM
}
