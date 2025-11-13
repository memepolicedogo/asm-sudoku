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
%macro printCode 1
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, %1Code
	mov	rdx, %1Len
	syscall
%endmacro
%macro restore 0
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, restoreCursorCode
	mov	rdx, restoreCursorLen
	syscall
%endmacro
%macro save 0
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, saveCursorCode
	mov	rdx, saveCursorLen
	syscall
%endmacro
%macro end 0
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, endCode
	mov	rdx, endLen
	syscall
	mov	byte [curr_x], 8
	mov	byte [curr_y], 8
%endmacro
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
	inc	byte [curr_y]
%endmacro
%macro up 0
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, upCode
	mov	rdx, upLen
	syscall
	dec	byte [curr_y]
%endmacro
%macro left 0
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, leftCode
	mov	rdx, leftLen
	syscall
	dec	byte [curr_x]
%endmacro
%macro right 0
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, rightCode
	mov	rdx, rightLen
	syscall
	inc	byte [curr_x]
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
		i_r0:	db 1,2,3,  4,5,6,  7,8,9
		i_r1:	db 2,0,0,  0,0,0,  0,0,0
		i_r2:	db 3,0,0,  0,0,0,  0,0,0
		i_r3:	db 4,0,0,  0,0,0,  0,0,0
		i_r4:	db 5,0,0,  0,0,0,  0,0,0
		i_r5:	db 6,0,0,  0,0,0,  0,0,0
		i_r6:	db 7,0,0,  0,0,0,  0,0,0
		i_r7:	db 8,0,0,  0,0,0,  0,0,0
		i_r8:	db 9,0,0,  0,0,0,  0,0,0
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
		n_r0:	dw 0,0,0,  0,0,0,  0,0,0
		n_r1:	dw 0,0,0,  0,0,0,  0,0,0
		n_r2:	dw 0,0,0,  0,0,0,  0,0,0
		n_r3:	dw 0,0,0,  0,0,0,  0,0,0
		n_r4:	dw 0,0,0,  0,0,0,  0,0,0
		n_r5:	dw 0,0,0,  0,0,0,  0,0,0
		n_r6:	dw 0,0,0,  0,0,0,  0,0,0
		n_r7:	dw 0,0,0,  0,0,0,  0,0,0
		n_r8:	dw 0,0,0,  0,0,0,  0,0,0
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
		db 32, 32 ; spacing
		mode:	db "I"
		db 32, 32 ; spacing
		notes:	db "                         "
		db 32, 32 ; spacing
		filled: db "00/81"
	toolbarLen	equ $-toolbar
	prepToolbarCode:
		db	ESC, "[20;0H"
	prepToolbarLen	equ $-prepToolbarCode
	clearMsgCode:
		db	ESC, "[2K"
	clearMsgLen	equ $-clearMsgCode
	prepMsgCode:
		db	ESC, "[21;0H"
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
	wrapDownCode:
		db ESC, "[16B"
	wrapDownLen	equ $-wrapDownCode
	wrapUpCode:
		db ESC, "[16A"
	wrapUpLen	equ $-wrapUpCode
	endCode:
		db ESC, "[18;35H"
	endLen		equ $-endCode
	homeCode:
		; back to origin of the board
		db ESC, "[2;3H"	; return to 0,0
	homeLen		equ $-homeCode
	downCode:
		; Down to next square
		db ESC, "[2B"	; Down 2 rows
	downLen		equ $-downCode
	upCode:
		; up to next square
		db ESC, "[2A"	; up 2 rows
	upLen		equ $-upCode
	postWriteCode:
		db ESC, "[1D"	; left 1 col
	postWriteLen		equ $-postWriteCode
	leftCode:
		; left to next square
		db ESC, "[4D"	; left 3 cols
	leftLen		equ $-leftCode
	rightCode:
		; right to next square
		db ESC, "[4C"	; right 3 cols
	rightLen	equ $-rightCode
	lineEndCode:
		db ESC, "[35G"
	lineEndLen	equ $-lineEndCode
	lineStartCode:
		db ESC, "[3G"
	lineStartLen	equ $-lineStartCode
	saveCursorCode:
		db ESC, "7"
	saveCursorLen	equ $-saveCursorCode
	restoreCursorCode:
		db ESC, "8"
	restoreCursorLen	equ $-restoreCursorCode
	enterBoldCode:
		db ESC, "[1m"
	enterBoldLen	equ $-enterBoldCode
	jumpCode:
		db ESC, "["
	jumpY:	db 0,0
		db ";"
	jumpX:	db 0,0
		db "H"
	jumpLen		equ $-jumpCode
	defmsg	insertMode, "Entered insert mode"
	defmsg	notesMode, "Entered notes mode"
	defmsg	winner, "You won! Press Enter to close."
	deferr	term_size, "Terminal is too small"
	deferr	bad_input, "An error occured while reading input"
	deferr	init_overwrite, "Can't write over inital values"

	og_termio:
		 c_iflag:	dd 0
		 c_oflag:	dd 0
		 c_cflag:	dd 0
		 c_lflag:	dd 0
		 c_line:	db 0
		 c_cc:		dq 0, 0, 0
	termio_len	equ $-og_termio
	new_termio:
		new_c_iflag:	dd 0
		new_c_oflag:	dd 0
		new_c_cflag:	dd 0
		new_c_lflag:	dd 0
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
	mov	eax, dword [new_c_iflag]
	and	eax, 4294965780; (IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON)
	mov	dword [new_c_iflag], eax
	mov	eax, dword [new_c_oflag]
	and	eax, 4294967294	  ; OPOST
	mov	dword [new_c_oflag], eax
	mov	eax, dword [new_c_lflag]
	and	eax, 4294934452	; ~(ICANON | ISIG | IEXTEN)
	mov	dword [new_c_lflag], eax
	mov	eax, dword [new_c_cflag]
	and	eax, 4294966991	; ~(CSIZE | PARENB)
	or	eax, 48	  ; CS8
	mov	dword [new_c_cflag], eax
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
	; Bold inital inputs
	printCode enterBold
	mov	r8, initialState
.populate_loop:
	cmp	r8, initialState+80
	je	.end_populate
	mov	r9b, byte [r8]
	inc	r8
	cmp	r9b, 0
	jne	.populate
	call	move_right
	jmp	.populate_loop
.populate:
	inc	byte [filledCount]
	add	r9b, 48
	mov	byte [replaceWith], r9b
	call	write_num
	call	move_right
	jmp	.populate_loop
.end_populate:
	; No longer bold
	printCode resetGraph
	home
	call	update_toolbar
	; Set values
	mov	byte [curr_x], 0
	mov	byte [targ_x], 0
	mov	byte [curr_y], 0
	mov	byte [targ_y], 0
main_loop:
	call	update_toolbar
	; Read input
	mov	qword [input_buff], 0
	mov	rax, 0
	mov	rdi, 0
	mov	rsi, input_buff
	mov	rdx, INBUFFSIZE
	syscall
	cmp	rax, 0
	jl	bad_input_error
	call	clear_msg
	; Possible inputs:
	; Number: 1-9
	; Command: ...
	; Move: arrow key/wasd
	cmp	byte [input_buff], ESC
	je	.check_arrow
	; Get char
	mov	r8b, byte [input_buff]
	; Check if num
	cmp	r8b, 49
	jl	bad_input_error
	cmp	r8b, 57
	jg	.check_char
	; Is num
	; Check mode
	cmp	byte [mode], 'I'
	je	.insert
	cmp	byte [mode], 'N'
	je	.note
	jmp	main_loop
.note:
	; Get value
	sub	r8b, 49
	mov	r9, 1
.notes_loop:
	cmp	r8b, 0
	je	.notes_end
	shl	r9, 1
	dec	r8b
	jmp	.notes_loop
.notes_end:
	;r9w stores the notes
	; Get current notes
	mov	r8, savedNotes
	xor	rax, rax
	mov	al, byte [curr_y]
	mov	rbx, 9
	mul	rbx
	shl	rax, 1
	add	r8, rax
	xor	rax, rax
	mov	al, byte [curr_x]
	shl	rax, 1
	add	r8, rax
	; e.g. if 1 and 2 are noted already and user inputs 3:
	; 000000000
	xor	word [r8], r9w
	jmp	main_loop


.insert:
	mov	byte [replaceWith], r8b
	; Check if square has starter number
	mov	r8, initialState
	xor	rax, rax
	mov	al, byte [curr_y]
	mov	rbx, 9
	mul	rbx
	add	r8, rax
	xor	rax, rax
	mov	al, byte [curr_x]
	add	r8, rax
	cmp	byte [r8], 0
	je	.valid_write
	call	init_overwrite_error
	jmp	main_loop
.valid_write:

	; Write number 
	call	write_num
	; Update stored state
	mov	r8, initialState
	xor	rax, rax
	mov	al, byte [curr_y]
	mov	rbx, 9
	mul	rbx
	add	r8, rax
	xor	rax, rax
	mov	al, byte [curr_x]
	add	r8, rax
	cmp	byte [r8], 0
	jne	.skip_count
	inc	byte [filledCount]
.skip_count:
	mov	r9b, byte [replaceWith]
	sub	r9b, 48
	mov	byte [r8], r9b
	call	win_check
	cmp	rax, 1
	je	win
	jmp	main_loop
.check_char:
	cmp	byte [input_buff], 'q'
	je	exit
	cmp	byte [input_buff], 'n'
	je	.switch_note
	cmp	byte [input_buff], 'i'
	je	.switch_input
.switch_note:
	; Enter note mode
	mov	byte [mode], 'N'
	call	mode_change
	jmp	main_loop
.switch_input:
	; enter insert mode
	mov	byte [mode], 'I'
	call	mode_change
	jmp	main_loop
.check_arrow:
	cmp	byte [input_buff+1], '['
	jne	main_loop
	xor	rax, rax
	mov	al, byte [input_buff+2]
	cmp	al, 'A'
	je	.up
	cmp	al, 'B'
	je	.down
	cmp	al, 'C'
	je	.right
	cmp	al, 'D'
	je	.left
	jmp	main_loop
.up:
	call	move_up
	jmp	main_loop
.down:
	call	move_down
	jmp	main_loop
.right:
	call	move_right
	jmp	main_loop
.left:
	call	move_left
	jmp	main_loop
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
global move_up
move_up:
	mov	al, byte [curr_y]
	cmp	al, 0
	je	.down
	up
	ret
.down:
	printCode wrapDown
	mov	byte [curr_y], 8
	ret
global move_down
move_down:
	mov	al, byte [curr_y]
	cmp	al, 8
	je	.up
	down
	ret
.up:
	printCode wrapUp
	mov	byte [curr_y], 0
	ret
	ret
global move_left
move_left:
	mov	al, byte [curr_x]
	cmp	al, 0
	jg	.move
	mov	al, byte [curr_y]
	cmp	al, 0
	jg	.up
	end
	ret
.up:
	up
	printCode lineEnd
	mov	byte [curr_x], 8
.move:
	left
	ret
global move_right
move_right:
	mov	al, byte [curr_x]
	cmp	al, 8
	jl	.move
	mov	al, byte [curr_y]
	cmp	al, 8
	jl	.down
	home
	ret
.down:
	down
	printCode lineStart
	mov	byte [curr_x], 0
	ret
.move:
	right
	ret
global draw_toolbar
draw_toolbar:
	save
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, prepToolbarCode
	mov	rdx, prepToolbarLen
	syscall
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, toolbar
	mov	rdx, toolbarLen
	syscall
	restore
	ret
global mode_change
mode_change:
	mov	al, byte [mode]
	cmp	al, 'I'
	je	.insert
	cmp	al, 'N'
	je	.notes
.insert:
	printmsg insertMode
	restore
	ret
.notes:
	printmsg notesMode
	restore
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
	restore
	ret
global prep_msg
prep_msg:
	save
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, prepMsgCode
	mov	rdx, prepMsgLen
	syscall
	ret
global prep_err
prep_err:
	save
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
	restore
	ret
global win_check
win_check:
	; TODO
	cmp	byte [filledCount], '8'
	jne	.no
.no:
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
	; Move cursor back over
	printCode postWrite
	ret
global jump_to
jump_to:
	; Jump to a given square
	; board starts at 0,0 goes to 8,8
	; Start from home
	home
	xor	rax, rax
	mov	al, byte [targ_y]
	cmp	al, 8
	jg	.bad_arg
	shr	rax, 1
	inc	rax
	mov	rbx, 10
	xor	rdx, rdx
	div	rbx
	add	rax, 48
	mov	byte [jumpY], al
	add	rdx, 48
	mov	byte [jumpY+1], dl
	mov	al, byte [targ_x]
	cmp	al, 8
	jg	.bad_arg
	shr	rax, 2
	add	rax, 3
	mov	rbx, 10
	xor	rdx, rdx
	div	rbx
	add	rax, 48
	mov	byte [jumpX], al
	add	rdx, 48
	mov	byte [jumpX+1], dl
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, jumpCode
	mov	rdx, jumpLen
	syscall
	; Cleanup
	mov	cl, byte [targ_y]
	mov	byte [curr_y], cl
	mov	byte [targ_y], 0
	mov	cl, byte [targ_y]
	mov	byte [curr_x], cl
	mov	byte [targ_x], 0
	ret
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
	xor	rdx, rdx
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
	shl	rax, 1
	add	r8, rax
	xor	rax, rax
	add	al, byte [curr_x]
	shl	rax, 1
	add	r8, rax
	mov	r9w, word [r8]
	mov	rax, notes
	test	r9w, 1
	jz	.no_one
	mov	byte [rax], '1'
	inc	rax
	jmp	.one
.no_one:
	mov	byte [rax], ' '
.one:
	add	rax, 2
	shr	r9, 1
	test	r9b, 1
	jz	.no_two
	mov	byte [rax], '2'
	inc	rax
	
	add	rax, 2
.no_two:
	shr	r9, 1
	test	r9b, 1
	jz	.no_three
	mov	byte [rax], '3'
	inc	rax
	
	add	rax, 2
.no_three:
	shr	r9, 1
	test	r9b, 1
	jz	.no_four
	mov	byte [rax], '4'
	inc	rax
	
	add	rax, 2
.no_four:
	shr	r9, 1
	test	r9b, 1
	jz	.no_five
	mov	byte [rax], '5'
	inc	rax
	
	add	rax, 2
.no_five:
	shr	r9, 1
	test	r9b, 1
	jz	.no_six
	mov	byte [rax], '6'
	inc	rax
	
	add	rax, 2
.no_six:
	shr	r9, 1
	test	r9b, 1
	jz	.no_seven
	mov	byte [rax], '7'
	inc	rax
	
	add	rax, 2
.no_seven:
	shr	r9, 1
	test	r9b, 1
	jz	.no_eight
	mov	byte [rax], '8'
	inc	rax
	
	add	rax, 2
.no_eight:
	shr	r9, 1
	test	r9b, 1
	jz	.no_nine
	mov	byte [rax], '9'
.no_nine:
	call draw_toolbar
	ret
; Errors
global init_overwrite_error
init_overwrite_error:
	printerr init_overwrite
	ret
global bad_input_error
bad_input_error:
	printerr bad_input
	jmp	exit
global term_size_error
term_size_error:
	printerr term_size
	jmp	exit
