extern printf
extern exit
global _start

[section .text]

_start:
	mov     rdi, hello   ; arg1, "hello world\n"
	call    printf       ; printf
	mov     rdi, 0       ; arg1, 42
	call    exit         ; exit
	mov     rax, 10
	ret

[section .rodata]

hello:
	db      "hello world", 10, 0
