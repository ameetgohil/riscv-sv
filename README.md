# riscv-sv
RISC-V implementation

# Dependencies
- RISC-V gcc tools
- [Verilator (version 4.0 or above)](https://www.veripool.org/projects/verilator/wiki/Installing)
- [nvm](https://github.com/creationix/nvm)
- cmake
- gtkwave (optional)

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
