MEMORY {
  rom (rx) : ORIGIN = 0x10000000, LENGTH = 0x8000
  sram (rwx) : ORIGIN = 0x20000000, LENGTH = 0x400000
}

ENTRY(_start)

SECTIONS {
  . = 0x10000080;
  .text : {
    *(.text)
    *(.text.*)
  } > rom

  .stack (NOLOAD) : {
    . = ALIGN(16);
    . = . + 4K;
    _stack_start = .;
  } > sram
}
