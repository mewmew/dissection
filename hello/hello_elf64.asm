extern printf
extern exit
global _start

[section .text]

_start:
	mov     rdi, hello
	call    printf
	mov     rdi, 0
	call    exit
	mov     rax, 10
	ret

[section .rodata]

hello:
	db      "hello world", 10, 0
