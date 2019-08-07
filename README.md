# riscv-sv
RISC-V implementation

# Dependencies
RISC-V gcc tools
Verilator

Set the RISCV variable in the environment to the location of riscv gcc tools

# Run instructions
```bash
cd c/counter
make

cd ../../sim
make

gtkwave logs/top.fst
```
