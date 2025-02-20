# Kelvin Dispatch Rules

We want to dispatch as many instructions as possible in the Kelvin core. The
following describes the general rules we use to determine which instructions can
be dispatcted.

## In-order

Kelvin is an in-order core. In at instruction at address n cannot be dispatched,
n+4 is also not considered for dispatch.

## Hazard Free

Kelvin uses scoreboarding to track dependencies across instructions. This
prevents RAW and WAW data hazards. All execution units read their operands from
the register file the cycle after the instructions are dispatched. Therefore,
it is not possible for WAR hazard to occur.

## Execution Unit Constraints

There are a limited number of execution units to service instructions. While
there are enough Alu and Bru units to service each lane, Kelvin contains only
1 Mlu. Therefore, we restrict the number of multiply instructions per-cycle to
a single instruction. Simiarily, non-pipelined execution units (ie. Dvu) may
exert backpressure to prevent an instruction from being dispatched while it is
busy.

Memory today is limited to dispatching one instruction per cycle.

## Control Flow

Conservatively, Kelvin will not dispatch past jump instructions. This also
includes instructions such as ebreak/ecall.
