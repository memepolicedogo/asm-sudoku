;-----Definitions-----;
; Call constants
%define TCGETS2		0x802C542A
%define TCSETSW2	0x402C542C
%define TIOCGWINSZ	0x5413
; Value constants
%define INBUFFSIZE	16
%define COL_MIN		100
%define ROW_MIN		50
; Char constants
%define ESC		0x1B
%define DEL		0x7F
%define TOP_RIGHT_CORNER	'┐'
%define TOP_LEFT_CORNER		'┌'
%define BOTTOM_RIGHT_CORNER	'┘'
%define BOTTOM_LEFT_CORNER	'└'
%define INSIDE_TOP_CORNER	'┬'
%define INSIDE_BOTTOM_CORNER	'┴'
%define OUTSIDE_RIGHT_CORNER	'┤'
%define OUTSIDE_LEFT_CORNER	'├'
%define HLINE			'─'
%define VLINE			'│'
%define CROSS			'┼'
%define SPACE			' '
%define SUDOKU_TOP		"┌───┬───┬───┰───┬───┬───┰───┬───┬───┐"
%define SUDOKU_MID		"│   │   │   ┃   │   │   ┃   │   │   │"
%define SUDOKU_CROSS		"├───┼───┼───╂───┼───┼───╂───┼───┼───┤"
%define SUDOKU_THIRD		"┝━━━┿━━━┿━━━╋━━━┿━━━┿━━━╋━━━┿━━━┿━━━┥"
%define SUDOKU_BOTTOM		"└───┴───┴───┸───┴───┴───┸───┴───┴───┘"
%define LINE_END		0x1B, "[1E"

; Macros
%macro home 0
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, homeCode
	mov	rdx, homeLen
	syscall
	mov	byte [curr_x], 0
	mov	byte [curr_y], 0
%endmacro
%macro down 0
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, downCode
	mov	rdx, downLen
	syscall
%endmacro
%macro up 0
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, upCode
	mov	rdx, upLen
	syscall
%endmacro
%macro left 0
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, leftCode
	mov	rdx, leftLen
	syscall
%endmacro
%macro right 0
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, rightCode
	mov	rdx, rightLen
	syscall
%endmacro
%macro defmsg	2
	%1Msg:	db %2, 0
	%1Len	equ $-%1Msg
%endmacro
%macro deferr	2
	%1Err:	db %2, 0
	%1Len	equ $-%1Err
%endmacro
%macro printmsg	1
	call	prep_msg
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, %1Msg
	mov	rdx, %1Len
	syscall
%endmacro
%macro printerr	1
	call	prep_err
	mov	rax, 1
	mov	rdi, 2
	mov	rsi, %1Err
	mov	rdx, %1Len
	syscall
	call	end_err
%endmacro
section .data
	initialState:
		i_r0:	db 0,0,0,  0,0,0,  0,0,0
		i_r1:	db 0,0,0,  0,0,0,  0,0,0
		i_r2:	db 0,0,0,  0,0,0,  0,0,0
		i_r3:	db 0,0,0,  0,0,0,  0,0,0
		i_r4:	db 0,0,0,  0,0,0,  0,0,0
		i_r5:	db 0,0,0,  0,0,0,  0,0,0
		i_r6:	db 0,0,0,  0,0,0,  0,0,0
		i_r7:	db 0,0,0,  0,0,0,  0,0,0
		i_r8:	db 0,0,0,  0,0,0,  0,0,0
	currentState:
		c_r0:	db 0,0,0,  0,0,0,  0,0,0
		c_r1:	db 0,0,0,  0,0,0,  0,0,0
		c_r2:	db 0,0,0,  0,0,0,  0,0,0
		c_r3:	db 0,0,0,  0,0,0,  0,0,0
		c_r4:	db 0,0,0,  0,0,0,  0,0,0
		c_r5:	db 0,0,0,  0,0,0,  0,0,0
		c_r6:	db 0,0,0,  0,0,0,  0,0,0
		c_r7:	db 0,0,0,  0,0,0,  0,0,0
		c_r8:	db 0,0,0,  0,0,0,  0,0,0
	savedNotes:
		n_r0:	db 0,0,0,  0,0,0,  0,0,0
		n_r1:	db 0,0,0,  0,0,0,  0,0,0
		n_r2:	db 0,0,0,  0,0,0,  0,0,0
		n_r3:	db 0,0,0,  0,0,0,  0,0,0
		n_r4:	db 0,0,0,  0,0,0,  0,0,0
		n_r5:	db 0,0,0,  0,0,0,  0,0,0
		n_r6:	db 0,0,0,  0,0,0,  0,0,0
		n_r7:	db 0,0,0,  0,0,0,  0,0,0
		n_r8:	db 0,0,0,  0,0,0,  0,0,0
	board:
		db SUDOKU_TOP, LINE_END
		db SUDOKU_MID, LINE_END
		db SUDOKU_CROSS, LINE_END
		db SUDOKU_MID, LINE_END
		db SUDOKU_CROSS, LINE_END
		db SUDOKU_MID, LINE_END
		db SUDOKU_THIRD, LINE_END
		db SUDOKU_MID, LINE_END
		db SUDOKU_CROSS, LINE_END
		db SUDOKU_MID, LINE_END
		db SUDOKU_CROSS, LINE_END
		db SUDOKU_MID, LINE_END
		db SUDOKU_THIRD, LINE_END
		db SUDOKU_MID, LINE_END
		db SUDOKU_CROSS, LINE_END
		db SUDOKU_MID, LINE_END
		db SUDOKU_CROSS, LINE_END
		db SUDOKU_MID, LINE_END
		db SUDOKU_BOTTOM, LINE_END
	boardSize	equ $-board
	toolbar:
		mode:	db "N"
		db 32, 32 ; spacing
		notes:	db "                         "
		db 32, 32 ; spacing
		filled: db "00/81"
	toolbarLen	equ $-toolbar
	prepToolbarCode:
		db	ESC, "[19;0H"
	prepToolbarLen	equ $-prepToolbarCode
	clearMsgCode:
		db	ESC, "[2K"
	clearMsgLen	equ $-clearMsgCode
	prepMsgCode:
		db	ESC, "[20;0H"
	prepMsgLen	equ $-prepMsgCode
	errStartCode:
		db	ESC, "[31m", "Error: "
	errStartLen	equ $-errStartCode
	resetGraphCode:
		db	ESC, "[0m"
	resetGraphLen	equ $-resetGraphCode
	replaceCode:
			db DEL
	replaceWith:	db 0
	replaceLen	equ $-replaceCode
	homeCode:
		; back to origin of the board
		db ESC, "[H"	; return to 0,0
		db ESC, "[1B"	; Down 1 row
		db ESC, "[2C"	; Right 2 col
	homeLen		equ $-homeCode
	downCode:
		; Down to next square
		db ESC, "[2B"	; Down 2 rows
	downLen		equ $-downCode
	upCode:
		; up to next square
		db ESC, "[2A"	; up 2 rows
	upLen		equ $-upCode
	leftCode:
		; left to next square
		db ESC, "[3D"	; left 3 cols
	leftLen		equ $-leftCode
	rightCode:
		; right to next square
		db ESC, "[3C"	; right 3 cols
	rightLen	equ $-rightCode
	test:
		db ESC, "[H"	; return to 0,0
		db ESC, "[1B"	; Down 1 row
		db ESC, "[2C"	; Right 2 col
		db DEL		; Delete char
		db "1"		; Replace with 1
	ts	equ $-test
	defmsg	winner, "You won! Press Enter to close."
	deferr	term_size, "Terminal is too small"
	deferr	bad_input, "An error occured while reading input"

	og_termio:
		 c_iflag:	dw 0
		 c_oflag:	dw 0
		 c_cflag:	dw 0
		 c_lflag:	dw 0
		 c_line:	db 0
		 c_cc:		dq 0, 0, 0
	termio_len	equ $-og_termio
	new_termio:
		new_c_iflag:	dw 0
		new_c_oflag:	dw 0
		new_c_cflag:	dw 0
		new_c_lflag:	dw 0
		new_c_line:	db 0
		new_c_cc:	dq 0, 0, 0
	clear:		db ESC, "[2J", ESC, "[3J", ESC, "[H"
	clearLen	equ $-clear
	filledCount:		db 0
section .bss
	curr_x:		resb 1
	curr_y:		resb 1
	targ_x:		resb 1
	targ_y:		resb 1
	expected_row:	resb 2
	expected_col:	resb 2
	winsize:
		ws_row:	resb 2
		ws_col:	resb 2
		; x/y pixel
		resb 4
	input_buff	resb INBUFFSIZE
section .text
global _start
_start:
	; Get current setup
	mov	rax, 16
	mov	rdi, 0
	mov	rsi, TCGETS2
	mov	rdx, og_termio
	syscall
	cmp	rax, 0
	jl	early_exit
	; Copy current setup to new var
	mov	rcx, termio_len
	mov	rsi, og_termio
	mov	rdi, new_termio
	rep movsb
	; Get current winsize
	mov	rax, 16
	mov	rdi, 0
	mov	rsi, TIOCGWINSZ
	mov	rdx, winsize
	syscall
	cmp	rax, 0
	jl	early_exit
	; Store winsize info
	mov	ax, [ws_row]
	cmp	ax, ROW_MIN
	jl	term_size_error
	mov	word [expected_row], ax
	mov	ax, [ws_col]
	cmp	ax, COL_MIN
	jl	term_size_error
	mov	word [expected_col], ax
	; Set options
	mov	ax, word [new_c_iflag]
	and	ax, 1515  ; (IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON)
	mov	word [new_c_iflag], ax
	mov	ax, word [new_c_oflag]
	and	ax, 1	  ; OPOST
	mov	word [new_c_oflag], ax
	mov	ax, word [new_c_lflag]
	and	ax, 32843 ; (ECHO | ECHONL | ICANON | ISIG | IEXTEN)
	mov	word [new_c_lflag], ax
	mov	ax, word [new_c_cflag]
	and	ax, 304	  ; (CSIZE | PARENB)
	or	ax, 48	  ; CS8
	mov	word [new_c_cflag], ax
	; Enter raw mode
	mov	rax, 16
	mov	rdi, 0
	mov	rsi, TCSETSW2
	mov	rdx, new_termio
	syscall
	cmp	rax, 0
	jl	exit
	call clear_screen
	; Draw board
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, board
	mov	rdx, boardSize
	syscall
	; Go to home
	home
	; Populate board
	mov	r8, initialState
.populate_loop:
	cmp	r8, initialState+80
	je	.end_populate
	mov	r9b, byte [r8]
	inc	r8
	cmp	r9b, 0
	jne	.populate
	jmp	.populate_loop
.populate:
	inc	byte [filledCount]
	add	r9b, 49
	mov	byte [replaceWith], r9b
	call	write_num
	jmp	.populate_loop
.end_populate:
	call	update_toolbar
	; Set values
	mov	byte [curr_x], 0
	mov	byte [targ_x], 0
	mov	byte [curr_y], 0
	mov	byte [targ_y], 0
main_loop:
	; Read input
	mov	rax, 0
	mov	rdi, 0
	mov	rsi, input_buff
	mov	rdx, INBUFFSIZE
	syscall
	cmp	rax, 0
	jl	bad_input_error
	; Possible inputs:
	; Number: 1-9
	; Command: ...
	; Move: arrow key/wasd
	; Input more than 1 byte must be an arrow or invalid
	cmp	rax, 1
	jg	.check_arrow
	; Get char
	mov	r8b, byte [input_buff]
	; Check if num
	cmp	r8b, 49
	jl	bad_input_error
	cmp	r8b, 57
	jg	.check_char
	; Is num
	mov	byte [replaceWith], r8b
	; Check if square has starter number
	mov	rax, initialState
	xor	rcx, rcx
	mov	cl, byte [curr_y]
	mul	rcx, 9
	add	rax, rcx
	xor	rcx, rcx
	mov	cl, byte [curr_x]
	add	rax, rcx
	cmp	byte [rax], 0
	jne	init_overwrite_error
	; Write number 
	call	write_num
	; Update stored state
	mov	rax, currentState
	xor	rcx, rcx
	mov	cl, byte [curr_y]
	mul	rcx, 9
	add	rax, rcx
	xor	rcx, rcx
	mov	cl, byte [curr_x]
	add	rax, rcx
	cmp	byte [rax], 0
	jne	.skip_count
	inc	byte [filledCount]
.skip_count:
	mov	r9b, byte [replaceWith]
	sub	r9b, 48
	mov	byte [rax], r9b
	call	win_check
	cmp	rax, 1
	je	win
	jmp	main_loop
.check_char:

.check_arrow:

win:
	printmsg winner
.loop:
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, input_buff
	mov	rdx, INBUFFSIZE
	syscall
	cmp	byte [input_buff], 10
	jne .loop
exit:

	; Restore terminal
	mov	rax, 16
	mov	rdi, 0
	; TCSETSW2
	mov	rsi, TCSETSW2
	mov	rdx, og_termio
	syscall
	call clear_screen
early_exit:
	; Exit
	mov	rax, 60
	mov	rsi, 0
	syscall

; Functions
global draw_toolbar
draw_toolbar:
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, prepToolbarCode
	mov	rdx, prepToolbarLen
	syscall
	ret
global update_toolbar
update_toolbar:
	; Check completion
	xor	rax, rax
	mov	al, byte [filledCount]
	cmp	rax, 10
	jg	.conv_tens
	add	rax, 48
	mov	byte [filled], 48
	mov	byte [filled+1], al
	jmp	.notes
.conv_tens:
	mov	rbx, 10
	div	rbx
	add	rax, 48
	add	rdx, 48
	mov	byte [filled], al
	mov	byte [filled+1], dl
.notes:
	; Check notes
	mov	r8, savedNotes
	xor	rax, rax
	mov	al, byte [curr_y]
	mov	rbx, 9
	mul	rbx
	add	r8, rax
	xor	rax, rax
	add	al, byte [curr_x]
	add	r8, rax
	mov	r9b, byte [r8]
	mov	rax, notes
	test	r9b, 1
	jz	.no_one
	mov	byte [rax], '1'
	inc	rax
	mov	byte [rax], ','
	add	rax, 2
.no_one:
	shl	r9, 1
	test	r9b, 1
	jz	.no_two
	mov	byte [rax], '2'
	inc	rax
	mov	byte [rax], ','
	add	rax, 2
.no_two:
	shl	r9, 1
	test	r9b, 1
	jz	.no_three
	mov	byte [rax], '3'
	inc	rax
	mov	byte [rax], ','
	add	rax, 2
.no_three:
	shl	r9, 1
	test	r9b, 1
	jz	.no_four
	mov	byte [rax], '4'
	inc	rax
	mov	byte [rax], ','
	add	rax, 2
.no_four:
	shl	r9, 1
	test	r9b, 1
	jz	.no_five
	mov	byte [rax], '5'
	inc	rax
	mov	byte [rax], ','
	add	rax, 2
.no_five:
	shl	r9, 1
	test	r9b, 1
	jz	.no_six
	mov	byte [rax], '6'
	inc	rax
	mov	byte [rax], ','
	add	rax, 2
.no_six:
	shl	r9, 1
	test	r9b, 1
	jz	.no_seven
	mov	byte [rax], '7'
	inc	rax
	mov	byte [rax], ','
	add	rax, 2
.no_seven:
	shl	r9, 1
	test	r9b, 1
	jz	.no_eight
	mov	byte [rax], '8'
	inc	rax
	mov	byte [rax], ','
	add	rax, 2
.no_eight:
	shl	r9, 1
	test	r9b, 1
	jz	.no_nine
	mov	byte [rax], '9'
.no_nine:
	call draw_toolbar
	ret
global return_cursor
return_cursor:
	mov	al, byte [curr_x]
	mov	byte [targ_x], al
	mov	al, byte [curr_y]
	mov	byte [targ_y], al
	call	jump_to
	ret
global clear_msg
clear_msg:
	; Get down to message level
	call prep_msg
	; Remove the text
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, clearMsgCode
	mov	rdx, clearMsgLen
	syscall
	; reset cursor position
	call	return_cursor
	ret
global prep_msg
prep_msg:
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, prepMsgCode
	mov	rdx, prepMsgLen
	syscall
	ret
global prep_err
prep_err:
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, prepMsgCode
	mov	rdx, prepMsgLen
	syscall
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, errStartCode
	mov	rdx, errStartLen
	syscall
	ret
global end_err
end_err:
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, resetGraphCode
	mov	rdx, resetGraphLen
	syscall
	ret
global win_check
win_check:
	; TODO
	mov	rax, 0
	ret
global remove_num
remove_num:
	mov byte [replaceWith], 32
global write_num
write_num:
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, replaceCode
	mov	rdx, replaceLen
	syscall
	ret
global jump_to
jump_to:
	; Jump to a given square
	; board starts at 0,0 goes to 8,8
	; Start from home
	home
	mov	cl, byte [targ_y]
	cmp	cl, 8
	jg	.bad_arg
.y_loop:
	cmp	cl, 0
	jle	.y_exit
	down
	dec	cl
	jmp	.y_loop
.y_exit:
	mov	cl, byte [targ_x]
	cmp	cl, 8
	jg	.bad_arg
.x_loop:
	cmp	cl, 0
	jle	.x_exit
	right
	dec	cl
	jmp	.x_loop
.x_exit:
	; Cleanup
	mov	cl, byte [targ_y]
	mov	byte [curr_y], cl
	mov	byte [targ_y], 0
	mov	cl, byte [targ_y]
	mov	byte [curr_x], cl
	mov	byte [targ_x], 0
	
.bad_arg:
	; Return home
	home
	mov	rax, -1
	ret
	
global clear_screen
clear_screen:
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, clear
	mov	rdx, clearLen
	syscall
	ret
; Errors
global init_overwrite_error
init_overwrite_error:
	printerr bad_input
	ret
global bad_input_error
bad_input_error:
	printerr bad_input
	jmp	exit
global term_size_error
term_size_error:
	printerr term_size
	jmp	exit
