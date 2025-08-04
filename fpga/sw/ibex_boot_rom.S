// A simple program that sets up a stack and calls main.
.section .text
.globl _start
.org 0x80
_start:
  // Set up the stack pointer
  la sp, _stack_start

  // Clear registers
  mv   tp, zero
  mv   t1, zero
  mv   t2, zero
  mv   s0, zero
  mv   s1, zero
  mv   a1, zero
  mv   a2, zero
  mv   a3, zero
  mv   a4, zero
  mv   a5, zero
  mv   a6, zero
  mv   a7, zero
  mv   s2, zero
  mv   s3, zero
  mv   s4, zero
  mv   s5, zero
  mv   s6, zero
  mv   s7, zero
  mv   s8, zero
  mv   s9, zero
  mv   s10, zero
  mv   s11, zero
  mv   t3, zero
  mv   t4, zero
  mv   t5, zero
  mv   t6, zero

  // Call main
  call main

  // Wait for interrupt
  wfi

// Infinite loop
_hang:
  j _hang
