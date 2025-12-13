%include "include/h.asm"
%define MAX_TRIES 250
%define BOARD_LEN 81
%define RAND_SIZE MAX_TRIES*BOARD_LEN*3; three bytes per grab-bag
section .data
	rand_file	db "/dev/urandom",0
section .text
; int gen_board(int square_count);
gen_board:
	%define count qword [rbp+16]
	%define tries qword [rbp-8]
	push	rbp
	mov	rbp, rsp
	sub	rsp, 8
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
	push	rsi
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
	; check if value is acceptable
	call	check_input
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
	mov	byte [rdi], al
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
