ehdr:

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
	dq 0x0000000000400280
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
	dw 0x000B

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
	dq 0x0000000000000000
  .vaddr:  ; Segment virtual address
	dq BASE
  .paddr:  ; Segment physical address
	dq BASE
  .filesz: ; Segment size in file
	dq 0x00000000000002AD
  .memsz:  ; Segment size in memory
	dq 0x00000000000002AD
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
	dq something2
  .vaddr:  ; Segment virtual address
	dq BASE + 2*MB + something2
  .paddr:  ; Segment physical address
	dq BASE + 2*MB + something2
  .filesz: ; Segment size in file
	dq something2size
  .memsz:  ; Segment size in memory
	dq something2size
  .align:  ; Segment alignment
	dq 0x8

phsize equ $ - phdr
phnum  equ phsize / phentsize

interp:
	db "/lib/ld64.so.1", 0

interpsize equ $ - interp

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
	dd 0x00000000
  .info:  ; Symbol type and binding
	db STB_LOCAL<<4
  .other: ; Symbol visibility
	db STV_DEFAULT
  .shndx: ; Section index
	dw 0x0000
  .value: ; Symbol value
	dq 0
  .size:  ; Symbol size
	dq 0

dynsymentsize equ $ - dynsym

dynsym_1:
  .name:  ; Symbol name (string tbl index)
	dd 0x00000010
  .info:  ; Symbol type and binding
	db STB_GLOBAL<<4 | STT_FUNC
  .other: ; Symbol visibility
	db STV_DEFAULT
  .shndx: ; Section index
	dw 0x0000
  .value: ; Symbol value
	dq 0
  .size:  ; Symbol size
	dq 0

dynsym_2:
  .name:  ; Symbol name (string tbl index)
	dd 0x0000000B
  .info:  ; Symbol type and binding
	db STB_GLOBAL<<4 | STT_FUNC
  .other: ; Symbol visibility
	db STV_DEFAULT
  .shndx: ; Section index
	dw 0x0000
  .value: ; Symbol value
	dq 0
  .size:  ; Symbol size
	dq 0

dynsymsize equ $ - dynsym

db 0x00
db "libc.so.6", 0
db "exit", 0
db "printf", 0
db "GLIBC_2.2.5", 0
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
db 0x01
db 0x00
db 0x01
db 0x00
db 0x01
db 0x00
db 0x00
db 0x00
db 0x10
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x75
db 0x1A
db 0x69
db 0x09
db 0x00
db 0x00
db 0x02
db 0x00
db 0x17
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x08
db 0x04
db 0x60
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x07
db 0x00
db 0x00
db 0x00
db 0x01
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
db 0x10
db 0x04
db 0x60
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x07
db 0x00
db 0x00
db 0x00
db 0x02
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
db 0xFF
db 0x35
db 0xA2
db 0x01
db 0x20
db 0x00
db 0xFF
db 0x25
db 0xA4
db 0x01
db 0x20
db 0x00
db 0x0F
db 0x1F
db 0x40
db 0x00
db 0xFF
db 0x25
db 0xA2
db 0x01
db 0x20
db 0x00
db 0x68
db 0x00
db 0x00
db 0x00
db 0x00
db 0xE9
db 0xE0
db 0xFF
db 0xFF
db 0xFF
db 0xFF
db 0x25
db 0x9A
db 0x01
db 0x20
db 0x00
db 0x68
db 0x01
db 0x00
db 0x00
db 0x00
db 0xE9
db 0xD0
db 0xFF
db 0xFF
db 0xFF
db 0x48
db 0xBF
db 0xA0
db 0x02
db 0x40
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0xE8
db 0xD1
db 0xFF
db 0xFF
db 0xFF
db 0xBF
db 0x00
db 0x00
db 0x00
db 0x00
db 0xE8
db 0xD7
db 0xFF
db 0xFF
db 0xFF
db 0xB8
db 0x0A
db 0x00
db 0x00
db 0x00
db 0xC3
db 0x00
db "hello world", 10, 0
db 0x00
db 0x00
db 0x00

something:
something2:
db 0x01
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x01
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x04
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x68
db 0x01
db 0x40
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x05
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0xC8
db 0x01
db 0x40
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x06
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x80
db 0x01
db 0x40
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x0A
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x23
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x0B
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x18
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x15
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
db 0x03
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0xF0
db 0x03
db 0x60
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x02
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x30
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x14
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x07
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x17
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x18
db 0x02
db 0x40
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0xFE
db 0xFF
db 0xFF
db 0x6F
db 0x00
db 0x00
db 0x00
db 0x00
db 0xF8
db 0x01
db 0x40
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0xFF
db 0xFF
db 0xFF
db 0x6F
db 0x00
db 0x00
db 0x00
db 0x00
db 0x01
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0xF0
db 0xFF
db 0xFF
db 0x6F
db 0x00
db 0x00
db 0x00
db 0x00
db 0xEC
db 0x01
db 0x40
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
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00

something2size equ $ - something2

db 0xB0
db 0x02
db 0x60
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
db 0x66
db 0x02
db 0x40
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x76
db 0x02
db 0x40
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00

somethingsize equ $ - something

db 0
db ".shstrtab", 0
db ".interp", 0
db ".dynsym", 0
db ".dynstr", 0
db ".gnu.version_r", 0
db ".rela.plt", 0
db ".text", 0
db ".rodata", 0
db ".dynamic", 0
db ".got.plt", 0
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
shdr_0:
  .name: ; Section name (string tbl index)
	dd 0
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
	dd 0
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
	dd 0x0000000B
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
shdr_2:
  .name: ; Section name (string tbl index)
	dd 0x00000013
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
	dd 0x000000003
  .info: ; Additional section information
	dd 0x000000001
  .addralign: ; Section alignment
	dq 0x8
  .entsize: ; Entry size if section holds table
	dq dynsymentsize

; .dynstr section
shdr_3:
  .name: ; Section name (string tbl index)
	dd 0x0000001B
  .type: ; Section type
	dd SHT_STRTAB
  .flags: ; Section flags
	dq SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq 0x00000000004001C8
  .offset: ; Section file offset
	dq 0x00000000000001C8
  .size: ; Section size in bytes
	dq 0x0000000000000023
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x1
  .entsize: ; Entry size if section holds table
	dq 0

; .gnu.version_r section
shdr_4:
  .name: ; Section name (string tbl index)
	dd 0x00000023
  .type: ; Section type
	dd 0x6FFFFFFE
  .flags: ; Section flags
	dq SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq 0x00000000004001F8
  .offset: ; Section file offset
	dq 0x00000000000001F8
  .size: ; Section size in bytes
	dq 0x0000000000000020
  .link: ; Link to another section
	dd 0x000000003
  .info: ; Additional section information
	dd 0x000000001
  .addralign: ; Section alignment
	dq 0x8
  .entsize: ; Entry size if section holds table
	dq 0

; .rela.plt section
shdr_5:
  .name: ; Section name (string tbl index)
	dd 0x00000032
  .type: ; Section type
	dd SHT_RELA
  .flags: ; Section flags
	dq SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq 0x0000000000400218
  .offset: ; Section file offset
	dq 0x0000000000000218
  .size: ; Section size in bytes
	dq 0x0000000000000030
  .link: ; Link to another section
	dd 0x000000002
  .info: ; Additional section information
	dd 0x000000006
  .addralign: ; Section alignment
	dq 0x8
  .entsize: ; Entry size if section holds table
	dq 0x0000000000000018

; .plt section
shdr_6:
  .name: ; Section name (string tbl index)
	dd 0x00000037
  .type: ; Section type
	dd SHT_PROGBITS
  .flags: ; Section flags
	dq SHF_ALLOC | SHF_EXECINSTR
  .addr: ; Section virtual addr at execution
	dq 0x0000000000400250
  .offset: ; Section file offset
	dq 0x0000000000000250
  .size: ; Section size in bytes
	dq 0x0000000000000030
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x10
  .entsize: ; Entry size if section holds table
	dq 0x0000000000000010

; .text section
shdr_7:
  .name: ; Section name (string tbl index)
	dd 0x0000003C
  .type: ; Section type
	dd SHT_PROGBITS
  .flags: ; Section flags
	dq SHF_ALLOC | SHF_EXECINSTR
  .addr: ; Section virtual addr at execution
	dq 0x0000000000400280
  .offset: ; Section file offset
	dq 0x0000000000000280
  .size: ; Section size in bytes
	dq 0x000000000000001F
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x10
  .entsize: ; Entry size if section holds table
	dq 0

; .rodata section
shdr_8:
  .name: ; Section name (string tbl index)
	dd 0x00000042
  .type: ; Section type
	dd SHT_PROGBITS
  .flags: ; Section flags
	dq SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq 0x00000000004002A0
  .offset: ; Section file offset
	dq 0x00000000000002A0
  .size: ; Section size in bytes
	dq 0x000000000000000D
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x4
  .entsize: ; Entry size if section holds table
	dq 0

; .dynamic section
shdr_9:
  .name: ; Section name (string tbl index)
	dd 0x0000004A
  .type: ; Section type
	dd SHT_DYNAMIC
  .flags: ; Section flags
	dq SHF_WRITE | SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq 0x00000000006002B0
  .offset: ; Section file offset
	dq 0x00000000000002B0
  .size: ; Section size in bytes
	dq 0x0000000000000140
  .link: ; Link to another section
	dd 0x000000003
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x8
  .entsize: ; Entry size if section holds table
	dq 0x0000000000000010

; .got.plt section
shdr_10:
  .name: ; Section name (string tbl index)
	dd 0x00000053
  .type: ; Section type
	dd SHT_PROGBITS
  .flags: ; Section flags
	dq SHF_WRITE | SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq 0x00000000006003F0
  .offset: ; Section file offset
	dq 0x00000000000003F0
  .size: ; Section size in bytes
	dq 0x0000000000000028
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x8
  .entsize: ; Entry size if section holds table
	dq 0x0000000000000008

; .shstrtab section
shdr_11:
  .name: ; Section name (string tbl index)
	dd 0x00000001
  .type: ; Section type
	dd SHT_STRTAB
  .flags: ; Section flags
	dq 0
  .addr: ; Section virtual addr at execution
	dq 0
  .offset: ; Section file offset
	dq 0x0000000000000418
  .size: ; Section size in bytes
	dq 0x000000000000005C
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
