# CoralNPU Integration Guide



This document describes integrating CoralNPU as an AXI/TileLink peripheral in
a bigger system.

## AXI

We provide a scalar-only CoralNPU configuration that can integrate with an AXI
based system. The SystemVerilog can be generated with:

``` bash
bazel build //hdl/chisel/src/coralnpu:core_mini_axi_cc_library_emit_verilog
```

### Module interfaces

![CoralNPU AXI](images/coralnpu_axi.svg)

The interfaces to CoralNPU are defined as follows:

|   Signal Bundle  |                   Description                             |
| ---------------- | --------------------------------------------------------- |
|       clk        | The clock of the AXI Bus/CoralNPU core.                     |
|      reset       | The active-low reset signal for the AXI Bus/CoralNPU core.  |
|      s_axi       | An AXI4 slave interface that can be used to write TCMs or touch CoralNPU CSRs. |
|      m_axi       | An AXI4 master interface used by CoralNPU to read/write to memories/CSRs. |
|       irqn       | Active-low interrupt to the CoralNPU core. Can be triggered by peripherals or other host processor. |
|       wfi        | Active-high signal from the CoralNPU core, indicating that the core is waiting for an interrupt. While this is active, CoralNPU is clock-gated. |
|      debug       | Debug interface to monitor CoralNPU instructions execution. This interface is typically only used for simulation. |
|      s_log       | Debug interface to handle SLOG instruction. This interface is typically only used for simulation. |
|      halted      | Output interface informing if the Core is running or not. Can be ignored. |
|      fault       | Output interface to determine if the Core hit a fault. These signals should be connected to a system control CPU interrupt-line or status register for notification when CoralNPU faults or is halted. |

#### AXI master signals

AR / AW channel

| Signal | Behaviour |
| ------ | --------- |
| addr   | Address CoralNPU wishes to read/write |
| prot   | Always 2 (unprivileged, insecure, data) |
| id     | Always 0 |
| len    | (Count of beats in the burst) - 1 |
| size   | Bytes-per-beat (1, 2, or 4) |
| burst  | Always 1 (INCR) |
| lock   | Always 0 (normal access) |
| cache  | Always 0 (Device non-bufferable) |
| qos    | Always 0 |
| region | Always 0 |

R channel

| Signal | Behaviour |
| ------ | --------- |
| data   | Response data from the slave |
| id     | Ignored, but should be 0 as CoralNPU only emits txns with an id of 0 |
| resp   | Response code |
| last   | Whether the beat is the last in the burst |

W channel

| Signal | Behaviour |
| ------ | --------- |
| data   | Data CoralNPU wishes to write |
| last   | Whether the beat is the last in the burst |
| strb   | Which bytes in the data are valid |

B channel

| Signal | Behaviour |
| ------ | --------- |
| id     | Ignored, but should be 0 as CoralNPU only emits txns with an id of 0 (an RTL assertion exists for this) |
| resp   | Response code |

Note: the USER signal is not supported on any of the channels.

#### AXI slave signals

AR / AW channel

| Signal | Behaviour |
| ------ | --------- |
| addr   | Address the master wishes to read / write to |
| prot   | Ignored |
| id     | Transaction ID, should be reflected in the response beats |
| len    | (Count of beats in the burst) - 1 |
| size   | Bytes-per-beat (1,2,4,8,16) |
| burst  | 0, 1, or 2 (FIXED, INCR, WRAP) |
| lock   | Ignored |
| cache  | Ignored |
| qos    | Ignored |
| region | Ignored |

R channel

| Signal | Behaviour |
| ------ | --------- |
| data   | Response data from CoralNPU |
| id     | Transaction ID, should match with the id field from AR |
| resp   | Response code (0/OKAY or 2/SLVERR) |
| last   | Whether the beat is the last in the burst |

W channel

| Signal | Behaviour |
| ------ | --------- |
| data   | Data the master wishes to write to CoralNPU |
| last   | Whether the beat is the last in the burst |
| strb   | Which bytes in data are valid |

B channel

| Signal | Behaviour |
| ------ | --------- |
| id     | Transaction ID, should match with the id field from AW |
| resp   | Response code (0/OKAY or 2/SLVERR)

Note: the USER signal is not supported on any of the channels.

#### Debug Signals

| Signal   | Behaviour |
| -------- | --------- |
| en       | 4-bit value, indicating which fetch lanes are active |
| addr     | 32-bit values, containing the PC for each fetch lane |
| inst     | 32-bit values, containing the instruction for each fetch lane |
| cycles   | cycle counter |
| dbus     | Information about internal LSU transactions |
| -> valid | Whether the transaction is valid |
| -> bits  | addr: The 32-bit address for the transaction |
|          | write: If the transaction is a write |
|          | wdata: 128-bit write data for the transaction |
| dispatch | Information about instructions which are dispatched for execution |
| -> fire  | If an instruction was dispatched in the slot, this cycle |
| -> addr  | The 32-bit address of the instruction |
| -> inst  | The 32-bit value of the instruction |
| regfile  | Information about writes to the integer register file |
| -> writeAddr | Register addresses to which a future write is expected |
| ->-> valid | If an instruction was dispatched in this lane, which will write the regfile |
| ->-> bits | The 5-bit register address to which the write is expected |
| -> writeData | For each port in the register file, information about writes |
| ->-> valid | If a write occurred on this port, this cycle |
| ->-> bits_addr | The 5-bit register address to which the write occurred |
| ->-> bits_data | The 32-bit value which was written to the register |
| float | Information about write to the floating point register file |
| -> writeAddr | Register addresses to which a future write is expected |
| ->-> valid | If an instruction was dispatched to floating point on this cycle |
| ->-> bits | The address of the register to which a write is expected |
| -> writeData | For each port in the register file, information about writes |
| ->-> valid | If a write occured on this port, this cycle |
| ->-> bits_addr | The 5-bit register address to which the writh occurred |
| ->-> bits_data | The 32-bit value which was written to the register |


### CoralNPU Memory Map

Memory accesses to CoralNPU are defined as follows:

| Region |      Range        |  Size  | Alignment |                 Description                   |
| ------ | ----------------  | ------ | --------- | --------------------------------------------- |
|  ITCM  | 0x0000 -  0x1FFF  |   8kB  |  4 bytes  | ITCM storage for code executed by CoralNPU.     |
|  DTCM  | 0x10000 - 0x17FFF |  32kB  |  1 byte   | DTCM storage for data used by CoralNPU.         |
|  CSR   | 0x30000 - TBD     |   TBD  |  4 bytes  | CSR interface used to query/control CoralNPU.   |

### Reset Considerations
CoralNPU uses a synchronous reset strategy -- to ensure proper reset behavior, ensure that the clock runs for a cycle with reset active, before enabling either the internal clock gate (via CSR) or gating externally.

## Booting CoralNPU
A note first -- in these examples, CoralNPU is located in the overall system memory map at 0x70000000.

1. The instruction memory of CoralNPU must be initialized.
```c
volatile uint8_t* coralnpu_itcm = (uint8_t*)0x00000000L;
for (int i = 0; i < coralnpu_binary_len; ++i) {
    coralnpu_itcm[i] = coralnpu_binary[i];
}
```

If something like a DMA engine is present in your system, that is probably a better option for initializing the ITCM.

2. Program the start PC
If your program is linked such that the starting address is 0, you may skip this.

```c
volatile uint32_t* coralnpu_pc_csr = (uint32_t*)0x00030004L;
*coralnpu_pc_csr = start_addr;
```

3. Release clock gate
```c
volatile uint32_t* coralnpu_reset_csr = (uint32_t*)0x00030000L;
*coralnpu_reset_csr = 1;
```

After this, ensure you wait a cycle to allow CoralNPU's reset to occur.
If you want to configure something like an interrupt that is connected to CoralNPU's
fault or halted outputs, this is a good time.

4. Release reset
```c
volatile uint32_t* coralnpu_reset_csr = (uint32_t*)0x00030000L;
*coralnpu_reset_csr = 0;
```

At this point, CoralNPU will begin executing at the PC programmed in step 2.

5. Monitor for `io_halted`
The status of CoralNPU's execution can be checked by reading the status CSR:
```c
volatile uint32_t* coralnpu_status_csr = (uint32_t*)0x00030008L;
uint32_t status = *coralnpu_status_csr;
bool halted = status & 1;
bool fault = status & 2;
```

# CoralNPU CSRs
Note: These are CSRs that are intended to be read or written externally
to CoralNPU, e.g. by the host processor in a system.
They are not the same as the RISC-V CSRs accessed via the Zicsr ISA extension.

### Register: `RESET_CONTROL`
*   **Offset**: `0x0`
*   **Description**: Controls reset and clock gating for the CoralNPU core. On power-up, the core is held in reset with its clock gated. To start the core, the clock gate should be released first, followed by de-asserting reset.

| Bits  | Name         | Description                                                                                             | Access | Reset Value |
| :---- | :----------- | :------------------------------------------------------------------------------------------------------ | :----- | :---------- |
| 0     | `RESET`      | When 1, the core is held in reset. When 0, the core is not in reset.                                    | R/W    | 1           |
| 1     | `CLOCK_GATE` | When 1, the core's clock is gated. When 0, the core's clock is running.                                 | R/W    | 1           |
| 31:2  | `RESERVED`   | Reserved, writes ignored, reads return 0.                                                               | R      | 0           |

### Register: `PC_START`
*   **Offset**: `0x4`
*   **Description**: Sets the program counter for the CoralNPU core. This should be programmed before releasing the core from reset.

| Bits  | Name            | Description                                         | Access | Reset Value |
| :---- | :-------------- | :-------------------------------------------------- | :----- | :---------- |
| 31:0  | `START_ADDRESS` | The address where the core will begin execution.    | R/W    | 0           |

### Register: `STATUS`
*   **Offset**: `0x8`
*   **Description**: Provides status on the CoralNPU core. This is a read-only register.

| Bits  | Name       | Description                                                              | Access | Reset Value |
| :---- | :--------- | :----------------------------------------------------------------------- | :----- | :---------- |
| 0     | `HALTED`   | When 1, the core has halted (e.g. after an `mpause` instruction).        | R      | 0           |
| 1     | `FAULT`    | When 1, the core has encountered a fault.                                | R      | 0           |
| 31:2  | `RESERVED` | Reserved, reads return 0.                                                | R      | 0           |
