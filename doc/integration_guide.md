# Kelvin Integration Guide



This document describes integrating Kelvin as an AXI/TileLink peripheral in
a bigger system.

## AXI

We provide a scalar-only Kelvin configuration that can integrate with an AXI
based system. The SystemVerilog can be generated with:

``` bash
bazel build //hdl/chisel/src/kelvin:core_mini_axi_cc_library_emit_verilog
```

### Module interfaces

![Kelvin AXI](images/kelvin_axi.svg)

The interfaces to Kelvin are defined as follows:

|   Signal Bundle  |                   Description                             |
| ---------------- | --------------------------------------------------------- |
|       clk        | The clock of the AXI Bus/Kelvin core.                     |
|      reset       | The active-low reset signal for the AXI Bus/Kelvin core.  |
|      s_axi       | An AXI slave interface that can be used to write TCMs or touch Kelvin CSRs. |
|      m_axi       | An AXI master interface used by Kelvin to read/write to memories/CSRs. |
|       irqn       | Active-low interrupt to the Kelvin core. Can be triggered by peripherals or other host processor. |
|       wfi        | Active-high signal from the Kelvin core, indicating that the core is waiting for an interrupt. While this is active, Kelvin is clock-gated. |
|      debug       | Debug interface to monitor Kelvin instructions execution. This interface is typically only used for simulation. |
|      s_log       | Debug interface to handle SLOG instruction. This interface is typically only used for simulation. |
|      halted      | Output interface informing if the Core is running or not. Can be ignored. |
|      fault       | Output interface to determine if the Core hit a fault. These signals should be connected to a system control CPU interrupt-line or status register for notification when Kelvin faults or is halted. |


### Kelvin Memory Map

Memory accesses to Kelvin are defined as follows:

| Region |      Range        |  Size  | Alignment |                 Description                   |
| ------ | ----------------  | ------ | --------- | --------------------------------------------- |
|  ITCM  | 0x0000 -  0x1FFF  |   8kB  |  4 bytes  | ITCM storage for code executed by Kelvin.     |
|  DTCM  | 0x10000 - 0x17FFF |  32kB  |  1 byte   | DTCM storage for data used by Kelvin.         |
|  CSR   | 0x30000 - TBD     |   TBD  |  4 bytes  | CSR interface used to query/control Kelvin.   |

### Reset Considerations
Kelvin uses a synchronous reset strategy -- to ensure proper reset behavior, ensure that the clock runs for a cycle with reset active, before enabling either the internal clock gate (via CSR) or gating externally.

## Booting Kelvin
A note first -- in these examples, Kelvin is located in the overall system memory map at 0x70000000.

1. The instruction memory of Kelvin must be initialized.
```c
volatile uint8_t* kelvin_itcm = (uint8_t*)0x70000000L;
for (int i = 0; i < kelvin_binary_len; ++i) {
    kelvin_itcm[i] = kelvin_binary[i];
}
```

If something like a DMA engine is present in your system, that is probably a better option for initializing the ITCM.

2. Program the start PC
If your program is linked such that the starting address is 0, you may skip this.

```c
volatile uint32_t* kelvin_pc_csr = (uint32_t*)0x70030004L;
*kelvin_pc_csr = start_addr;
```

3. Release clock gate
```c
volatile uint32_t* kelvin_reset_csr = (uint32_t*)0x70030000L;
*kelvin_reset_csr = 1;
```

After this, ensure you wait a cycle to allow Kelvin's reset to occur.
If you want to configure something like an interrupt that is connected to Kelvin's
fault or halted outputs, this is a good time.

4. Release reset
```c
volatile uint32_t* kelvin_reset_csr = (uint32_t*)0x70030000L;
*kelvin_reset_csr = 0;
```

At this point, Kelvin will begin executing at the PC programmed in step 2.

5. Monitor for `io_halted`
The status of Kelvin's execution can be checked by reading the status CSR:
```c
volatile uint32_t* kelvin_status_csr = (uint32_t*)0x70030008L;
uint32_t status = *kelvin_status_csr;
bool halted = status & 1;
bool fault = status & 2;
```
