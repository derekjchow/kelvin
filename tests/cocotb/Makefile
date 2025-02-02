example_add.bin: example_add.elf
	llvm-objcopy-17 example_add.elf -O binary --dump-section .text=example_add.bin

example_add.elf: example_add.c
	clang-17 --target=riscv32-none-eabi -march=rv32im_zicsr -nostdlib -T kelvin_tcm.ld -o example_add.elf example_add.c kelvin_start.S

.PHONY: clean
clean:
	rm -rf example_add.elf example_add.bin

# Inspect file
#llvm-objcopy-17 -I binary -O elf32-littleriscv --rename-section=.data=.text,code example_add.bin file.elf
#llvm-objdump-17 -d file.elf

