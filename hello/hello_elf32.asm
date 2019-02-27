extern printf
extern exit
global _start

[section .text]

_start:
	push    hello    ; arg1, "hello world\n"
	call    printf   ; printf
	add     esp, 4
	push    42       ; arg1, 42
	call    exit     ; exit
	add     esp, 4
	ret

[section .rodata]

hello:
	db      "hello world", 10, 0
