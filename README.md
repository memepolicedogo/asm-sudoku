### ASM SUDOKU
Big 'ole NASM project, uses ANSI control codes and stuff to do terminal sudoku\\
Build it with `build.sh`, uses NASM and ld\\
Move around with arrow keys, 1-9 inputs into the cell, 0 clears the cell\\
Enter notes mode with 'n', same controls as insert mode, which you can return to using 'i'\\
I've only tested this with the default config of konsole, so the colors might look weird for you, feel free to fork and make fixes, just show me some love in your readme or somthing idk\\
Currently only supports hardcoded grids (`initialState` in `section .data`) but will be more betterer later\\
