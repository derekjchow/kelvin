# Load Store Unit

![image](../images/lsu.svg)

The Load Store Unit handles memory operations issued by the core. Functionally,
it's purpose is to translate memory instructions into transactions on the
appropriate subsystem.

## Pipeline

The pipeline stages for the LSU are as follows:

* **Enqueue Command:** After an instruction is dispatched, it reads operands
from the register file the next cycle. The instruction+operands are combined
into a command and inserted into the LSU command queue. This stage takes 1 cycle
to complete for all dispatched commands.
* **Transfer Memory:**  The next pipeline stage in the LSU operates on one
memory operation taken from the command queue at a time, in-order. This stage
can take a variable number of cycles. While commands to TCM can typically be
handled in 1-cycle writes and 2-cycle reads, commands to external interfaces may
exert back-pressure.

## Handling Memory Transactions

The address of the operation determines which bus a memory transaction is
serviced on:

* **IBus:** Addresses mapped to ITCM will go through the IBus interface of the
LSU. Note there is no write interface on the IBus, so Kelvin cannot overwrite
it's own instructions. Store instructions to ITCM will generate a fault.
* **DBus:** Addresses mapped to DTCM will go through the DBus interface of the
LSU.
* **EBus:** Addressed not mapped to either ITCM or DTCM get mapped to the EBus
interface. This interface will drive transactions over the Kelvin Master AXI
interface.

Load results from the LSU are returned back to the register file asynchronously.
Faults are also reported to the Kelvin Core asynchronously.

A "memory active" interface is also returned back to the Core. This signal is
used by dispatch to ensure all memory operations are committed before
certain operations are dispatched: `wfi`, `fencei` and `ebreak`.