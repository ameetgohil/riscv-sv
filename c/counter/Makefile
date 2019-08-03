RISCV_COMPILER=$(RISCV)/bin/riscv32-unknown-elf-gcc
RISCV_OBJCOPY=$(RISCV)/bin/riscv32-unknown-elf-objcopy
RISCV_OBJDUMP=$(RISCV)/bin/riscv32-unknown-elf-objdump
LD=../inc/link.ld
START=../inc/start.S


default: all

all: compile objcopy

compile:
	rm -rf build
	mkdir build
	$(RISCV_COMPILER) -g -march=rv32i -mabi=ilp32 -nostdlib -T $(LD) $(START) ./src/main.c -o build/counter.elf -Wl,-Map,build/counter.map,--print-memory-usage

objcopy:
	$(RISCV_OBJCOPY) -O ihex build/counter.elf build/counter.hex
	$(RISCV_OBJDUMP) -S -d build/counter.elf > build/counter.asm
	$(RISCV_OBJDUMP)  -t build/counter.elf > build/counter_symbols.txt



