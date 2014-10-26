[bits 64]

; === [ ELF file header ] ======================================================

ehdr:

something4:

; ELF classes.
ELFCLASS64 equ 2 ; 64-bit object

; Data encodings.
ELFDATA2LSB equ 1 ; 2's complement with little-endian encoding

; Object file types.
ET_EXEC equ 2 ; Executable file

; Architecture.
EM_X86_64 equ 62 ; AMD x86-64 architecture

  .ident:     ; Magic number and other info
    .ident.magic:   ; ELF magic number
	db 0x7F, "ELF"
    .ident.class:   ; File class
	db ELFCLASS64
    .ident.data:    ; Data encoding
	db ELFDATA2LSB
    .ident.version: ; ELF header version
	db 1
    .ident.pad:     ; Padding
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  .type:      ; Object file type
	dw ET_EXEC
  .machine:   ; Architecture
	dw EM_X86_64
  .version:   ; Object file version
	dd 1
  .entry:     ; Entry point virtual address
	dq BASE + text.start
  .phoff:     ; Program header table file offset
	dq phdr
  .shoff:     ; Section header table file offset
	dq 0
  .flags:     ; Processor-specific flags
	dd 0
  .ehsize:    ; ELF header size in bytes
	dw ehsize
  .phentsize: ; Program header table entry size
	dw phentsize
  .phnum:     ; Program header table entry count
	dw phnum
  .shentsize: ; Section header table entry size
	dw 0
  .shnum:     ; Section header table entry count
	dw 0
  .shstrndx:  ; Section header string table index
	dw 0

ehsize equ $ - ehdr

; === [/ ELF file header ] =====================================================

; === [ Program headers ] ======================================================

phdr:

; Segment types.
PT_LOAD    equ 1 ; Loadable program segment
PT_DYNAMIC equ 2 ; Dynamic linking information
PT_INTERP  equ 3 ; Program interpreter
PT_PHDR    equ 6 ; Entry for header table itself

; Segment flags.
PF_X equ 0x1 ; Segment is executable
PF_W equ 0x2 ; Segment is writable
PF_R equ 0x4 ; Segment is readable

; Base address
MB   equ 0x100000
BASE equ 4*MB

phdr_phdr:
  .type:   ; Segment type
	dd PT_PHDR
  .flags:  ; Segment flags
	dd PF_R
  .offset: ; Segment file offset
	dq phdr
  .vaddr:  ; Segment virtual address
	dq BASE + phdr
  .paddr:  ; Segment physical address
	dq BASE + phdr
  .filesz: ; Segment size in file
	dq phsize
  .memsz:  ; Segment size in memory
	dq phsize
  .align:  ; Segment alignment
	dq 0x8

phentsize equ $ - phdr

phdr_interp:
  .type:   ; Segment type
	dd PT_INTERP
  .flags:  ; Segment flags
	dd PF_R
  .offset: ; Segment file offset
	dq interp
  .vaddr:  ; Segment virtual address
	dq BASE + interp
  .paddr:  ; Segment physical address
	dq BASE + interp
  .filesz: ; Segment size in file
	dq interp_size
  .memsz:  ; Segment size in memory
	dq interp_size
  .align:  ; Segment alignment
	dq 0x1

phdr_2:
  .type:   ; Segment type
	dd PT_LOAD
  .flags:  ; Segment flags
	dd PF_R | PF_X
  .offset: ; Segment file offset
	dq something4
  .vaddr:  ; Segment virtual address
	dq BASE
  .paddr:  ; Segment physical address
	dq BASE
  .filesz: ; Segment size in file
	dq something4size
  .memsz:  ; Segment size in memory
	dq something4size
  .align:  ; Segment alignment
	dq 2*MB

phdr_3:
  .type:   ; Segment type
	dd PT_LOAD
  .flags:  ; Segment flags
	dd PF_R | PF_W
  .offset: ; Segment file offset
	dq something
  .vaddr:  ; Segment virtual address
	dq BASE + 2*MB + something
  .paddr:  ; Segment physical address
	dq BASE + 2*MB + something
  .filesz: ; Segment size in file
	dq somethingsize
  .memsz:  ; Segment size in memory
	dq somethingsize
  .align:  ; Segment alignment
	dq 2*MB

phdr_dynamic:
  .type:   ; Segment type
	dd PT_DYNAMIC
  .flags:  ; Segment flags
	dd PF_R | PF_W
  .offset: ; Segment file offset
	dq dynamic
  .vaddr:  ; Segment virtual address
	dq BASE + 2*MB + dynamic
  .paddr:  ; Segment physical address
	dq BASE + 2*MB + dynamic
  .filesz: ; Segment size in file
	dq dynamic_size
  .memsz:  ; Segment size in memory
	dq dynamic_size
  .align:  ; Segment alignment
	dq 0x8

phsize equ $ - phdr
phnum  equ phsize / phentsize

; === [/ Program headers ] =====================================================

; === [ Sections ] =============================================================

; --- [ .interp section ] ------------------------------------------------------

interp:

	db "/lib/ld64.so.1", 0

interp_size equ $ - interp

; --- [/ .interp section ] -----------------------------------------------------

; --- [ .dynsym section ] ------------------------------------------------------

dynsym:

; Symbol bindings.
STB_GLOBAL equ 1 ; Global symbol

; Symbol types.
STT_FUNC equ 2 ; Code object

; Symbol visibility.
STV_DEFAULT equ 0 ; Default visibility.

  .printf:
	dd dynstr.printf_off        ; name: Symbol name (string table offset)
	db STB_GLOBAL<<4 | STT_FUNC ; info: Symbol type and binding
	db STV_DEFAULT              ; other: Symbol visibility
	dw 0                        ; shndx: Section index
	dq 0                        ; value: Symbol value
	dq 0                        ; size: Symbol size

.entsize equ $ - dynsym

  .exit:
	dd dynstr.exit_off          ; name: Symbol name (string table offset)
	db STB_GLOBAL<<4 | STT_FUNC ; info: Symbol type and binding
	db STV_DEFAULT              ; other: Symbol visibility
	dw 0                        ; shndx: Section index
	dq 0                        ; value: Symbol value
	dq 0                        ; size: Symbol size

.printf_idx equ (.printf - dynsym) / .entsize
.exit_idx   equ (.exit - dynsym) / .entsize

; --- [/ .dynsym section ] -----------------------------------------------------

; --- [ .dynstr section ] ------------------------------------------------------

dynstr:

  .libc:
	db "libc.so.6", 0
  .printf:
	db "printf", 0
  .exit:
	db "exit", 0

.libc_off   equ .libc - dynstr
.printf_off equ .printf - dynstr
.exit_off   equ .exit - dynstr

; --- [/ .dynstr section ] -----------------------------------------------------

; --- [ .rela.plt section ] ----------------------------------------------------

rela_plt:

; Relocation types.
R_386_JMP_SLOT equ 7

  .printf:
	dq BASE + 2*MB + got_plt_printf           ; offset: Address
	dq dynsym.printf_idx<<32 | R_386_JMP_SLOT ; info: Relocation type and symbol index
	dq 0                                      ; addend: Addend

  .exit:
	dq BASE + 2*MB + got_plt_exit             ; offset: Address
	dq dynsym.exit_idx<<32 | R_386_JMP_SLOT   ; info: Relocation type and symbol index
	dq 0                                      ; addend: Addend

; --- [/ .rela.plt section ] ---------------------------------------------------

; --- [ .plt section ] ---------------------------------------------------------

plt:

  .resolve:
	push	QWORD [rel 2*MB + got_plt_1]
	jmp	[rel 2*MB + got_plt_2]

  .printf:
	jmp	[rel 2*MB + got_plt_printf]

  .resolve_printf:
	push	QWORD 0
	jmp	NEAR .resolve

  .exit:
	jmp	[rel 2*MB + got_plt_exit]

  .resolve_exit:
	push	QWORD 1
	jmp	NEAR .resolve

; --- [/ .plt section ] --------------------------------------------------------

; --- [ .text section ] --------------------------------------------------------

text:

  .start:
	mov	rdi, BASE + rodata.hello
	call	plt.printf
	mov	edi, 0
	call	plt.exit

; --- [/ .text section ] -------------------------------------------------------

; --- [ .rodata section ] ------------------------------------------------------

rodata:

  .hello:
	db "hello world", 10, 0

; --- [/ .rodata section ] -----------------------------------------------------

something4size equ $ - something4

something:

; --- [ .dynamic section ] -----------------------------------------------------

dynamic:

; Dynamic tags.
DT_NULL     equ 0  ; Marks the end of the dynamic array
DT_NEEDED   equ 1  ; String table offset of a required library
DT_PLTGOT   equ 3  ; Address of the PLT and/or GOT
DT_STRTAB   equ 5  ; Address of the string table
DT_SYMTAB   equ 6  ; Address of the symbol table
DT_JMPREL   equ 23 ; Address of the relocation entities of the PLT

  .libc:
	dq DT_NEEDED       ; tag: Dynamic entry type
	dq dynstr.libc_off ; val: Integer or address value

.entsize equ $ - dynamic

  .strtab:
	dq DT_STRTAB     ; tag: Dynamic entry type
	dq BASE + dynstr ; val: Integer or address value

  .symtab:
	dq DT_SYMTAB     ; tag: Dynamic entry type
	dq BASE + dynsym ; val: Integer or address value

  .pltgot:
	dq DT_PLTGOT             ; tag: Dynamic entry type
	dq BASE + 2*MB + got_plt ; val: Integer or address value

  .jmprel:
	dq DT_JMPREL       ; tag: Dynamic entry type
	dq BASE + rela_plt ; val: Integer or address value

  .null:
	dq DT_NULL ; tag: Dynamic entry type
	dq 0       ; val: Integer or address value

dynamic_size equ $ - dynamic

; --- [/ .dynamic section ] ----------------------------------------------------

; --- [ .got.plt section ] -----------------------------------------------------

got_plt:

got_plt_libc:
	dq BASE + 2*MB + dynamic.libc

got_pltentsize equ $ - got_plt

got_plt_1:
	dq 0

got_plt_2:
	dq 0

got_plt_printf:
	dq BASE + plt.resolve_printf

got_plt_exit:
	dq BASE + plt.resolve_exit

got_pltsize equ $ - got_plt

; --- [/ .got.plt section ] ----------------------------------------------------

somethingsize equ $ - something

; === [/ Sections ] ============================================================
