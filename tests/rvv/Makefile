 CXXFLAGS = \
	--target=riscv32-none-eabi \
	-march=rv32im_zve32x \
	-nostdlib \
	-O2

empty.elf: empty.cc kelvin_tcm.ld start.s
	clang-17 $(CXXFLAGS) -T kelvin_tcm.ld -o empty.elf empty.cc start.s

.PHONY : clean

clean:
	rm empty.elf
