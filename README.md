# riscv-sv
RISC-V implementation

# Dependencies
RISC-V gcc tools
Verilator
npm

Set the RISCV variable in the environment to the location of riscv gcc tools

# Run instructions
```bash
cd c/counter
make

cd ../../sim
npm i
make

gtkwave logs/top.fst
```
