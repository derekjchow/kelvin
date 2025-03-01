CC=clang-17
CC_FLAGS=--target=riscv32-none-eabi -march=rv32im_zicsr -nostdlib -T kelvin_tcm.ld

program.elf: program.c
	$(CC) $(CC_FLAGS) -o program.elf program.c kelvin_start.S

.PHONY: clean
clean:
	rm -rf *.elf