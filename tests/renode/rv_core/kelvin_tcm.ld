/* Copyright 2024 Google LLC. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

MEMORY {
    ITCM(rx): ORIGIN = 0x00000000, LENGTH = 8K
    DTCM(rw): ORIGIN = 0x00020000, LENGTH = 32K
}

STACK_SIZE = DEFINED(__stack_size__) ? __stack_size__ : 0x80;
HEAP_SIZE = DEFINED(__heap_size__) ? __heap_size__ : 0x80;

ENTRY(_start)

SECTIONS {
    /* ITCM data here */
    . = ORIGIN(ITCM);
    .text : ALIGN(4) {
        *(._init)
        *(.text)
        *(.text.*)
        . = ALIGN(4);
    } > ITCM

    .init.array : ALIGN(4) {
      __init_array_start = .;
      *(.init_array)
      *(.init_array.*)
      . = ALIGN(4);
      __init_array_end = .;
    } > ITCM

    .rodata : ALIGN(4) {
      *(.srodata)
      *(.srodata.*)
      *(.rodata)
      *(.rodata.*)
      . = ALIGN(4);
    } > ITCM

    /* TODO(atv): This would be good in DTCM. But needs a proper ELF loader. */
    .data : ALIGN(4) {
      __data_start__ = .;
      /**
      * This will get loaded into `gp`, and the linker will use that register for
      * accessing data within [-2048,2047] of `__global_pointer$`.
      *
      * This is much cheaper (for small data) than materializing the
      * address and loading from that (which will take one extra instruction).
      */
      _global_pointer = . + 0x800;
      *(.sdata)
      *(.sdata.*)
      *(.data)
      *(.data.*)
      . = ALIGN(4);
        __data_end__ = .;
    } > ITCM

    /* DTCM data here */
    . = ORIGIN(DTCM);
    .bss : ALIGN(4) {
      __bss_start__ = .;
      *(.sbss)
      *(.sbss.*)
      *(.bss)
      *(.bss.*)
      __bss_end__ = .;
    } > DTCM

    .heap : ALIGN(4) {
      __heap_start__ = .;
      . += HEAP_SIZE;
      __heap_end__ = .;
    } > DTCM

    .stack : ALIGN(4) {
      __stack_start__ = .;
      . += STACK_SIZE;
      __stack_end__ = .;
    } > DTCM
}