[bits 64]

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
	dq shdr
  .flags:     ; Processor-specific flags
	dd 0
  .ehsize:    ; ELF header size in bytes
	dw ehsize
  .phentsize: ; Program header table entry size
	dw phentsize
  .phnum:     ; Program header table entry count
	dw phnum
  .shentsize: ; Section header table entry size
	dw shentsize
  .shnum:     ; Section header table entry count
	dw shnum
  .shstrndx:  ; Section header string table index
	dw shdr_shstrtab_idx

ehsize equ $ - ehdr

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

phdr_0:
  .type:   ; Segment type
	dd PT_PHDR
  .flags:  ; Segment flags
	dd PF_R | PF_X
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

phdr_1:
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

phdr_4:
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

interp:
	db "/lib/ld64.so.1", 0

interpsize equ $ - interp

hash:
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00

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
	dw shdr_null_idx
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
	dw shdr_null_idx
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
	dw shdr_null_idx
  .value: ; Symbol value
	dq 0
  .size:  ; Symbol size
	dq 0

dynsymsize equ $ - dynsym

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

db 0x00

rela_plt:

; Relocation types.

R_386_JMP_SLOT equ 7

rela_plt_0:
  .offset: ; Address
	dq BASE + 2*MB + got_plt_printf
  .info:   ; Relocation type and symbol index
	dq dynsym_printf_idx<<32 | R_386_JMP_SLOT
  .addend: ; Addend
	dq 0

rela_pltentsize equ $ - rela_plt

rela_plt_1:
  .offset: ; Address
	dq BASE + 2*MB + got_plt_exit
  .info:   ; Relocation type and symbol index
	dq dynsym_exit_idx<<32 | R_386_JMP_SLOT
  .addend: ; Addend
	dq 0

rela_pltsize equ $ - rela_plt

db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00

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
; pushq	$0x0
	db 0x68, 0x00, 0x00, 0x00, 0x00
	jmp	NEAR plt_0

plt_exit:
	jmp	[rel 2*MB + got_plt_exit]

.resolve:
; pushq	$0x1
	db 0x68, 0x01, 0x00, 0x00, 0x00

	jmp	NEAR plt_0

pltsize equ $ - plt

text:

  .start:
	mov	rdi, BASE + hello
	call	plt_printf
	mov	edi, 0
	call	plt_exit
	mov	eax, 10
	ret

textsize equ $ - text

db 0x00

rodata:

hello:
	db "hello world", 10, 0

rodatasize equ $ - rodata

something4size equ $ - something4

db 0x00
db 0x00
db 0x00

something:

dynamic:

; Dynamic tags.
DT_NULL     equ 0  ; Marks the end of the dynamic array
DT_NEEDED   equ 1  ; String table offset of a required library
DT_PLTRELSZ equ 2  ; Size of the relocation entities of the PLT
DT_PLTGOT   equ 3  ; Address of the PLT and/or GOT
DT_HASH     equ 4  ; Address of the symbol hash table
DT_STRTAB   equ 5  ; Address of the string table
DT_SYMTAB   equ 6  ; Address of the symbol table
DT_STRSZ    equ 10 ; Size of the string table
DT_SYMENT   equ 11 ; Symbol table entry size
DT_PLTREL   equ 20 ; Index to the PLTGOT dynamic entity
DT_DEBUG    equ 21 ; Used for debugging
DT_JMPREL   equ 23 ; Address of the relocation entities of the PLT

dyn_0:
  .tag: ; Dynamic entry type
	dq DT_NEEDED
  .val: ; Integer or address value
	dq dynstr.libc_idx

dynentsize equ $ - dynamic

dyn_1:
  .tag: ; Dynamic entry type
	dq DT_HASH
  .val: ; Integer or address value
	dq BASE + hash

dyn_2:
  .tag: ; Dynamic entry type
	dq DT_STRTAB
  .val: ; Integer or address value
	dq BASE + dynstr

dyn_3:
  .tag: ; Dynamic entry type
	dq DT_SYMTAB
  .val: ; Integer or address value
	dq BASE + dynsym

dyn_4:
  .tag: ; Dynamic entry type
	dq DT_STRSZ
  .val: ; Integer or address value
	dq dynstrsize

dyn_5:
  .tag: ; Dynamic entry type
	dq DT_SYMENT
  .val: ; Integer or address value
	dq dynsymentsize

dyn_6:
  .tag: ; Dynamic entry type
	dq DT_DEBUG
  .val: ; Integer or address value
	dq 0

dyn_pltgot:
dyn_pltgot_idx equ (dyn_pltgot - dynamic) / dynentsize
  .tag: ; Dynamic entry type
	dq DT_PLTGOT
  .val: ; Integer or address value
	dq BASE + 2*MB + got_plt

dyn_8:
  .tag: ; Dynamic entry type
	dq DT_PLTRELSZ
  .val: ; Integer or address value
	dq rela_pltsize

dyn_9:
  .tag: ; Dynamic entry type
	dq DT_PLTREL
  .val: ; Integer or address value
	dq dyn_pltgot_idx

dyn_10:
  .tag: ; Dynamic entry type
	dq DT_JMPREL
  .val: ; Integer or address value
	dq BASE + rela_plt

dyn_11:
  .tag: ; Dynamic entry type
	dq DT_NULL
  .val: ; Integer or address value
	dq 0

dynamicsize equ $ - dynamic

got_plt:

got_plt_0:
	dq BASE + 2*MB + dyn_0.tag

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

somethingsize equ $ - something

shstrtab:

  .null:
	db 0
  .shstrtab:
	db ".shstrtab", 0
  .interp:
	db ".interp", 0
  .dynsym:
	db ".dynsym", 0
  .dynstr:
	db ".dynstr", 0
  .rela_plt:
	db ".rela"
	.plt:
	db ".plt", 0
  .text:
	db ".text", 0
  .rodata:
	db ".rodata", 0
  .dynamic:
	db ".dynamic", 0
  .got_plt:
	db ".got.plt", 0

.null_idx          equ .null - shstrtab
.shstrtab_idx      equ .shstrtab - shstrtab
.interp_idx        equ .interp - shstrtab
.dynsym_idx        equ .dynsym - shstrtab
.dynstr_idx        equ .dynstr - shstrtab
.rela_plt_idx      equ .rela_plt - shstrtab
.plt_idx           equ .plt - shstrtab
.text_idx          equ .text - shstrtab
.rodata_idx        equ .rodata - shstrtab
.dynamic_idx       equ .dynamic - shstrtab
.got_plt_idx       equ .got_plt - shstrtab

shstrtabsize equ $ - shstrtab

db 0x00
db 0x00
db 0x00
db 0x00

shdr:

; Section types.
SHT_NULL     equ 0  ; Inactive section
SHT_PROGBITS equ 1  ; Program specific information
SHT_STRTAB   equ 3  ; String table
SHT_RELA     equ 4  ; Relocation entities
SHT_DYNAMIC  equ 6  ; Dynamic linking information
SHT_DYNSYM   equ 11 ; Dynamic linking symbols

; Section flags.
SHF_WRITE     equ 1 ; Contains writeable data
SHF_ALLOC     equ 2 ; Occupies memory during process execution
SHF_EXECINSTR equ 4 ; Contains executable machine instructions

; Section indicies.
SHN_UNDEF equ 0 ; Undefined, missing or irrelevant section reference

; NULL section
shdr_null:
shdr_null_idx equ (shdr_null - shdr) / shentsize

  .name: ; Section name (string tbl index)
	dd shstrtab.null_idx
  .type: ; Section type
	dd SHT_NULL
  .flags: ; Section flags
	dq 0
  .addr: ; Section virtual addr at execution
	dq 0
  .offset: ; Section file offset
	dq 0
  .size: ; Section size in bytes
	dq 0
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0
  .entsize: ; Entry size if section holds table
	dq 0

shentsize equ $ - shdr

; .interp section
shdr_1:
  .name: ; Section name (string tbl index)
	dd shstrtab.interp_idx
  .type: ; Section type
	dd SHT_PROGBITS
  .flags: ; Section flags
	dq SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq BASE + interp
  .offset: ; Section file offset
	dq interp
  .size: ; Section size in bytes
	dq interpsize
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x1
  .entsize: ; Entry size if section holds table
	dq 0

; .dynsym section
shdr_dynsym:
shdr_dynsym_idx equ (shdr_dynsym - shdr) / shentsize

  .name: ; Section name (string tbl index)
	dd shstrtab.dynsym_idx
  .type: ; Section type
	dd SHT_DYNSYM
  .flags: ; Section flags
	dq SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq BASE + dynsym
  .offset: ; Section file offset
	dq dynsym
  .size: ; Section size in bytes
	dq dynsymsize
  .link: ; Link to another section
	dd shdr_dynstr_idx
  .info: ; Additional section information; table index to the first global symbol
	dd dynsym_globals_idx
  .addralign: ; Section alignment
	dq 0x8
  .entsize: ; Entry size if section holds table
	dq dynsymentsize

; .dynstr section
shdr_dynstr:
shdr_dynstr_idx equ (shdr_dynstr - shdr) / shentsize

  .name: ; Section name (string tbl index)
	dd shstrtab.dynstr_idx
  .type: ; Section type
	dd SHT_STRTAB
  .flags: ; Section flags
	dq SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq BASE + dynstr
  .offset: ; Section file offset
	dq dynstr
  .size: ; Section size in bytes
	dq dynstrsize
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x1
  .entsize: ; Entry size if section holds table
	dq 0

; .rela.plt section
shdr_4:
  .name: ; Section name (string tbl index)
	dd shstrtab.rela_plt_idx
  .type: ; Section type
	dd SHT_RELA
  .flags: ; Section flags
	dq SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq BASE + rela_plt
  .offset: ; Section file offset
	dq rela_plt
  .size: ; Section size in bytes
	dq rela_pltsize
  .link: ; Link to another section
	dd shdr_dynsym_idx
  .info: ; Additional section information; section header index to which the relocations apply
	dd shdr_plt_idx
  .addralign: ; Section alignment
	dq 0x8
  .entsize: ; Entry size if section holds table
	dq rela_pltentsize

; .plt section
shdr_plt:
shdr_plt_idx equ (shdr_plt - shdr) / shentsize

  .name: ; Section name (string tbl index)
	dd shstrtab.plt_idx
  .type: ; Section type
	dd SHT_PROGBITS
  .flags: ; Section flags
	dq SHF_ALLOC | SHF_EXECINSTR
  .addr: ; Section virtual addr at execution
	dq BASE + plt
  .offset: ; Section file offset
	dq plt
  .size: ; Section size in bytes
	dq pltsize
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x10
  .entsize: ; Entry size if section holds table
	dq pltentsize

; .text section
shdr_6:
  .name: ; Section name (string tbl index)
	dd shstrtab.text_idx
  .type: ; Section type
	dd SHT_PROGBITS
  .flags: ; Section flags
	dq SHF_ALLOC | SHF_EXECINSTR
  .addr: ; Section virtual addr at execution
	dq BASE + text
  .offset: ; Section file offset
	dq text
  .size: ; Section size in bytes
	dq textsize
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x10
  .entsize: ; Entry size if section holds table
	dq 0

; .rodata section
shdr_7:
  .name: ; Section name (string tbl index)
	dd shstrtab.rodata_idx
  .type: ; Section type
	dd SHT_PROGBITS
  .flags: ; Section flags
	dq SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq BASE + rodata
  .offset: ; Section file offset
	dq rodata
  .size: ; Section size in bytes
	dq rodatasize
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x4
  .entsize: ; Entry size if section holds table
	dq 0

; .dynamic section
shdr_8:
  .name: ; Section name (string tbl index)
	dd shstrtab.dynamic_idx
  .type: ; Section type
	dd SHT_DYNAMIC
  .flags: ; Section flags
	dq SHF_WRITE | SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq BASE + 2*MB + dynamic
  .offset: ; Section file offset
	dq dynamic
  .size: ; Section size in bytes
	dq dynamicsize
  .link: ; Link to another section
	dd shdr_dynstr_idx
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x8
  .entsize: ; Entry size if section holds table
	dq dynentsize

; .got.plt section
shdr_9:
  .name: ; Section name (string tbl index)
	dd shstrtab.got_plt_idx
  .type: ; Section type
	dd SHT_PROGBITS
  .flags: ; Section flags
	dq SHF_WRITE | SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq BASE + 2*MB + got_plt
  .offset: ; Section file offset
	dq got_plt
  .size: ; Section size in bytes
	dq got_pltsize
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x8
  .entsize: ; Entry size if section holds table
	dq got_pltentsize

; .shstrtab section
shdr_shstrtab:
shdr_shstrtab_idx equ (shdr_shstrtab - shdr) / shentsize

  .name: ; Section name (string tbl index)
	dd shstrtab.shstrtab_idx
  .type: ; Section type
	dd SHT_STRTAB
  .flags: ; Section flags
	dq 0
  .addr: ; Section virtual addr at execution
	dq 0
  .offset: ; Section file offset
	dq shstrtab
  .size: ; Section size in bytes
	dq shstrtabsize
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x1
  .entsize: ; Entry size if section holds table
	dq 0

shsize equ $ - shdr
shnum  equ shsize / shentsize
