%include "include/h.asm"
%define MAX_TRIES 250
%define BOARD_LEN 81
%define RAND_SIZE MAX_TRIES*BOARD_LEN*3; three bytes per grab-bag
section .data
	rand_file:	db "/dev/urandom",0

	debugMsg:	db "Random: ("
	x:		db 0, ","
	y:		db 0, ") = "
	v:		db 0,10
	debugLen	equ $-debugMsg
section .text
; int gen_board(int square_count);
gen_board:
	%define count qword [rbp+16]
	%define tries qword [rbp-8]
	%define rand qword [rbp-16]
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	mov	tries, MAX_TRIES
	; If count is 0 quit with no error code
	mov	rax, 1
	mov	rcx, count
	cmp	rcx, 0
	je	.exit
	; Open /dev/random
	mov	rax, 2
	mov	rdi, rand_file
	mov	rsi, 0
	mov	rdx, 0	; Read only
	syscall
	cmp	rax, 0
	jl	.exit
	push	rax
	; mmap 
	mov	rax, 9
	mov	rdi, 0
	mov	rsi, RAND_SIZE
	mov	rdx, 3 ; PROT_READ | PROT_WRITE
	mov	r10, 0x22 ; MAP_PRIVATE | MAP_ANON
	mov	r9, 0
	mov	r8, 0
	syscall
	cmp	rax, 0
	jl	.close_exit
	; read from rand
	; store the new memory
	push	rax
	mov	rax, 0
	pop	rsi ; mem address
	pop	rdi ; fptr
	push	rsi
	push	rdi
	mov	rdx, RAND_SIZE
	syscall
	; close
	mov	rax, 3
	pop	rdi
	syscall
	; rsi = random data
	pop	rsi
	mov	rand, rsi
.gen_loop:
	cmp	count, 0
	je	.good_gen
	cmp	tries, 0
	je	.bad_gen
	; Starting conditions
	; x = 0, y = 0, v = 0
	; get value
	xor	rax, rax
	xor	rdx, rdx
	mov	al, byte [rsi]
	inc	rsi
	; v%9+1
	mov	rbx, 9
	div	rbx
	inc	rdx
	; rdx = v
	%ifdef DEBUG
	mov	byte [v], dl
	add	byte [v], 48
	%endif
	push	rdx
	
	; get y
	xor	rax, rax
	xor	rdx, rdx
	mov	al, byte [rsi]
	inc	rsi
	; y%9
	mov	rbx, 9
	div	rbx
	; rdx = y
	%ifdef DEBUG
	mov	byte [y], dl
	add	byte [y], 48
	%endif
	push	rdx

	; get x
	xor	rax, rax
	xor	rdx, rdx
	mov	al, byte [rsi]
	inc	rsi
	; x%9
	mov	rbx, 9
	div	rbx
	; rdx = x
	push	rdx
	mov	rand, rsi
	%ifdef DEBUG
	mov	byte [x], dl
	add	byte [x], 48
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, debugMsg
	mov	rdx, debugLen
	;syscall
	pop	rdx
	push	rdx
	%endif
	; check if value is acceptable
	call	check_input
	mov	rsi, rand
	; get the index
	pop	r8 ; x
	cmp	rax, 0
	jl	.bad_try
	mov	rax, r8
	; rdi=board
	mov	rdi, initialState
	add	rdi, rax
	pop	rax ; y
	xor	rdx, rdx
	mov	rbx, 9
	mul	rbx
	; rax has y offset
	add	rdi, rax
	pop	rax ; val
	; check if it's already got a value
	cmp	byte [rdi], 0
	jne	.bad_try
	; write val
	; Initial
	mov	byte [rdi], al
	; Current (needed for check_input)
	mov 	rbx, rdi
	sub	rbx, initialState
	; rbx has offset
	add	rbx, col_0
	mov	byte [rbx], al
	jmp	.good_try


.bad_try:
	dec	tries
	jmp	.gen_loop
.good_try:
	mov	tries, MAX_TRIES
	dec	count
	jmp	.gen_loop

.bad_gen:
	; return with error
	; unmap 
	mov	rax, 11
	pop	rdi
	mov	rsi, RAND_SIZE
	syscall
	mov	rax, -1
	add	rax, count
	jmp	.exit

.good_gen:
	; return with success
	; unmap 
	mov	rax, 11
	pop	rdi
	mov	rsi, RAND_SIZE
	syscall
	mov	rax, 1
	jmp	.exit

.exit:
	mov	rsp, rbp
	pop	rbp
	ret
.close_exit:
	mov	rax, 3
	pop	rdi
	syscall
	jmp	.exit
	%undef count
	%undef tries
