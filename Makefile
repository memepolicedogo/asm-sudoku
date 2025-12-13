ASM=nasm
ASM_FLAGS= -f elf64
ASSEMBLE=$(ASM) $(ASM_FLAGS)
LINK=ld

debug: ASM_FLAGS+= -g -F dwarf
debug: sudoku

sudoku: main.o check_input.o gen_board.o
	$(LINK) $^ -o $@
	@rm -f *.o
main.o: main.asm
	$(ASSEMBLE) $< -o $@

check_input.o: include/check_input.asm
	$(ASSEMBLE) $< -o $@

gen_board.o: include/gen_board.asm
	$(ASSEMBLE) $< -o $@

