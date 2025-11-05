/* Copyright 2025 Google LLC. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

MEMORY {
    ITCM(rx): ORIGIN = 0x00000000, LENGTH = 8K
    DTCM(rw): ORIGIN = 0x00010000, LENGTH = 32K
}

STACK_SIZE = DEFINED(__stack_size__) ? __stack_size__ : 0x80;
__stack_size = STACK_SIZE;
__stack_shift = 7;
__boot_hart = 0;

ENTRY(_start)

SECTIONS {
    /* ITCM data here */
    . = ORIGIN(ITCM);
    .text : ALIGN(16) {
        *(._init)
        *(.text)
        *(.text.*)
        . = ALIGN(16);
    } > ITCM

    .init.array : ALIGN(16) {
      __init_array_start = .;
      __init_array_start__ = .;
      *(.init_array)
      *(.init_array.*)
      . = ALIGN(16);
      __init_array_end = .;
      __init_array_end__ = .;
    } > ITCM

    .rodata : ALIGN(16) {
      *(.srodata)
      *(.srodata.*)
      *(.rodata)
      *(.rodata.*)
      . = ALIGN(16);
    } > ITCM

    /* Static Thread Local Storage template */
    .tdata : {
        PROVIDE_HIDDEN (__tdata_start = .);
        *(.tdata .tdata.*)
        *(.gnu.linkonce.td.*)
        PROVIDE_HIDDEN (__tdata_end = .);
    } > DTCM
    PROVIDE (__tdata_size = SIZEOF (.tdata));

    .tbss (NOLOAD) : {
        PROVIDE_HIDDEN (__tbss_start = .);
        PROVIDE_HIDDEN (__tbss_offset = ABSOLUTE (__tbss_start - __tdata_start));
        *(.tbss .tbss.*)
        *(.gnu.linkonce.tb.*)
        *(.tcommon)
        PROVIDE_HIDDEN (__tbss_end = .);
    } > DTCM
    PROVIDE (__tbss_size = SIZEOF (.tbss));

    .data : ALIGN(16) {
      __data_start__ = .;
      /**
      * This will get loaded into `gp`, and the linker will use that register for
      * accessing data within [-2048,2047] of `__global_pointer$`.
      *
      * This is much cheaper (for small data) than materializing the
      * address and loading from that (which will take one extra instruction).
      */
      _global_pointer = . + 0x800;
      __global_pointer$ = . + 0x800;
      *(.sdata)
      *(.sdata.*)
      *(.data)
      *(.data.*)
      /**
       * Memory location for the return value from main,
       * which could be inspected by another core in the system.
       **/
      . = ALIGN(4);
      _ret = .;
      . += 4;
      . = ALIGN(16);
      __data_end__ = .;
      _edata = .;
    } > DTCM

    /* DTCM data here */
    . = ORIGIN(DTCM);
    .bss : ALIGN(16) {
      __bss_start__ = .;
      __bss_start = .;
      *(.sbss)
      *(.sbss.*)
      *(.bss)
      *(.bss.*)
      __bss_end__ = .;
      __bss_end = .;
      _end = .;
    } > DTCM

    .heap : ALIGN(16) {
      __heap_start__ = .;
      . = ORIGIN(DTCM) + LENGTH(DTCM) - STACK_SIZE;
      __heap_end__ = .;
      __heap_end = .;
    } > DTCM

    .stack : ALIGN(16) {
      __stack_start__ = .;
      __stack_start = .;
      . += STACK_SIZE;
      __stack_end__ = .;
    } > DTCM
}
