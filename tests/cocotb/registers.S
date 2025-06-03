    .section .text
    .balign 4
    .global _start
    .type _start, @function
_start:
    li x1,  (1 << 1)
    li x2,  (1 << 2)
    li x3,  (1 << 3)
    li x4,  (1 << 4)
    li x5,  (1 << 5)
    li x6,  (1 << 6)
    li x7,  (1 << 7)
    li x8,  (1 << 8)
    li x9,  (1 << 9)
    li x10, (1 << 10)
    li x11, (1 << 11)
    li x12, (1 << 12)
    li x13, (1 << 13)
    li x14, (1 << 14)
    li x15, (1 << 15)
    li x16, (1 << 16)
    li x17, (1 << 17)
    li x18, (1 << 18)
    li x19, (1 << 19)
    li x20, (1 << 20)
    li x21, (1 << 21)
    li x22, (1 << 22)
    li x23, (1 << 23)
    li x24, (1 << 24)
    li x25, (1 << 25)
    li x26, (1 << 26)
    li x27, (1 << 27)
    li x28, (1 << 28)
    li x29, (1 << 29)
    li x30, (1 << 30)
    li x31, (1 << 31)

    fmv.w.x f0, x0
    fmv.w.x f1, x1
    fmv.w.x f2, x2
    fmv.w.x f3, x3
    fmv.w.x f4, x4
    fmv.w.x f5, x5
    fmv.w.x f6, x6
    fmv.w.x f7, x7
    fmv.w.x f8, x8
    fmv.w.x f9, x9
    fmv.w.x f10, x10
    fmv.w.x f11, x11
    fmv.w.x f12, x12
    fmv.w.x f13, x13
    fmv.w.x f14, x14
    fmv.w.x f15, x15
    fmv.w.x f16, x16
    fmv.w.x f17, x17
    fmv.w.x f18, x18
    fmv.w.x f19, x19
    fmv.w.x f20, x20
    fmv.w.x f21, x21
    fmv.w.x f22, x22
    fmv.w.x f23, x23
    fmv.w.x f24, x24
    fmv.w.x f25, x25
    fmv.w.x f26, x26
    fmv.w.x f27, x27
    fmv.w.x f28, x28
    fmv.w.x f29, x29
    fmv.w.x f30, x30
    fmv.w.x f31, x31

    wfi
    beq x30, x31, pause
    ebreak
pause:
    .word 0x08000073 # mpause
