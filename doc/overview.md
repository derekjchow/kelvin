# CoralNPU

CoralNPU is a RISCV CPU built with custom SIMD instructions and microarchitectural
decisions that align with the dataplane properties of an ML accelerator. The design
of CoralNPU starts with domain and matrix capabilities; vector and scalar
capabilities are then added for a fused design.

## Block Diagram

![CoralNPU block diagram](images/coralnpu_block.png)

## Scalar Core

A simple RISC-V scalar frontend drives the command queues of the ML+SIMD
backend.

CoralNPU utilizes a custom RISC-V frontend (rv32im) that runs the minimal set of
instructions to support an executor run-to-completion model (eg. no OS, no
interrupts), with all control tasks onloaded to the SMC . The C extension
encoding is reclaimed (as per the risc-v specification) to provide the necessary
encoding space for the SIMD registers (6b indices), and to allow flexible type
encodings and instruction compression (stripmining) for the SIMD instruction
set. The scalar core is an in order machine with no speculation.

The branch policy in the fetch stage is backwards branches are taken and forward
branches are not-taken, incurring a penalty cycle if the execute result does not
match the decision in the fetch unit.

Registers        | Names         | Width
---------------- | ------------- | -----------------------
Scalar (31)      | zero, x1..x31 | 32 bits
Control & Status | CSRx          | Various

## Vector Core

We use SIMD and vector interchangeably, referring to a simple and practical SIMD
instruction definition devoid of variable length behaviors. The scalar frontend
is decoupled from the backend by a FIFO structure that buffers vector
instructions, posting only to the relevant command queues when dependencies are
resolved in the vector regfile. The vector core supports data widths of 8, 16, and 32 bits.

Registers        | Names         | Width
---------------- | ------------- | -----------------------
Vector (64)      | v0..v63       | 256 bits (eg. int32 x8)
Accumulator      | acc<8><8>     | 8x8x 32 bits


### MAC

The central component of the design is a quantized outer product
multiply-accumulate engine. An outer-product engine provides two-dimensional
broadcast structures to maximize the amount of deliverable compute with respect
to memory accesses. On one axis is a parallel broadcast (“wide”, convolution
weights), and the other axis the transpose shifted inputs of a number of batches
(“narrow”, eg. MobileNet XY batching).

![CoralNPU MAC](images/coralnpu_aconv.png)

The outer-product construction is a vertical arrangement of multiple VDOT
opcodes which utilize 4x 8bit multiplies reduced into 32 bit accumulators and
performing 256 MACs per cycle.

### Stripmining

Strip mining is defined as folding array-based parallelism to fit the available
hardware parallelism. To reduce frontend instruction dispatch pressure becoming
a bottleneck, and to natively support instruction level tiling patterns through
the SIMD registers, the instruction encoding shall explicitly include a
stripmine mechanism that converts a single frontend dispatch event to the
command queue into four serialized issue events into the SIMD units. For
instance a “vadd v0” in Dispatch will produce “vadd v0 : vadd v1 : vadd v2 :
vadd v3” at Issue. These will be processed as four discrete events.

## Cache

Caches exists as a single layer between the core and the first level of shared
SRAM. The L1 cache and scalar core frontend are an overhead to the rest of the
backend compute pipeline and ideally are as small as possible.

The L1Icache is 8KB (256b blocks * 256 slots) with 4-way set associativity.

The L1Dcache sizing is towards the scalar core requirements to perform loop
management and address generation. The L1Dcache is 16KB (SIMD256b) with low set
associativity of 4-way. The L1Dcache is implemented with a dual bank
architecture where each bank is 8KB (similar to L1Icache). This property allows
for a degree of next line prefetch. The L1Dcache also serves as an alignment
buffer for the scalar and SIMD instructions to assist development and to
simplify software support. In an embedded setting, the L1Dcache provides half of
the memory bandwidth to the ML outer-product engine when only a single external
memory port is provided. Line and all entry flushing is supported where the core
stalls until completion to simplify the contract.
