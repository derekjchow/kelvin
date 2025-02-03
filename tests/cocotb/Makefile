CC=clang-17
CC_FLAGS=--target=riscv32-none-eabi -march=rv32im_zicsr -nostdlib -T kelvin_tcm.ld

all: example_add.bin example_external_read.bin example_external_write.bin

example_add.bin: example_add.elf
	llvm-objcopy-17 example_add.elf -O binary --dump-section .text=example_add.bin

example_add.elf: example_add.c
	$(CC) $(CC_FLAGS) -o example_add.elf example_add.c kelvin_start.S

example_external_read.bin: example_external_read.elf
	llvm-objcopy-17 example_external_read.elf -O binary --dump-section .text=example_external_read.bin

example_external_read.elf: example_external_read.c
	$(CC) $(CC_FLAGS) -o example_external_read.elf example_external_read.c kelvin_start.S

example_external_write.bin: example_external_write.elf
	llvm-objcopy-17 example_external_write.elf -O binary --dump-section .text=example_external_write.bin

example_external_write.elf: example_external_write.c
	$(CC) $(CC_FLAGS) -o example_external_write.elf example_external_write.c kelvin_start.S

.PHONY: clean
clean:
	rm -rf *.elf *.bin

# Inspect file
#llvm-objcopy-17 -I binary -O elf32-littleriscv --rename-section=.data=.text,code example_add.bin file.elf
#llvm-objdump-17 -d file.elf

