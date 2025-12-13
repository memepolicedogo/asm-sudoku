%include "include/h.asm"
; int check_input(int x, int y, int val)
check_input:
	%define x qword [rbp+16]
	%define y qword [rbp+24]
	%define val qword [rbp+32]
	push	rbp
	mov	rbp, rsp
	; x and y from 0-8
	mov	rsi, row_0
	mov	rax, x
	; &row_0+x+(x*8) == &row_%[x]
	add	rsi, rax
	shl	rax, 3
	add	rsi, rax	; row_%[x]
.prep_loop:
	mov	rdi, val
	mov	rcx, 0
	mov	rax, val
	; check values
	; this loop works for all of the structures so we can reuse it for fun and profit
.loop:
	mov	al, byte [rsi+rcx]
	cmp	al,dil ; value at (x,y) == val
	je	.bad_input
	inc	rcx
	cmp	rcx, 9
	jne	.loop
	cmp	rsi, col_0
	jl	.get_col
	cmp	rsi, sqr_0_0
	jl	.get_sqr
	jmp	.good_input
.get_col:
	mov	rsi, col_0
	; Much the same as with row
	mov	rax, y
	add	rsi, rax
	shl	rax, 3
	add	rsi, rax	; col_%[x]
	jmp	.prep_loop
.get_sqr:
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
	add	rsi, 9
	cmp	rax, 6
	jl	.prep_loop
	add	rsi, 9
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
