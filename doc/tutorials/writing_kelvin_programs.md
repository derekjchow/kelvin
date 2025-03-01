# Writing a Kelvin Program

This tutorial introduces the basics of writing a Kelvin program. You will:

1) Learn the basic structure of a Kelvin program.
2) Write and compile a basic program.
3) Test your program with a cocotb test bench.

## Prerequistes

This tutorial assumes you have clang-17 and bazel installed on your machine.

## Writing a basic Kelvin program

Open up [`tests/cocotb/tutorial/program.c`](../../tests/cocotb/tutorial/program.c),
which is a skeleton program:

```c
// TODO: Add two inputs buffers of 8 uint32_t's (input1_buffer, input2_buffer)
// TODO: Add one input buffer of 8 uint32_t's (output_buffer)

int main(int argc, char** argv) {
  // TODO: Add code to element wise add/subtract from input1_buffer and
  // input2_buffer and store the result to output_buffer.

  return 0;
}
```

The typical structure of a Kelvin program includes:

1) Input buffers, to store the inputs to the computation you want to perform.
   For this tutorial, we will assume the host core will write data to Kelvin's
   DTCM before the program executes.
2) Output buffers, for Kelvin to store the result of computation. Similar to
   the input buffers, we'll assume that Kelvin will write to a location in it's
   DTCM to be read by the host processor after it completes.
3) The actual computation to be performed.

### Defining Input and Output Buffers

For this tutorial we'll accept two input buffers and emit one output buffer,
each consisting of 8 uint32_t. We define them outside of `main`.

```c
uint32_t input1_buffer[8];
uint32_t input2_buffer[8];
uint32_t output_buffer[8];

int main(int argc, char** argv) {
  // TODO: Add code to element wise add/subtract from input1_buffer and
  // input2_buffer and store the result to output_buffer.

  return 0;
}
```

For this tutorial, we do not need to define the precise locations of these
buffers. Our linker script will allocate them in DTCM and we'll query their
locations in our test bench.

### Defining Computation

As a simple example, let's add element-wise the elements from `input1_buffer`
to `input2_buffer`:

```c
uint32_t input1_buffer[8];
uint32_t input2_buffer[8];
uint32_t output_buffer[8];

int main(int argc, char** argv) {
  for (int i = 0; i < 8; i++) {
    output_buffer[i] = input1_buffer[i] + input2_buffer[i];
  }
  return 0;
}
```

The core will halt when returning from `main`.

### Compiling the program

A Makefile is included in `test/cocotb/tutorial`. Simply run `make` in that
directory to generate the program `program.elf`.

## Creating the test bench

Open up [`tests/cocotb/tutorial/tutorial.py`](../../tests/cocotb/tutorial/tutorial.py)
which contains the skeleton testbench:

```python
@cocotb.test()
async def core_mini_axi_tutorial(dut):
    """Testbench to run your Kelvin program."""
    # Test bench setup
    core_mini_axi = CoreMiniAxiInterface(dut)
    await core_mini_axi.init()
    await core_mini_axi.reset()
    cocotb.start_soon(core_mini_axi.clock.start())
```

First, we need to program ITCM with your program. A `load_elf` function is
provided to copy all loadable sections into memory. Add the following to
`core_mini_axi_tutorial`:

```python
@cocotb.test()
async def core_mini_axi_tutorial(dut):
    """Testbench to run your Kelvin program."""
    ...
    with open("../tests/cocotb/tutorial/program.elf", "rb") as f:
      entry_point = await core_mini_axi.load_elf(f)
```

Before we start the program, let's also write inputs into DTCM. We can
determine the location of a buffer using `lookup_symbol` and write to DTCM with
`write`:

```python
@cocotb.test()
async def core_mini_axi_tutorial(dut):
    """Testbench to run your Kelvin program."""
    ...
    with open("../tests/cocotb/tutorial/program.elf", "rb") as f:
      ...
      inputs1_addr = core_mini_axi.lookup_symbol(f, "input1_buffer")
      inputs2_addr = core_mini_axi.lookup_symbol(f, "input2_buffer")

    input1_data = np.arange(8, dtype=np.uint32)
    input2_data = 8994 * np.ones(8, dtype=np.uint32)
    await core_mini_axi.write(inputs1_addr, input1_data)
    await core_mini_axi.write(inputs2_addr, input2_data)
```

Now that input data has been written, let's actually run the program! Use
`execute_from` to start the program on Kelvin. Once it's running, wait for the
core to halt, so we know it's done work and we can read the result:

```python
@cocotb.test()
async def core_mini_axi_tutorial(dut):
    """Testbench to run your Kelvin program."""
    ...
    await core_mini_axi.execute_from(entry_point)
    await core_mini_axi.wait_for_halted()
```

Finally, let's `read` and print the result:

```python
@cocotb.test()
async def core_mini_axi_tutorial(dut):
    """Testbench to run your Kelvin program."""
    ...
    rdata = (await core_mini_axi.read(outputs_addr, 4 * 8)).view(np.uint32)
    print(f"I got {rdata}")
```

## Running the test bench

You can run the test bench with:

```bash
bazel run //tests/cocotb/tutorial:tutorial
```

You should the following in the console output:

```bash
I got [8994 8995 8996 8997 8998 8999 9000 9001]
```

Congratulations on running your first program!

## Next steps

Follow up tutorials will cover accelerating Kelvin with RISC-V Vector
intrinsics.