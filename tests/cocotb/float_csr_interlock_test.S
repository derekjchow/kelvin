.balign 4
.global main
.type main, @function
main:
    # 2.0f -> x2
    li x2, 0x40000000
    # x2 -> ft0
    fmv.w.x ft0, x2
    # Read the fflags CSR into x1
    csrr x1, fflags
    # Issue sqrt(2.0), which should set the inexact flag
    fsqrt.s  ft1, ft0
    # Read fflags, and compare to the previous value.
    csrr x3, fflags
    # If the flags register did not change, we have an error.
    beq x1, x3, 1f
    .word 0x08000073
1:
    ebreak
