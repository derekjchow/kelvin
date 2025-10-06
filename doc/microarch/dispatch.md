# CoralNPU Dispatch Rules

We want to dispatch as many instructions as possible in the CoralNPU core. The
following describes the general rules we use to determine which instructions can
be dispatcted.

## In-order

CoralNPU is an in-order core. In at instruction at address n cannot be dispatched,
n+4 is also not considered for dispatch.

## Hazard Handling

CoralNPU uses scoreboarding to track dependencies across instructions. This
prevents RAW and WAW data hazards. All execution units read their operands from
the register file the cycle after the instructions are dispatched. Therefore,
WAR hazard never occurs.

## Execution Unit Constraints

There are a limited number of execution units to service instructions. While
there are enough Alu and Bru units to service each lane, CoralNPU contains only
1 Mlu. Therefore, we restrict the number of multiply instructions per-cycle to
a single instruction. Simiarily, non-pipelined execution units (ie. Dvu) may
exert backpressure to prevent an instruction from being dispatched while it is
busy.

Memory today is limited to dispatching one instruction per cycle.

## Control Flow

Conservatively, CoralNPU will not dispatch past the following jump instructions:
`jal`, `jalr`, `ebreak`, `ecall`, `mret`, `wfi`.

## Special Instructions

Instructions that can affect the core state beyond the PC/RegisterFile are
limited to executing out of the first slot. They are also typically treated as
jump control flow instructions, so no other instructions should be dispatched in
the same cycle as these. These instructions are: `csrrw`, `csrrs`, `csrrc`
`ebreak`, `ecall`, `mret`, `fence`, `fenci` and `wfi`.