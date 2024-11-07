.globl _start
_start:
    la sp, __stack_end__
    la ra, main
    jalr ra
    .word 0x08000073 # mpause