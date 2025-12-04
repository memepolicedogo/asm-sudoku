#! /bin/bash
nasm -f elf64 -g -F dwarf src.asm && ld -o sudoku src.o && rm *.o

