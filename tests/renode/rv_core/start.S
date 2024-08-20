.globl _start
_start:
    la sp, __stack_end__
    la ra, main
    jalr ra
0:  wfi
    j 0b
