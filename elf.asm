[bits 64]

; === [ ELF file header ] ======================================================

; ___ [ Read-only data segment ] _______________________________________________

rodata_seg:

; ELF classes.
ELFCLASS64 equ 2 ; 64-bit object

; Data encodings.
ELFDATA2LSB equ 1 ; 2's complement with little-endian encoding

; Object file types.
ET_EXEC equ 2 ; Executable file

; Architecture.
EM_X86_64 equ 62 ; AMD x86-64 architecture

ehdr:

	db 0x7F, "ELF"               ; ident.magic: ELF magic number
	db ELFCLASS64                ; ident.class: File class
	db ELFDATA2LSB               ; ident.data: Data encoding
	db 1                         ; ident.version: ELF header version
	db 0, 0, 0, 0, 0, 0, 0, 0, 0 ; ident.pad: Padding
	dw ET_EXEC                   ; type: Object file type
	dw EM_X86_64                 ; machine: Architecture
	dd 1                         ; version: Object file version
	dq BASE_CODE + text.start    ; entry: Entry point virtual address
	dq phdr                      ; phoff: Program header table file offset
	dq 0                         ; shoff: Section header table file offset
	dd 0                         ; flags: Processor-specific flags
	dw .size                     ; ehsize: ELF header size in bytes
	dw phdr.entsize              ; phentsize: Program header table entry size
	dw phdr.count                ; phnum: Program header table entry count
	dw 0                         ; shentsize: Section header table entry size
	dw 0                         ; shnum: Section header table entry count
	dw 0                         ; shstrndx: Section header string table index

.size equ $ - ehdr

; === [/ ELF file header ] =====================================================

; === [ Program headers ] ======================================================

; Segment types.
PT_LOAD      equ 1          ; Loadable program segment
PT_DYNAMIC   equ 2          ; Dynamic linking information
PT_INTERP    equ 3          ; Program interpreter

; Segment flags.
PF_X equ 0x1 ; Segment is executable
PF_W equ 0x2 ; Segment is writable
PF_R equ 0x4 ; Segment is readable

; Base addresses.
BASE        equ 0x400000
PAGE        equ 0x1000
BASE_RODATA equ BASE
BASE_DATA   equ BASE + 1*PAGE
BASE_CODE   equ BASE + 2*PAGE

phdr:

; --- [ Interpreter program header ] -------------------------------------------

  .interp:
	dd PT_INTERP                ; type: Segment type
	dd PF_R                     ; flags: Segment flags
	dq interp                   ; offset: Segment file offset
	dq BASE_RODATA + interp     ; vaddr: Segment virtual address
	dq BASE_RODATA + interp     ; paddr: Segment physical address
	dq interp.size              ; filesz: Segment size in file
	dq interp.size              ; memsz: Segment size in memory
	dq 0x1                      ; align: Segment alignment

.entsize equ $ - phdr

; --- [ Dynamic array program header ] -----------------------------------------

  .dynamic:
	dd PT_DYNAMIC             ; type: Segment type
	dd PF_R                   ; flags: Segment flags
	dq dynamic                ; offset: Segment file offset
	dq BASE_RODATA + dynamic  ; vaddr: Segment virtual address
	dq BASE_RODATA + dynamic  ; paddr: Segment physical address
	dq dynamic.size           ; filesz: Segment size in file
	dq dynamic.size           ; memsz: Segment size in memory
	dq 0x8                    ; align: Segment alignment

; --- [ Read-only data segment program header ] --------------------------------

  .rodata_seg:
	dd PT_LOAD                  ; type: Segment type
	dd PF_R                     ; flags: Segment flags
	dq rodata_seg               ; offset: Segment file offset
	dq BASE_RODATA + rodata_seg ; vaddr: Segment virtual address
	dq BASE_RODATA + rodata_seg ; paddr: Segment physical address
	dq rodata_seg.size          ; filesz: Segment size in file
	dq rodata_seg.size          ; memsz: Segment size in memory
	dq PAGE                     ; align: Segment alignment

; --- [ Data segment program header ] ------------------------------------------

  .data_seg:
	dd PT_LOAD                  ; type: Segment type
	dd PF_R | PF_W              ; flags: Segment flags
	dq data_seg                 ; offset: Segment file offset
	dq BASE_DATA + data_seg     ; vaddr: Segment virtual address
	dq BASE_DATA + data_seg     ; paddr: Segment physical address
	dq data_seg.size            ; filesz: Segment size in file
	dq data_seg.size            ; memsz: Segment size in memory
	dq PAGE                     ; align: Segment alignment

; --- [ Code segment program header ] ------------------------------------------

  .code_seg:
	dd PT_LOAD                  ; type: Segment type
	dd PF_R | PF_X              ; flags: Segment flags
	dq code_seg                 ; offset: Segment file offset
	dq BASE_CODE + code_seg     ; vaddr: Segment virtual address
	dq BASE_CODE + code_seg     ; paddr: Segment physical address
	dq code_seg.size            ; filesz: Segment size in file
	dq code_seg.size            ; memsz: Segment size in memory
	dq PAGE                     ; align: Segment alignment

.size  equ $ - phdr
.count equ .size / .entsize

; === [/ Program headers ] =====================================================

; === [ Sections ] =============================================================

; --- [ .interp section ] ------------------------------------------------------

interp:

	db "/lib/ld64.so.1", 0

.size equ $ - interp

; --- [/ .interp section ] -----------------------------------------------------

; --- [ .dynamic section ] -----------------------------------------------------

; Dynamic tags.
DT_NULL     equ 0  ; Marks the end of the dynamic array
DT_NEEDED   equ 1  ; String table offset of a required library
DT_PLTGOT   equ 3  ; Address of the PLT and/or GOT
DT_STRTAB   equ 5  ; Address of the string table
DT_SYMTAB   equ 6  ; Address of the symbol table
DT_JMPREL   equ 23 ; Address of the relocation entities of the PLT

dynamic:

  .libc:
	dq DT_NEEDED              ; tag: Dynamic entry type
	dq dynstr.libc_off        ; val: Integer or address value

.entsize equ $ - dynamic

  .strtab:
	dq DT_STRTAB              ; tag: Dynamic entry type
	dq BASE_RODATA + dynstr   ; val: Integer or address value

  .symtab:
	dq DT_SYMTAB              ; tag: Dynamic entry type
	dq BASE_RODATA + dynsym   ; val: Integer or address value

  .pltgot:
	dq DT_PLTGOT              ; tag: Dynamic entry type
	dq BASE_DATA + got_plt    ; val: Integer or address value

  .jmprel:
	dq DT_JMPREL              ; tag: Dynamic entry type
	dq BASE_RODATA + rela_plt ; val: Integer or address value

  .null:
	dq DT_NULL               ; tag: Dynamic entry type
	dq 0                     ; val: Integer or address value

.size equ $ - dynamic

; --- [/ .dynamic section ] ----------------------------------------------------

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

; --- [ .dynsym section ] ------------------------------------------------------

; Symbol bindings.
STB_GLOBAL equ 1 ; Global symbol

; Symbol types.
STT_FUNC equ 2 ; Code object

; Symbol visibility.
STV_DEFAULT equ 0 ; Default visibility.

dynsym:

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

; --- [ .rela.plt section ] ----------------------------------------------------

; Relocation types.
R_386_JMP_SLOT equ 7

rela_plt:

  .printf:
	dq BASE_DATA + got_plt.printf             ; offset: Address
	dq dynsym.printf_idx<<32 | R_386_JMP_SLOT ; info: Relocation type and symbol index
	dq 0                                      ; addend: Addend

  .exit:
	dq BASE_DATA + got_plt.exit               ; offset: Address
	dq dynsym.exit_idx<<32 | R_386_JMP_SLOT   ; info: Relocation type and symbol index
	dq 0                                      ; addend: Addend

; --- [/ .rela.plt section ] ---------------------------------------------------

; --- [ .rodata section ] ------------------------------------------------------

rodata:

  .hello:
	db "hello world", 10, 0

; --- [/ .rodata section ] -----------------------------------------------------

rodata_seg.size equ $ - rodata_seg

; ___ [/ Read-only data segment ] ______________________________________________

; ___ [ Data segment ] _________________________________________________________

data_seg:

; --- [ .got.plt section ] -----------------------------------------------------

got_plt:

  .libc:
	dq BASE_RODATA + dynamic.libc

  .1:
	dq 0

  .2:
	dq 0

  .printf:
	dq BASE_CODE + plt.resolve_printf

  .exit:
	dq BASE_CODE + plt.resolve_exit

; --- [/ .got.plt section ] ----------------------------------------------------

data_seg.size equ $ - data_seg

; ___ [/ Data segment ] ________________________________________________________

; ___ [ Code segment ] _________________________________________________________

code_seg:

; --- [ .plt section ] ---------------------------------------------------------

plt:

  .resolve:
	push	QWORD [rel (BASE_DATA - BASE_CODE) + got_plt.1]
	jmp	[rel (BASE_DATA - BASE_CODE) + got_plt.2]

  .printf:
	jmp	[rel (BASE_DATA - BASE_CODE) + got_plt.printf]

  .resolve_printf:
	push	QWORD 0
	jmp	NEAR .resolve

  .exit:
	jmp	[rel (BASE_DATA - BASE_CODE) + got_plt.exit]

  .resolve_exit:
	push	QWORD 1
	jmp	NEAR .resolve

; --- [/ .plt section ] --------------------------------------------------------

; --- [ .text section ] --------------------------------------------------------

text:

  .start:
	mov	rdi, BASE_RODATA + rodata.hello
	call	plt.printf
	mov	edi, 0
	call	plt.exit

; --- [/ .text section ] -------------------------------------------------------

code_seg.size equ $ - code_seg

; ___ [/ Code segment ] ________________________________________________________

; === [/ Sections ] ============================================================
