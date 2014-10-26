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
	dq interpsize
  .memsz:  ; Segment size in memory
	dq interpsize
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
	dq dynamicsize
  .memsz:  ; Segment size in memory
	dq dynamicsize
  .align:  ; Segment alignment
	dq 0x8

phsize equ $ - phdr
phnum  equ phsize / phentsize

; === [/ Program headers ] =====================================================

; === [ Sections ] =============================================================

; --- [ .interp section ] ------------------------------------------------------

interp:
	db "/lib/ld64.so.1", 0

interpsize equ $ - interp

; --- [/ .interp section ] -----------------------------------------------------

; --- [ .dynsym section ] ------------------------------------------------------

dynsym:

; Symbol bindings.
STB_LOCAL  equ 0 ; Local symbol
STB_GLOBAL equ 1 ; Global symbol

; Symbol types.
STT_FUNC equ 2 ; Code object

; Symbol visibility.
STV_DEFAULT equ 0 ; Default visibility.

dynsym_0:
  .name:  ; Symbol name (string tbl index)
	dd dynstr.null_idx
  .info:  ; Symbol type and binding
	db STB_LOCAL<<4
  .other: ; Symbol visibility
	db STV_DEFAULT
  .shndx: ; Section index
	dw 0
  .value: ; Symbol value
	dq 0
  .size:  ; Symbol size
	dq 0

dynsymentsize equ $ - dynsym

dynsym_globals:
dynsym_globals_idx equ (dynsym_globals - dynsym) / dynsymentsize

dynsym_printf:
dynsym_printf_idx equ (dynsym_printf - dynsym) / dynsymentsize

  .name:  ; Symbol name (string tbl index)
	dd dynstr.printf_idx
  .info:  ; Symbol type and binding
	db STB_GLOBAL<<4 | STT_FUNC
  .other: ; Symbol visibility
	db STV_DEFAULT
  .shndx: ; Section index
	dw 0
  .value: ; Symbol value
	dq 0
  .size:  ; Symbol size
	dq 0

dynsym_exit:
dynsym_exit_idx equ (dynsym_exit - dynsym) / dynsymentsize

  .name:  ; Symbol name (string tbl index)
	dd dynstr.exit_idx
  .info:  ; Symbol type and binding
	db STB_GLOBAL<<4 | STT_FUNC
  .other: ; Symbol visibility
	db STV_DEFAULT
  .shndx: ; Section index
	dw 0
  .value: ; Symbol value
	dq 0
  .size:  ; Symbol size
	dq 0

dynsymsize equ $ - dynsym

; --- [/ .dynsym section ] -----------------------------------------------------

; --- [ .dynstr section ] ------------------------------------------------------

dynstr:

  .null:
	db 0
  .libc:
	db "libc.so.6", 0
  .exit:
	db "exit", 0
  .printf:
	db "printf", 0

.null_idx   equ .null - dynstr
.libc_idx   equ .libc - dynstr
.exit_idx   equ .exit - dynstr
.printf_idx equ .printf - dynstr

dynstrsize equ $ - dynstr

; --- [/ .dynstr section ] -----------------------------------------------------

; --- [ .rela.plt section ] ----------------------------------------------------

rela_plt:

; Relocation types.

R_386_JMP_SLOT equ 7

rela_plt_printf:
  .offset: ; Address
	dq BASE + 2*MB + got_plt_printf
  .info:   ; Relocation type and symbol index
	dq dynsym_printf_idx<<32 | R_386_JMP_SLOT
  .addend: ; Addend
	dq 0

rela_pltentsize equ $ - rela_plt

rela_plt_exit:
  .offset: ; Address
	dq BASE + 2*MB + got_plt_exit
  .info:   ; Relocation type and symbol index
	dq dynsym_exit_idx<<32 | R_386_JMP_SLOT
  .addend: ; Addend
	dq 0

rela_pltsize equ $ - rela_plt

; --- [/ .rela.plt section ] ---------------------------------------------------

; --- [ .plt section ] ---------------------------------------------------------

plt:

plt_0:
	push	QWORD [rel 2*MB + got_plt_1]
	jmp	[rel 2*MB + got_plt_2]
; nopl	0x0(%rax)
	db 0x0F, 0x1F, 0x40, 0x00

pltentsize equ $ - plt

plt_printf:
	jmp	[rel 2*MB + got_plt_printf]

.resolve:
	push	QWORD 0
	jmp	NEAR plt_0

plt_exit:
	jmp	[rel 2*MB + got_plt_exit]

.resolve:
	push	QWORD 1
	jmp	NEAR plt_0

pltsize equ $ - plt

; --- [/ .plt section ] --------------------------------------------------------

; --- [ .text section ] --------------------------------------------------------

text:

  .start:
	mov	rdi, BASE + hello
	call	plt_printf
	mov	edi, 0
	call	plt_exit

textsize equ $ - text

; --- [/ .text section ] -------------------------------------------------------

; --- [ .rodata section ] ------------------------------------------------------

rodata:

hello:
	db "hello world", 10, 0

rodatasize equ $ - rodata

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

dyn_libc:
  .tag: ; Dynamic entry type
	dq DT_NEEDED
  .val: ; Integer or address value
	dq dynstr.libc_idx

dynentsize equ $ - dynamic

dyn_strtab:
  .tag: ; Dynamic entry type
	dq DT_STRTAB
  .val: ; Integer or address value
	dq BASE + dynstr

dyn_symtab:
  .tag: ; Dynamic entry type
	dq DT_SYMTAB
  .val: ; Integer or address value
	dq BASE + dynsym

dyn_pltgot:
dyn_pltgot_idx equ (dyn_pltgot - dynamic) / dynentsize
  .tag: ; Dynamic entry type
	dq DT_PLTGOT
  .val: ; Integer or address value
	dq BASE + 2*MB + got_plt

dyn_jmprel:
  .tag: ; Dynamic entry type
	dq DT_JMPREL
  .val: ; Integer or address value
	dq BASE + rela_plt

dyn_null:
  .tag: ; Dynamic entry type
	dq DT_NULL
  .val: ; Integer or address value
	dq 0

dynamicsize equ $ - dynamic

; --- [/ .dynamic section ] ----------------------------------------------------

; --- [ .got.plt section ] -----------------------------------------------------

got_plt:

got_plt_libc:
	dq BASE + 2*MB + dyn_libc.tag

got_pltentsize equ $ - got_plt

got_plt_1:
	dq 0

got_plt_2:
	dq 0

got_plt_printf:
	dq BASE + plt_printf.resolve

got_plt_exit:
	dq BASE + plt_exit.resolve

got_pltsize equ $ - got_plt

; --- [/ .got.plt section ] ----------------------------------------------------

somethingsize equ $ - something

; === [/ Sections ] ============================================================
