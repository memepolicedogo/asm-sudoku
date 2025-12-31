%include "include/h.asm"
%ifdef DEBUG
section .data
	rowMsg:		db "Starting row check",10
	rowMsgLen	equ $-rowMsg
	colMsg:		db "Starting column check",10
	colMsgLen	equ $-colMsg
	sqrMsg:		db "Starting square check",10
	sqrMsgLen	equ $-sqrMsg
	cellMsg:	db "cmp "
	cellSrc:	db "0, "
	cellDst:	db "0",10
	cellMsgLen	equ $-cellMsg
	evilLen		equ $-cellSrc
	locationMsg:	db "Checking at "
	locationLen	equ $-locationMsg
section .text
%endif
; int check_input(int x, int y, int val)
check_input:
	%define x qword [rbp+16]
	%define y qword [rbp+24]
	%define val qword [rbp+32]
	push	rbp
	mov	rbp, rsp
	%ifdef DEBUG;{
	mov	rax, x
	mov	byte [cellSrc], al
	mov	rax, y
	mov	byte [cellDst], al
	add	byte [cellSrc], 48
	add	byte [cellDst], 48
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, locationMsg
	mov	rdx, locationLen
	syscall
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, cellSrc
	mov	rdx, evilLen
	syscall
	%endif;}
	; x and y from 0-8
	mov	rax, y
	; &row_0+y+(y*8) == &row_%[y]
	mov	rsi, 0
	add	rsi, rax
	shl	rax, 3
	add	rsi, rax	; offset index
	shl	rsi, 3		; *8 bc item width is 8 bytes
	add	rsi, row_0	; row_0+offset bytes
	%ifdef DEBUG;{
	push	rcx
	push	rax
	push	rdi
	push	rsi
	push	rdx
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, rowMsg
	mov	rdx, rowMsgLen
	syscall
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
	pop	rcx
	%endif;}
.prep_loop:
	mov	rdi, val
	mov	rcx, 0
	mov	rax, val
	; check values
	; this loop works for all of the structures so we can reuse it for fun and profit
.loop:
	mov	rax, qword [rsi+rcx]
	mov	al, byte [rax]
	%ifdef DEBUG;{
	mov	byte [cellSrc], al
	mov	byte [cellDst], dil
	add	byte [cellSrc], 48
	add	byte [cellDst], 48
	push	rcx
	push	rax
	push	rdi
	push	rsi
	push	rdx
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, cellMsg
	mov	rdx, cellMsgLen
	syscall
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
	pop	rcx
	%endif;}
	cmp	al,dil ; value at (x,y) == val
	je	.bad_input
	add	rcx, 8
	cmp	rcx, 9*8
	jne	.loop
	cmp	rsi, col_0
	jl	.get_col
	cmp	rsi, sqr_0_0
	jl	.get_sqr
	jmp	.good_input
.get_col:
	%ifdef DEBUG;{
	push	rcx
	push	rax
	push	rdi
	push	rsi
	push	rdx
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, colMsg
	mov	rdx, colMsgLen
	syscall
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
	pop	rcx
	%endif;}
	mov	rsi, 0
	; Much the same as with row
	mov	rax, x
	add	rsi, rax
	shl	rax, 3
	add	rsi, rax	; col_%[x]
	shl	rsi, 3
	add	rsi, col_0
	jmp	.prep_loop
.get_sqr:
	%ifdef DEBUG;{
	push	rcx
	push	rax
	push	rdi
	push	rsi
	push	rdx
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, sqrMsg
	mov	rdx, sqrMsgLen
	syscall
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
	pop	rcx
	%endif;}
	mov	rax, y
	cmp	rax, 3
	jl	.y_0
	cmp	rax, 6
	jl	.y_1
	jmp	.y_2
.y_0:
	mov	rsi, sqr_0_0
	jmp	.x
.y_1:
	mov	rsi, sqr_0_1
	jmp	.x
.y_2:
	mov	rsi, sqr_0_2
	jmp	.x
.x:
	mov	rax, x
	cmp	rax, 3
	jl	.prep_loop
	add	rsi, 9*8
	cmp	rax, 6
	jl	.prep_loop
	add	rsi, 9*8
	jmp	.prep_loop
.bad_input:
	mov	rax, -1
	jmp	.exit
.good_input:
	mov	rax, 1
	jmp	.exit
.exit:
	mov	rsp, rbp
	pop	rbp
	ret
	%undef x
	%undef y
	%undef val
