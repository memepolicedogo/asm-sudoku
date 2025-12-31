%ifndef SUDOKU
	%define SUDOKU
	extern initialState
	%assign i 0
	%rep 9
	extern row_%[i]
	extern col_%[i]
	%assign i i+1
	%endrep
	%assign x 0
	%rep 3
		%assign y 0
		%rep 3
			extern sqr_%[x]_%[y]
		%assign y y+1
		%endrep
	%assign x x+1
	%endrep
	%undef x
	%undef y
	%undef i
	extern check_input
	extern gen_board
	extern filledCount
%endif
