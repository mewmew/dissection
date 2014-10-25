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

phdr_0:
  .type:   ; Segment type
	dd PT_PHDR
  .flags:  ; Segment flags
	dd PF_R | PF_X
  .offset: ; Segment file offset
	dq phdr
  .vaddr:  ; Segment virtual address
	dq 0x0000000000400040
  .paddr:  ; Segment physical address
	dq 0x0000000000400040
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
	dq 0x0000000000400158
  .paddr:  ; Segment physical address
	dq 0x0000000000400158
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
	dq 0x0000000000400000
  .paddr:  ; Segment physical address
	dq 0x0000000000400000
  .filesz: ; Segment size in file
	dq 0x00000000000002AD
  .memsz:  ; Segment size in memory
	dq 0x00000000000002AD
  .align:  ; Segment alignment
	dq 0x200000 ; 2MB

phdr_3:
  .type:   ; Segment type
	dd PT_LOAD
  .flags:  ; Segment flags
	dd PF_R | PF_W
  .offset: ; Segment file offset
	dq something
  .vaddr:  ; Segment virtual address
	dq 0x00000000006002B0
  .paddr:  ; Segment physical address
	dq 0x00000000006002B0
  .filesz: ; Segment size in file
	dq somethingsize
  .memsz:  ; Segment size in memory
	dq somethingsize
  .align:  ; Segment alignment
	dq 0x200000 ; 2MB

phdr_4:
  .type:   ; Segment type
	dd PT_DYNAMIC
  .flags:  ; Segment flags
	dd PF_R | PF_W
  .offset: ; Segment file offset
	dq 0x00000000000002B0
  .vaddr:  ; Segment virtual address
	dq 0x00000000006002B0
  .paddr:  ; Segment physical address
	dq 0x00000000006002B0
  .filesz: ; Segment size in file
	dq 0x0000000000000140
  .memsz:  ; Segment size in memory
	dq 0x0000000000000140
  .align:  ; Segment alignment
	dq 0x8

phsize equ $ - phdr
phnum  equ phsize / phentsize

interp:
	db "/lib/ld64.so.1", 0x00

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
db 0x10
db 0x00
db 0x00
db 0x00
db 0x12
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
db 0x0B
db 0x00
db 0x00
db 0x00
db 0x12
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
db 0x6C ; l
db 0x69 ; i
db 0x62 ; b
db 0x63 ; c
db 0x2E ; .
db 0x73 ; s
db 0x6F ; o
db 0x2E ; .
db 0x36 ; 6
db 0x00
db 0x65 ; e
db 0x78 ; x
db 0x69 ; i
db 0x74 ; t
db 0x00
db 0x70 ; p
db 0x72 ; r
db 0x69 ; i
db 0x6E ; n
db 0x74 ; t
db 0x66 ; f
db 0x00
db 0x47 ; G
db 0x4C ; L
db 0x49 ; I
db 0x42 ; B
db 0x43 ; C
db 0x5F ; _
db 0x32 ; 2
db 0x2E ; .
db 0x32 ; 2
db 0x2E ; .
db 0x35 ; 5
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
db 0x75 ; u
db 0x1A
db 0x69 ; i
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
db 0x60 ; `
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
db 0x60 ; `
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
db 0xFF ; ÿ
db 0x35 ; 5
db 0xA2 ; ¢
db 0x01
db 0x20 ;
db 0x00
db 0xFF ; ÿ
db 0x25 ; %
db 0xA4 ; ¤
db 0x01
db 0x20 ;
db 0x00
db 0x0F
db 0x1F
db 0x40 ; @
db 0x00
db 0xFF ; ÿ
db 0x25 ; %
db 0xA2 ; ¢
db 0x01
db 0x20 ;
db 0x00
db 0x68 ; h
db 0x00
db 0x00
db 0x00
db 0x00
db 0xE9 ; é
db 0xE0 ; à
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0x25 ; %
db 0x9A
db 0x01
db 0x20 ;
db 0x00
db 0x68 ; h
db 0x01
db 0x00
db 0x00
db 0x00
db 0xE9 ; é
db 0xD0 ; Ð
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0x48 ; H
db 0xBF ; ¿
db 0xA0
db 0x02
db 0x40 ; @
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0xE8 ; è
db 0xD1 ; Ñ
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0xBF ; ¿
db 0x00
db 0x00
db 0x00
db 0x00
db 0xE8 ; è
db 0xD7 ; ×
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0xB8 ; ¸
db 0x0A
db 0x00
db 0x00
db 0x00
db 0xC3 ; Ã
db 0x00
db 0x68 ; h
db 0x65 ; e
db 0x6C ; l
db 0x6C ; l
db 0x6F ; o
db 0x20 ;
db 0x77 ; w
db 0x6F ; o
db 0x72 ; r
db 0x6C ; l
db 0x64 ; d
db 0x0A
db 0x00
db 0x00
db 0x00
db 0x00

something:
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
db 0x68 ; h
db 0x01
db 0x40 ; @
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
db 0xC8 ; È
db 0x01
db 0x40 ; @
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
db 0x40 ; @
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
db 0x23 ; #
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
db 0xF0 ; ð
db 0x03
db 0x60 ; `
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
db 0x30 ; 0
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
db 0x40 ; @
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0xFE ; þ
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0x6F ; o
db 0x00
db 0x00
db 0x00
db 0x00
db 0xF8 ; ø
db 0x01
db 0x40 ; @
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0x6F ; o
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
db 0xF0 ; ð
db 0xFF ; ÿ
db 0xFF ; ÿ
db 0x6F ; o
db 0x00
db 0x00
db 0x00
db 0x00
db 0xEC ; ì
db 0x01
db 0x40 ; @
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
db 0xB0 ; °
db 0x02
db 0x60 ; `
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
db 0x66 ; f
db 0x02
db 0x40 ; @
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x76 ; v
db 0x02
db 0x40 ; @
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00

somethingsize equ $ - something

db 0x00
db 0x2E ; .
db 0x73 ; s
db 0x68 ; h
db 0x73 ; s
db 0x74 ; t
db 0x72 ; r
db 0x74 ; t
db 0x61 ; a
db 0x62 ; b
db 0x00
db 0x2E ; .
db 0x69 ; i
db 0x6E ; n
db 0x74 ; t
db 0x65 ; e
db 0x72 ; r
db 0x70 ; p
db 0x00
db 0x2E ; .
db 0x64 ; d
db 0x79 ; y
db 0x6E ; n
db 0x73 ; s
db 0x79 ; y
db 0x6D ; m
db 0x00
db 0x2E ; .
db 0x64 ; d
db 0x79 ; y
db 0x6E ; n
db 0x73 ; s
db 0x74 ; t
db 0x72 ; r
db 0x00
db 0x2E ; .
db 0x67 ; g
db 0x6E ; n
db 0x75 ; u
db 0x2E ; .
db 0x76 ; v
db 0x65 ; e
db 0x72 ; r
db 0x73 ; s
db 0x69 ; i
db 0x6F ; o
db 0x6E ; n
db 0x5F ; _
db 0x72 ; r
db 0x00
db 0x2E ; .
db 0x72 ; r
db 0x65 ; e
db 0x6C ; l
db 0x61 ; a
db 0x2E ; .
db 0x70 ; p
db 0x6C ; l
db 0x74 ; t
db 0x00
db 0x2E ; .
db 0x74 ; t
db 0x65 ; e
db 0x78 ; x
db 0x74 ; t
db 0x00
db 0x2E ; .
db 0x72 ; r
db 0x6F ; o
db 0x64 ; d
db 0x61 ; a
db 0x74 ; t
db 0x61 ; a
db 0x00
db 0x2E ; .
db 0x64 ; d
db 0x79 ; y
db 0x6E ; n
db 0x61 ; a
db 0x6D ; m
db 0x69 ; i
db 0x63 ; c
db 0x00
db 0x2E ; .
db 0x67 ; g
db 0x6F ; o
db 0x74 ; t
db 0x2E ; .
db 0x70 ; p
db 0x6C ; l
db 0x74 ; t
db 0x00
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
	dd 11
  .type: ; Section type
	dd SHT_PROGBITS
  .flags: ; Section flags
	dq SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq 0x0000000000400158
  .offset: ; Section file offset
	dq interp
  .size: ; Section size in bytes
	dq interpsize
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x0000000000000001
  .entsize: ; Entry size if section holds table
	dq 0x0000000000000000

; .dynsym section
shdr_2:
  .name: ; Section name (string tbl index)
	dd 0x00000013
  .type: ; Section type
	dd SHT_DYNSYM
  .flags: ; Section flags
	dq SHF_ALLOC
  .addr: ; Section virtual addr at execution
	dq 0x0000000000400180
  .offset: ; Section file offset
	dq 0x0000000000000180
  .size: ; Section size in bytes
	dq 0x0000000000000048
  .link: ; Link to another section
	dd 0x000000003
  .info: ; Additional section information
	dd 0x000000001
  .addralign: ; Section alignment
	dq 0x0000000000000008
  .entsize: ; Entry size if section holds table
	dq 0x0000000000000018

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
	dq 0x0000000000000001
  .entsize: ; Entry size if section holds table
	dq 0x0000000000000000

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
	dq 0x0000000000000008
  .entsize: ; Entry size if section holds table
	dq 0x0000000000000000

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
	dq 0x0000000000000008
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
	dq 0x0000000000000010
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
	dq 0x0000000000000010
  .entsize: ; Entry size if section holds table
	dq 0x0000000000000000

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
	dq 0x0000000000000004
  .entsize: ; Entry size if section holds table
	dq 0x0000000000000000

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
	dq 0x0000000000000008
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
	dq 0x0000000000000008
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
	dq 0x0000000000000000
  .offset: ; Section file offset
	dq 0x0000000000000418
  .size: ; Section size in bytes
	dq 0x000000000000005C
  .link: ; Link to another section
	dd SHN_UNDEF
  .info: ; Additional section information
	dd 0
  .addralign: ; Section alignment
	dq 0x0000000000000001
  .entsize: ; Entry size if section holds table
	dq 0x0000000000000000

shsize equ $ - shdr
shnum  equ shsize / shentsize
