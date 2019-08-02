RISCV_COMPILER=$(RISCV)/bin/riscv32-unknown-elf-gcc
RISCV_OBJCOPY=$(RISCV)/bin/riscv32-unknown-elf-objcopy
RISCV_OBJDUMP=$(RISCV)/bin/riscv32-unknown-elf-objdump
LD=../inc/link.ld
START=../inc/start.S

compile:
	$(RISCV_COMPILER) -g -march=rv32i -mabi=ilp32 -nostdlib -T $(LD) $(START) ./src/main.c -o counter

