; TODO
; lets make a new error for dis
; Highlight same num (DONE)- Highlight row/col for empty (NOT DONE)
; Active error checking
; Random board generation
; Save files (also would allow dynamic board loading)

;-----Definitions-----;
; Call constants
%define TCGETS2		0x802C542A
%define TCSETSW2	0x402C542C
%define TIOCGWINSZ	0x5413
; Value constants
%define INBUFFSIZE	16
%define FBUFFSIZE	512
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

; MACROS{
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
	mov	byte [index], 0
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
%macro defmsg	2+
	%1Msg:	db %2, 0
	%1Len	equ $-%1Msg
%endmacro
%macro deferr	2+
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
;}
section .data
	;BOARD{
	initialState:
		i_r0:	db 0,3,2,  9,7,5,  1,8,6
		i_r1:	db 1,9,8,  2,6,3,  4,7,5
		i_r2:	db 6,7,5,  4,1,8,  2,9,3
		i_r3:	db 5,6,9,  7,2,1,  3,4,8
		i_r4:	db 7,8,1,  3,5,4,  6,2,9
		i_r5:	db 2,4,3,  8,9,6,  7,5,1
		i_r6:	db 8,5,7,  6,3,2,  9,1,4
		i_r7:	db 3,2,4,  1,8,9,  5,6,7
		i_r8:	db 9,1,6,  5,4,7,  8,3,0
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
	endState:
	times 5 db 0
	sqr_0_0:	
		dq c_r0, c_r0+1, c_r0+2
		dq c_r1, c_r1+1, c_r1+2
		dq c_r2, c_r2+1, c_r2+2
	sqr_1_0:	
		dq c_r0+3, c_r0+4, c_r0+5
		dq c_r1+3, c_r1+4, c_r1+5
		dq c_r2+3, c_r2+4, c_r2+5
	sqr_2_0:	
		dq c_r0+6, c_r0+7, c_r0+8
		dq c_r1+6, c_r1+7, c_r1+8
		dq c_r2+6, c_r2+7, c_r2+8
	sqr_0_1:	
		dq c_r3, c_r3+1, c_r3+2
		dq c_r4, c_r4+1, c_r4+2
		dq c_r5, c_r5+1, c_r5+2
	sqr_1_1:	
		dq c_r3+3, c_r3+4, c_r3+5
		dq c_r4+3, c_r4+4, c_r4+5
		dq c_r5+3, c_r5+4, c_r5+5
	sqr_2_1:	
		dq c_r3+6, c_r3+7, c_r3+8
		dq c_r4+6, c_r4+7, c_r4+8
		dq c_r5+6, c_r5+7, c_r5+8
	sqr_0_2:	
		dq c_r6, c_r6+1, c_r6+2
		dq c_r7, c_r7+1, c_r7+2
		dq c_r8, c_r8+1, c_r8+2
	sqr_1_2:	
		dq c_r6+3, c_r6+4, c_r6+5
		dq c_r7+3, c_r7+4, c_r7+5
		dq c_r8+3, c_r8+4, c_r8+5
	sqr_2_2:	
		dq c_r6+6, c_r6+7, c_r6+8
		dq c_r7+6, c_r7+7, c_r7+8
		dq c_r8+6, c_r8+7, c_r8+8
	sqr_end:
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
	;}
	toolbar:
		db 32, 32 ; spacing
		mode:	db "I"
		db 32, 32 ; spacing
		notes:	db "                         "
		notesLen	equ $-notes
		db 32, 32 ; spacing
		filled: db "00/81"
	toolbarLen	equ $-toolbar
	;CODES{
	highlightCode:
		db	ESC, "[30;47m"
	highlightLen	equ $-highlightCode
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
		db ESC, "[1m", ESC, "[34m"
	enterBoldLen	equ $-enterBoldCode
	jumpCode:
		db ESC, "["
	jumpY:	db 0,0
		db ";"
	jumpX:	db 0,0
		db "H"
	jumpLen		equ $-jumpCode
	;}
	defmsg	insertMode, "Entered insert mode"
	defmsg	notesMode, "Entered notes mode"
	defmsg	no, "Not quite!"
	defmsg	winner, "You won! Press Enter to close."
	deferr	bad_dev, "The developer of this program did something wrong",10
	deferr	no_open, "Failed to open the given file",10
	deferr	no_load, "Invalid save file",10
	deferr	bad_args, "Invalid argument(s)",10
	deferr	term_size, "Terminal is too small",10
	deferr	bad_input, "An error occured while reading input"
	deferr	init_overwrite, "Can't write over inital values"
	;UTIL{
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
	;}
	clear:		db ESC, "[2J", ESC, "[3J", ESC, "[H"
	clearLen	equ $-clear
	filledCount:		db 0
	index:			db 0
	spaces:		times 32 db 32
	in_game:	db 0
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
	f_buff		resb FBUFFSIZE
	arg_c		resq 1
	curr_opt	resb 1
section .text
;INIT{
global _start
_start:
	; Get current setup
	mov	rax, 16
	mov	rdi, 0
	mov	rsi, TCGETS2
	mov	rdx, og_termio
	syscall
	cmp	rax, 0
	jl	exit
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
	jl	exit
	; Store winsize info
	mov	ax, [ws_row]
	cmp	ax, ROW_MIN
	jl	term_size_error
	mov	word [expected_row], ax
	mov	ax, [ws_col]
	cmp	ax, COL_MIN
	jl	term_size_error
	mov	word [expected_col], ax
	; Handle args
handle_args:
	pop	rax
	mov	qword [arg_c], rax
	cmp	rax, 1
	je	.no_args
	pop	rax
.clear_arg:
	inc	rax
	cmp	byte [rax], 0
	jne	.clear_arg
.arg_start:
	dec	qword [arg_c]
	cmp	qword [arg_c], 0
	je	.no_args
	inc	rax
	cmp	byte [rax], '-'
	je	.parse_opt
	jne	.parse_val
.parse_val:
	; Check related opt
	xor	r8, r8
	mov	r8b, byte [curr_opt]
	; If no related opt
	cmp	r8b, 0
	je	bad_args_error
	; Load save
	cmp	r8b, 's'
	je	.save_file_name
	; Implicit deny
	call	bad_args_error
	; Handle value accordingly
.save_file_name:
	; Current arg should be the name/path of/to a save file
	; push current arg_v value to the stack since we're using rax for a syscall
	push	rax
	; sys_open
	mov	rax, 2
	pop	rdi
	push	rdi
	mov	rsi, 0
	mov	rdx, 0 ; read only
	syscall
	cmp	rax, 0
	jl	no_open_error
	; rax holds a fptr for the save file, try to load it
	call	load_save
	; Once again if rax is negative there was an error
	cmp	rax, 0
	jl	no_load_error
	; Otherwise the file was loaded successfully and we can close it 
	; rax should have fd
	mov	rdi, rax
	mov	rax, 3 ; sys_close
	syscall
	cmp	rax, 0
	jl	bad_dev_error
	; restore arg_v
	pop	rax
	; Clear curr_opt
	mov	byte [curr_opt], 0
	jmp	.clear_arg
.parse_opt:
	inc	rax
	cmp	byte [rax], '-'
	jne	.one_tack
	; Handle long-name args
.one_tack:
	; Handle single char args
	xor	r8, r8
	mov	r8b, byte [rax]
	; cmp	r8b, '{option_char}'
	; je	.option
	; -s: load save file
	cmp	r8b, 's'
	je	.load_save
	call	bad_args_error
.load_save:
	mov	byte [curr_opt], 's'
	jmp	.clear_arg
.no_args:
	; If arg parsing ended while an option was waiting on a value, the args are bad
	cmp	byte [curr_opt], 0
	je	init
	call	bad_args_error
init:
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
	; Set in_game
	mov	byte [in_game], 1
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
	;}
	;MAIN{
main_loop:
	call	update_toolbar
	call	highlight
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
	cmp	r8b, 48
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
	sub	r8b, 48
	cmp	r8b, 0
	jne	.notes_cont
	mov	r8, savedNotes
	xor	rax, rax
	mov	al, byte [index]
	shl	rax, 1
	add	r8, rax
	mov	word [r8], 0
	jmp	main_loop
.notes_cont:
	dec	r8b
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
	mov	al, byte [index]
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
	mov	al, byte [index]
	add	r8, rax
	cmp	byte [r8], 0
	je	.valid_write
	call	init_overwrite_error
	jmp	main_loop
.valid_write:
	mov	r8b, byte [replaceWith]
	cmp	r8b, 48
	jne	.insert_cont
	call	remove_num
	jmp	main_loop
.insert_cont:
	; Update stored state
	mov	r8, currentState
	xor	rax, rax
	mov	al, byte [index]
	add	r8, rax
	cmp	byte [r8], 0
	jne	.skip_count
	inc	byte [filledCount]
.skip_count:
	mov	r9b, byte [replaceWith]
	sub	r9b, 48
	mov	byte [r8], r9b
	; Write number 
	call	write_num
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
	;}
win:
	call	update_toolbar
	printmsg winner
.loop:
	mov	qword [input_buff], 0
	mov	rax, 0
	mov	rdi, 0
	mov	rsi, input_buff
	mov	rdx, 1
	syscall
	cmp	byte [input_buff], 13
	jne .loop
exit:
	
	cmp	byte [in_game], 1
	jne	.early
	; Restore terminal
	mov	rax, 16
	mov	rdi, 0
	; TCSETSW2
	mov	rsi, TCSETSW2
	mov	rdx, og_termio
	syscall
	call clear_screen
	mov	byte [in_game], 0
.early:
	; Exit
	mov	rax, 60
	mov	rsi, 0
	syscall

; Functions
global load_save
; Where RAX is an open file descriptor
load_save:
	push	rax
	mov	rax, 0
	pop	rdi
	push	rdi
	mov	rsi, f_buff
	mov	rdx, FBUFFSIZE
	syscall
	cmp	rax, 0
	jl	.read_err
	cmp	rax, FBUFFSIZE
	jge	.size_err
	; get the end of the jit
	add	rax, f_buff
	push	rax
	xor	r8,r8
	; get the first char
	mov	r8b, byte [rsi]
	cmp	r8b, '<'
	jne	.bad_file_err
	inc	rsi
	mov	r8b, byte [rsi]
	; First section should be version
	cmp	r8b, 'V'
	jne	.bad_file_err
	; Check version number
	inc	rsi
	mov	r8w, word [rsi]
	cmp	r8w, '1>' ; We only have version 1 currently
	je	.load_ver_1
	jmp	.bad_version_err
.load_ver_1:
	add	rsi, 2 ; gets passed version section
	mov	r8b, byte [rsi]
	cmp	r8b, 10 ; is newline
	jne	.v1_new_sec
	inc	rsi
.v1_new_sec:
	; get start of next section
	pop	rax
	cmp	rsi, rax	; are we at the end
	jge	.loaded
	push	rax
	mov	r8w, word [rsi]
	add	rsi, 2 ; get to start of data
	cmp	r8w, '<I'
	je	.v1_i
	cmp	r8w, '<B'
	je	.v1_b
	cmp	r8w, '<N'
	je	.v1_n
	jmp	.bad_file_err
.v1_i:
	mov	rcx, 81
	mov	rdi, initialState
	rep	movsb
	cmp	byte [rsi], '>'
	jne	.bad_file_err
	inc	rsi
	cmp	byte [rsi], 10
	jne	.v1_new_sec
	inc	rsi
	jmp	.v1_new_sec
.v1_b:
	mov	rcx, 81
	mov	rdi, currentState
	rep	movsb
	cmp	byte [rsi], '>'
	jne	.bad_file_err
	inc	rsi
	cmp	byte [rsi], 10
	jne	.v1_new_sec
	inc	rsi
	jmp	.v1_new_sec
.v1_n:
	mov	rcx, 81
	mov	rdi, savedNotes
	rep	movsw
	cmp	byte [rsi], '>'
	jne	.bad_file_err
	inc	rsi
	cmp	byte [rsi], 10
	jne	.v1_new_sec
	inc	rsi
	jmp	.v1_new_sec
	jmp	.v1_new_sec


.loaded:
	pop	rax
	ret
.size_err:
	pop	rdx
	mov	rax, -90
.read_err:
	pop	rdx
	ret
.bad_file_err:
	pop	rdx
	pop	rdx
	mov	rax, -22
	ret
.bad_version_err:
	pop	rdx
	pop	rdx
	mov	rax, -1
	ret
global highlight
highlight:
	; Save cursor
	save
	; Save current x and y
	xor	rdx, rdx
	mov	dl, byte [curr_x]
	push	rdx
	mov	dl, byte [curr_y]
	push	rdx
	; Get current value
	mov	rax, currentState
	xor	rdx, rdx
	mov	dl, byte [index]
	push	rdx	; save current index
	add	rax, rdx
	xor	r8, r8
	mov	r8b, byte [rax]
	cmp	r8b, 0
	je	.zero
	; Iterate through the board and highlight matches
	home
.loop:
	mov	rax, currentState
	pop	rdi
	push	rdi
	cmp	dil, byte [index]
	jne	.cont
	jmp	.iter
.cont:
	xor	rdi, rdi
	mov	dil, byte [index]
	; value therein
	mov	sil, [rax+rdi]
	; is the number 0?
	cmp	sil, 0
	je	.iter
	; store value
	push	rsi
	; is the number the same?
	cmp	sil, r8b
	je	.color
	jne	.clean
	; Clean remove any old highlighting
.color:
	; Write control code
	printCode highlight
.clean:
	mov	rax, initialState
	xor	rdi, rdi
	mov	dil, byte [index]
	mov	sil, byte [rax+rdi]
	cmp	sil, 0
	je	.no_bold
	printCode enterBold
.no_bold:
	; Clear cell
	call	remove_num
	; Write back number
	pop	rsi
	add	sil, 48
	mov	byte [replaceWith], sil
	call	write_num
	; Clear formating
	printCode resetGraph
.iter:
	call	move_right
	cmp	byte [index], 0
	jne	.loop
	pop	rdx
	mov	byte [index], dl
	pop	rdx
	mov	byte [curr_y], dl
	pop	rdx
	mov	byte [curr_x], dl
	restore
	ret
	; If current is 0 highlight row and col
.zero:
	save
	home
.clean_loop:
	mov	rax, currentState
	xor	rdx, rdx
	mov	dl, byte [index]
	add	rax, rdx
	mov	dl, byte [rax]
	cmp	dl, 0
	je	.no_clean
	push	rdx
	call	remove_num
	pop	rdx
	add	rdx, 48
	mov	byte [replaceWith], dl
	mov	rax, initialState
	xor	rdx, rdx
	mov	dl, byte [index]
	add	rax, rdx
	cmp	byte [rax], 0
	je	.z_no_bold
	printCode enterBold
.z_no_bold:
	call	write_num
	printCode resetGraph
.no_clean:
	call	move_right
	cmp	byte [index], 0
	jne	.clean_loop
	; We should have a clean board
	; get back to the main location
	restore
	pop	rdx
	mov	byte [index], dl
	pop	rdx
	mov	byte [curr_y], dl
	pop	rdx
	mov	byte [curr_x], dl
	ret
	; toggle with h?
; MOVES{
global move_up
move_up:
	mov	al, byte [curr_y]
	cmp	al, 0
	je	.down
	up
	sub	byte [index], 9
	ret
.down:
	printCode wrapDown
	mov	byte [curr_y], 8
	mov	byte [index], 72
	mov	al, byte [curr_x]
	add	byte [index], al
	ret
global move_down
move_down:
	mov	al, byte [curr_y]
	cmp	al, 8
	je	.up
	down
	add	byte [index], 9
	ret
.up:
	printCode wrapUp
	mov	byte [curr_y], 0
	mov	byte [index], 0
	mov	al, byte [curr_x]
	add	byte [index], al
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
	mov	byte [index], 80
	ret
.up:
	up
	printCode lineEnd
	mov	byte [curr_x], 8
	dec	byte [index]
	ret
.move:
	left
	dec	byte [index]
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
	mov	byte [index], 0
	ret
.down:
	down
	printCode lineStart
	mov	byte [curr_x], 0
	inc	byte [index]
	ret
.move:
	right
	inc	byte [index]
	ret
;}
;TOOLBAR{
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
	; Clear notes
	mov	rcx, notesLen
	mov	rsi, spaces
	mov	rdi, notes
	rep movsb
	test	r9w, 1
	jz	.no_one
	mov	byte [rax], '1'
	inc	rax
	
	mov	byte [rax], ' '
	add	rax, 2
.no_one:
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
	cmp	byte [in_game], 1
	jne	.ret
	save
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, prepMsgCode
	mov	rdx, prepMsgLen
	syscall
.ret:
	ret
global prep_err
prep_err:
	cmp	byte [in_game], 1
	jne	.ret
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
.ret:
	ret
global end_err
end_err:
	cmp	byte [in_game], 1
	jne	.ret
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, resetGraphCode
	mov	rdx, resetGraphLen
	syscall
	restore
.ret:
	ret
;}
;WIN{
global win_check
win_check:
	cmp	byte [filledCount], 81
	jne	.no
	; Actually check
	mov	rax, currentState
	; r9w holds the state
	mov	r9w, 0
	; rcx counter
	mov	rcx, 0
.row_loop:
	xor	r8, r8
	mov	r8b, [rax+rcx]
	mov	r10w, 1
	dec	r8b
.row_shift_loop:
	cmp	r8b, 0
	je	.row_shift_end
	shl	r10w, 1
	dec	r8b
	jmp	.row_shift_loop
.row_shift_end:
	xor	r9w, r10w
	inc	rcx
	cmp	rcx, 9
	jl	.row_loop
	cmp	r9w, 511
	jne	.no
	xor	r9, r9
	add	rax, 9
	cmp	rax, endState
	je	.checked_rows
	mov	rcx, 0
	jmp	.row_loop
.checked_rows:
	mov	rax, currentState
	mov	rcx, 0
.col_loop:
	xor	r8, r8
	mov	r8b, [rax+rcx]
	mov	r10w, 1
	dec	r8b
.col_shift_loop:
	cmp	r8b, 0
	je	.col_shift_end
	shl	r10w, 1
	dec	r8b
	jmp	.col_shift_loop
.col_shift_end:
	xor	r9w, r10w
	add	rcx, 9
	cmp	rcx, 81
	jl	.col_loop
	cmp	r9w, 511
	jne	.no
	xor	r9, r9
	add	rax, 1
	cmp	rax, c_r1
	jge	.checked_cols
	mov	rcx, 0
	jmp	.col_loop
.checked_cols:

	mov	rax, sqr_0_0
	mov	rcx, 0
.sqr_loop:
	mov	r11, qword [rax+rcx]
	mov	r8b, [r11]
	mov	r10w, 1
	dec	r8b
.sqr_shift_loop:
	cmp	r8b, 0
	je	.sqr_shift_end
	shl	r10w, 1
	dec	r8b
	jmp	.sqr_shift_loop
.sqr_shift_end:
	xor	r9w, r10w
	add	rcx, 8
	cmp	rcx, 72
	jl	.sqr_loop
	cmp	r9w, 511
	jne	.no
	xor	r9, r9
	add	rax, rcx
	cmp	rax, sqr_end
	jge	.checked_sqrs
	mov	rcx, 0
	jmp	.sqr_loop
.checked_sqrs:
	; TODO Squares
	mov	rax, 1
	ret
.no:
	cmp	byte [filledCount], 81
	je	.print_msg
	mov	rax, 0
	ret
.print_msg:
	printmsg no
	mov	rax, 0
	ret
;}
;WRITE{
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
	; Update stored jit
	mov	rax, currentState
	push	r8
	xor	r8, r8
	mov	r8b, byte [index]
	add	rax, r8
	mov	r8b, byte [replaceWith]
	cmp	r8b, 32
	jne	.non_zero
	mov	byte [rax], 0
	pop	r8
	ret
.non_zero:
	sub	r8b, 48
	mov	byte [rax], r8b
	pop	r8
	ret
global clear_screen
clear_screen:
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, clear
	mov	rdx, clearLen
	syscall
	ret
;}
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
global no_load_error
no_load_error:
	printerr no_load
	jmp	exit
global no_open_error
no_open_error:
	printerr no_open
	jmp	exit
global bad_args_error
bad_args_error:
	printerr bad_args
	jmp	exit
global bad_dev_error
bad_dev_error:
	printerr bad_dev
	jmp	exit
