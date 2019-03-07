BITS 32

; Base addresses.
BASE        equ 0x08048000
PAGE        equ 0x1000
BASE_RODATA equ BASE
BASE_CODE   equ BASE + 1*PAGE
BASE_HELLO  equ BASE + 2*PAGE
BASE_DATA   equ 0x0804BF58

%define round(n, r)     (((n + (r - 1)) / r) * r)

; ___ [ Read-only data segment ] _______________________________________________

rodata_seg_off equ 0

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x000000 0x08048000 0x08048000 0x00200 0x00200 R   0x1000

SECTION .rdata vstart=BASE_RODATA align=1

rodata_seg:

; === [ ELF file header ] ======================================================

; ELF classes.
ELFCLASS32 equ 1 ; 32-bit object

; Data encodings.
ELFDATA2LSB equ 1 ; 2's complement with little-endian encoding

; Object file types.
ET_EXEC equ 2 ; Executable file

; Architecture.
EM_386 equ 3 ; Intel i386

shstrndx equ 0x000b ; TODO: remove

ehdr:

	db      0x7F, "ELF"               ; ident.magic: ELF magic number
	db      ELFCLASS32                ; ident.class: File class
	db      ELFDATA2LSB               ; ident.data: Data encoding
	db      1                         ; ident.version: ELF header version
	db      0, 0, 0, 0, 0, 0, 0, 0, 0 ; ident.pad: Padding
	dw      ET_EXEC                   ; type: Object file type
	dw      EM_386                    ; machine: Architecture
	dd      1                         ; version: Object file version
	dd      text.start                ; entry: Entry point virtual address
	dd      phdr_off                  ; phoff: Program header table file offset
	dd      shdr_off                  ; shoff: Section header table file offset
	dd      0                         ; flags: Processor-specific flags
	dw      ehdr.size                 ; ehsize: ELF header size in bytes
	dw      phdr.entsize              ; phentsize: Program header table entry size
	dw      phdr.count                ; phnum: Program header table entry count
	dw      shdr.entsize              ; shentsize: Section header table entry size
	dw      shdr.count                ; shnum: Section header table entry count
	dw      shstrndx                  ; shstrndx: Section header string table index

ehdr.size equ $ - ehdr

; === [/ ELF file header ] =====================================================

; === [ Program headers ] ======================================================

; Program header entry types.
PT_NULL    equ 0 ; Unused entry.
PT_LOAD    equ 1 ; Loadable segment.
PT_DYNAMIC equ 2 ; Dynamic linking information segment.
PT_INTERP  equ 3 ; Pathname of interpreter.
PT_PHDR    equ 6 ; Location of program header itself.

; Program header entry flags.
PF_X equ 0x1 ; Executable.
PF_W equ 0x2 ; Writable.
PF_R equ 0x4 ; Readable.

phdr_off equ $ - BASE

phdr:

; --- [ Program header ] -------------------------------------------------------

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  PHDR           0x000034 0x08048034 0x08048034 0x000e0 0x000e0 R   0x4

  .phdr:
	dd      PT_PHDR                  ; type:   Entry type.
	dd      phdr - BASE_RODATA       ; off:    File offset of contents.
	dd      phdr                     ; vaddr:  Virtual address in memory image.
	dd      phdr                     ; paddr:  Physical address (not used).
	dd      phdr.size                ; filesz: Size of contents in file.
	dd      phdr.size                ; memsz:  Size of contents in memory.
	dd      PF_R                     ; flags:  Access permission flags.
	dd      0x4                      ; align:  Alignment in memory and file.

; --- [ Interpreter program header ] -------------------------------------------

phdr.entsize equ $ - phdr

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  INTERP         0x000134 0x08048134 0x08048134 0x00013 0x00013 R   0x1

  .interp:
	dd      PT_INTERP                ; type:   Entry type.
	dd      interp_off               ; off:    File offset of contents.
	dd      interp                   ; vaddr:  Virtual address in memory image.
	dd      interp                   ; paddr:  Physical address (not used).
	dd      interp.size              ; filesz: Size of contents in file.
	dd      interp.size              ; memsz:  Size of contents in memory.
	dd      PF_R                     ; flags:  Access permission flags.
	dd      0x1                      ; align:  Alignment in memory and file.

; --- [ Read-only data segment program header ] --------------------------------

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x000000 0x08048000 0x08048000 0x00200 0x00200 R   0x1000

  .rodata_seg:
	dd      PT_LOAD                  ; type:   Entry type.
	dd      rodata_seg_off           ; off:    File offset of contents.
	dd      rodata_seg               ; vaddr:  Virtual address in memory image.
	dd      rodata_seg               ; paddr:  Physical address (not used).
	dd      rodata_seg.size          ; filesz: Size of contents in file.
	dd      rodata_seg.size          ; memsz:  Size of contents in memory.
	dd      PF_R                     ; flags:  Access permission flags.
	dd      0x1000                   ; align:  Alignment in memory and file.

; --- [ Code segment program header ] ------------------------------------------

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x001000 0x08049000 0x08049000 0x00048 0x00048 R E 0x1000

  .code_seg:
	dd      PT_LOAD                  ; type:   Entry type.
	dd      code_seg_off             ; off:    File offset of contents.
	dd      code_seg                 ; vaddr:  Virtual address in memory image.
	dd      code_seg                 ; paddr:  Physical address (not used).
	dd      code_seg.size            ; filesz: Size of contents in file.
	dd      code_seg.size            ; memsz:  Size of contents in memory.
	dd      PF_R | PF_X              ; flags:  Access permission flags.
	dd      0x1000                   ; align:  Alignment in memory and file.

; --- [ "hello world" segment program header ] ---------------------------------

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x002000 0x0804a000 0x0804a000 0x0000d 0x0000d R   0x1000

  .hello_seg:
	dd      PT_LOAD                  ; type:   Entry type.
	dd      hello_seg_off             ; off:    File offset of contents.
	dd      hello_seg                 ; vaddr:  Virtual address in memory image.
	dd      hello_seg                 ; paddr:  Physical address (not used).
	dd      hello_seg.size            ; filesz: Size of contents in file.
	dd      hello_seg.size            ; memsz:  Size of contents in memory.
	dd      PF_R                     ; flags:  Access permission flags.
	dd      0x1000                   ; align:  Alignment in memory and file.

; --- [ Data segment program header ] ------------------------------------------

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x002f58 0x0804bf58 0x0804bf58 0x000bc 0x000bc RW  0x1000

  .data_seg:
	dd      PT_LOAD                  ; type:   Entry type.
	dd      data_seg_off             ; off:    File offset of contents.
	dd      data_seg                 ; vaddr:  Virtual address in memory image.
	dd      data_seg                 ; paddr:  Physical address (not used).
	dd      data_seg.size            ; filesz: Size of contents in file.
	dd      data_seg.size            ; memsz:  Size of contents in memory.
	dd      PF_R | PF_W              ; flags:  Access permission flags.
	dd      0x1000                   ; align:  Alignment in memory and file.

; --- [ Dynamic array program header ] -----------------------------------------

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  DYNAMIC        0x002f58 0x0804bf58 0x0804bf58 0x000a8 0x000a8 RW  0x4

  .dynamic:
	dd      PT_DYNAMIC               ; type:   Entry type.
	dd      dynamic_off              ; off:    File offset of contents.
	dd      dynamic                  ; vaddr:  Virtual address in memory image.
	dd      dynamic                  ; paddr:  Physical address (not used).
	dd      dynamic.size             ; filesz: Size of contents in file.
	dd      dynamic.size             ; memsz:  Size of contents in memory.
	dd      PF_R | PF_W              ; flags:  Access permission flags.
	dd      0x4                      ; align:  Alignment in memory and file.

phdr.size  equ $ - phdr
phdr.count equ phdr.size / phdr.entsize

; --- [ NULL program header ] --------------------------------------------------

  .null:
	dd      PT_NULL                  ; type:   Entry type.
	dd      0                        ; off:    File offset of contents.
	dd      0                        ; vaddr:  Virtual address in memory image.
	dd      0                        ; paddr:  Physical address (not used).
	dd      0                        ; filesz: Size of contents in file.
	dd      0                        ; memsz:  Size of contents in memory.
	dd      0                        ; flags:  Access permission flags.
	dd      0                        ; align:  Alignment in memory and file.

; === [/ Program headers ] =====================================================

; --- [ .interp section ] ------------------------------------------------------

interp_off equ $ - BASE

interp:

	db      "/lib/ld-linux.so.2", 0

interp.size equ $ - interp

; 00000147

align 0x8, db 0x00

; 00000148

hash:

times (0x160 - 0x148)   db 0x00

; 00000160

gnu_hash:

times (0x178 - 0x160)   db 0x00

; --- [ Dynamic symbols ] ------------------------------------------------------

dynsym_off equ $ - BASE

dynsym:

; 00000178
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; |................|

; 00000180
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; |................|

; 00000190
db 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; |................|

; 000001a0
db 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x00, 0x00 ; |........|

dynsym.size equ $ - dynsym

; --- [ .dynstr section ] ------------------------------------------------------

dynstr_off equ $ - BASE

; 000001a8

dynstr:

  .null:
	db      0

  .libc:
	db      "libc.so.6", 0

  .exit:
	db      "exit", 0

  .printf:
	db      "printf", 0

  .glibc:
	db      "GLIBC_2.0", 0

.libc_off   equ .libc - dynstr
.exit_off   equ .exit - dynstr
.printf_off equ .printf - dynstr
.glibc_off  equ .glibc - dynstr

dynstr.size equ $ - dynstr

align 2, db 0x00

; 000001ca

versym:

times (0x1d0 - 0x1ca) db 0x00

; --- [ .gnu.version_r section ] -----------------------------------------------

gnu_version_r_off equ $ - BASE

; 000001d0

gnu_version_r:

db 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; |................|

; 000001e0
db 0x10, 0x69, 0x69, 0x0d, 0x00, 0x00, 0x02, 0x00, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; |.ii.............|

gnu_version_r.size equ $ - gnu_version_r

; --- [ .rel.plt section ] -----------------------------------------------------

rel_plt_off equ $ - BASE

; 000001f0

rel_plt:

db 0x0c, 0xc0, 0x04, 0x08, 0x07, 0x01, 0x00, 0x00, 0x10, 0xc0, 0x04, 0x08, 0x07, 0x02, 0x00, 0x00 ; |................|

rel_plt.size equ $ - rel_plt

; 00000200

rodata_seg.size equ $ - rodata_seg

; ___ [/ Read-only data segment ] ______________________________________________

align 0x1000, db 0x00

; ___ [ Code segment ] _________________________________________________________

code_seg_off equ $ - BASE

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x001000 0x08049000 0x08049000 0x00048 0x00048 R E 0x1000

SECTION .code vstart=BASE_CODE align=1 follows=.rdata

code_seg:

; --- [ .plt section ] ---------------------------------------------------------

plt_off equ $ - BASE

; 00001000

plt:

db 0xff, 0x35, 0x04, 0xc0, 0x04, 0x08, 0xff, 0x25, 0x08, 0xc0, 0x04, 0x08, 0x00, 0x00, 0x00, 0x00 ; |.5.....%........|

; 00001010
db 0xff, 0x25, 0x0c, 0xc0, 0x04, 0x08, 0x68, 0x00, 0x00, 0x00, 0x00, 0xe9, 0xe0, 0xff, 0xff, 0xff ; |.%....h.........|

; 00001020
db 0xff, 0x25, 0x10, 0xc0, 0x04, 0x08, 0x68, 0x08, 0x00, 0x00, 0x00, 0xe9, 0xd0, 0xff, 0xff, 0xff ; |.%....h.........|

plt.size equ $ - plt

; --- [ .text section ] --------------------------------------------------------

text_off equ $ - BASE

; 00001030

text:

  .start:
db 0x68, 0x00, 0xa0, 0x04, 0x08, 0xe8, 0xd6, 0xff, 0xff, 0xff, 0x83, 0xc4, 0x04, 0x6a, 0x00, 0xe8 ; |h............j..|

; 00001040
db 0xdc, 0xff, 0xff, 0xff, 0x83, 0xc4, 0x04, 0xc3 ; |................|

text.size equ $ - text

code_seg.size equ $ - code_seg

; ___ [/ Code segment ] ________________________________________________________

align 0x1000, db 0x00

; ___ [ "hello world" segment ] ________________________________________________

hello_seg_off equ $ - BASE

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x002000 0x0804a000 0x0804a000 0x0000d 0x0000d R   0x1000

SECTION .hello vstart=BASE_HELLO align=1 follows=.code

hello_seg:

; --- [ .rodata section ] ------------------------------------------------------

rodata_off equ $ - BASE

; 00002000

rodata:

	db      "hello world", 10, 0

rodata.size equ $ - rodata

hello_seg.size equ $ - hello_seg

; ___ [/ "hello world" segment ] _______________________________________________

times BASE_DATA - (BASE_HELLO + hello_seg.size + PAGE)   db 0x00

; ___ [ Data segment ] _________________________________________________________

data_seg_off equ $ - BASE

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x002f58 0x0804bf58 0x0804bf58 0x000bc 0x000bc RW  0x1000

SECTION .data vstart=BASE_DATA align=1

data_seg:

; --- [ .dynamic section ] -----------------------------------------------------

dynamic_off equ data_seg_off + ($ - $$)

; 00002f58

; Dynamic tags.
DT_NULL       equ 0          ; Terminating entry.
DT_NEEDED     equ 1          ; String table offset of a needed shared library.
DT_PLTRELSZ   equ 2          ; Total size in bytes of PLT relocations.
DT_PLTGOT     equ 3          ; Processor-dependent address.
DT_HASH       equ 4          ; Address of symbol hash table.
DT_STRTAB     equ 5          ; Address of string table.
DT_SYMTAB     equ 6          ; Address of symbol table.
DT_STRSZ      equ 10         ; Size of string table.
DT_SYMENT     equ 11         ; Size of each symbol table entry.
DT_REL        equ 17         ; Address of ElfNN_Rel relocations.
DT_PLTREL     equ 20         ; Type of relocation used for PLT.
DT_DEBUG      equ 21         ; Reserved (not used).
DT_JMPREL     equ 23         ; Address of PLT relocations.
DT_GNU_HASH   equ 0x6FFFFEF5 ; Address of GNU symbol hash table.
DT_VERSYM     equ 0x6FFFFFF0 ; GNU version symbol.
DT_VERNEED    equ 0x6FFFFFFE ; GNU version needed.
DT_VERNEEDNUM equ 0x6FFFFFFF ; GNU version needed count.

dynamic:

;  Tag        Type                         Name/Value
; 0x00000001 (NEEDED)                     Shared library: [libc.so.6]

  .libc:
	dd      DT_NEEDED              ; tag: Dynamic entry type
	dd      dynstr.libc_off        ; val: Integer or address value

.entsize equ $ - dynamic

;  Tag        Type                         Name/Value
; 0x00000004 (HASH)                       0x8048148

  .hash:
	dd      DT_HASH                ; tag: Dynamic entry type
	dd      hash                   ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x6ffffef5 (GNU_HASH)                   0x8048160

  .gnu_hash:
	dd      DT_GNU_HASH            ; tag: Dynamic entry type
	dd      gnu_hash               ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x00000005 (STRTAB)                     0x80481a8

  .strtab:
	dd      DT_STRTAB              ; tag: Dynamic entry type
	dd      dynstr                 ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x00000006 (SYMTAB)                     0x8048178

  .symtab:
	dd      DT_SYMTAB              ; tag: Dynamic entry type
	dd      dynsym                 ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x0000000a (STRSZ)                      33 (bytes)

  .strsz:
	dd      DT_STRSZ               ; tag: Dynamic entry type
	dd      dynstr.size            ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x0000000b (SYMENT)                     16 (bytes)

syment equ 16 ; TODO: remove

  .syment:
	dd      DT_SYMENT              ; tag: Dynamic entry type
	dd      syment                 ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x00000015 (DEBUG)                      0x0

  .debug:
	dd      DT_DEBUG               ; tag: Dynamic entry type
	dd      0                      ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x00000003 (PLTGOT)                     0x804c000

plt_got equ 0x0804c000 ; TODO: remove

  .plt_got:
	dd      DT_PLTGOT              ; tag: Dynamic entry type
	dd      plt_got                ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x00000002 (PLTRELSZ)                   16 (bytes)

pltrelsz equ 16 ; TODO: remove

  .pltrelsz:
	dd      DT_PLTRELSZ            ; tag: Dynamic entry type
	dd      pltrelsz               ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x00000014 (PLTREL)                     REL

  .pltrel:
	dd      DT_PLTREL              ; tag: Dynamic entry type
	dd      DT_REL                 ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x00000017 (JMPREL)                     0x80481f0

  .jmprel:
	dd      DT_JMPREL              ; tag: Dynamic entry type
	dd      rel_plt                ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x6ffffffe (VERNEED)                    0x80481d0

  .verneed:
	dd      DT_VERNEED             ; tag: Dynamic entry type
	dd      gnu_version_r          ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x6fffffff (VERNEEDNUM)                 1

verneednum equ 1 ; TODO: remove

  .verneednum:
	dd      DT_VERNEEDNUM          ; tag: Dynamic entry type
	dd      verneednum             ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x6ffffff0 (VERSYM)                     0x80481ca

  .versym:
	dd      DT_VERSYM              ; tag: Dynamic entry type
	dd      versym                 ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x00000000 (NULL)                       0x0

  .null:
	dd      DT_NULL                ; tag: Dynamic entry type
	dd      0                      ; val: Integer or address value

; TODO: simply padding
times (0x3000 - 0x2FD8) db 0x00

dynamic.size equ $ - dynamic

; --- [ .got.plt section ] -----------------------------------------------------

got_plt_off equ data_seg_off + ($ - $$)

; 00003000

got_plt:

db 0x58, 0xbf, 0x04, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x16, 0x90, 0x04, 0x08 ; |X...............|

; 00003010
db 0x26, 0x90, 0x04, 0x08 ; |&...|

got_plt.size equ $ - got_plt

data_seg.size equ $ - data_seg

; ___ [/ Data segment ] ________________________________________________________

; --- [ .shstrtab section ] ----------------------------------------------------

shstrtab_off equ data_seg_off + ($ - $$)

; 00003014

shstrtab:

	db 0

  .shstrtab_idx equ $ - shstrtab
	db      ".shstrtab", 0

  .interp_idx equ $ - shstrtab
	db      ".interp", 0

  .dynsym_idx equ $ - shstrtab
	db      ".dynsym", 0

  .dynstr_idx equ $ - shstrtab
	db      ".dynstr", 0

  .gnu_version_r_idx equ $ - shstrtab
	db      ".gnu.version_r", 0

  .rel_plt_idx equ $ - shstrtab
	db      ".rel"

  .plt_idx equ $ - shstrtab
	db      ".plt", 0

  .text_idx equ $ - shstrtab
	db      ".text", 0

  .rodata_idx equ $ - shstrtab
	db      ".rodata", 0

  .dynamic_idx equ $ - shstrtab
	db      ".dynamic", 0

  .got_plt_idx equ $ - shstrtab
	db      ".got.plt", 0

shstrtab.size equ $ - shstrtab

align 0x2, db 0x00

; === [ Section headers ] ======================================================

; 00003070

; Section header types.
SHT_NULL        equ 0          ; inactive
SHT_PROGBITS    equ 1          ; program defined information
SHT_STRTAB      equ 3          ; string table section
SHT_DYNAMIC     equ 6          ; dynamic section
SHT_REL         equ 9          ; relocation section - no addends
SHT_DYNSYM      equ 11         ; dynamic symbol table section
SHT_GNU_VERNEED equ 0x6FFFFFFE ; GNU version needs section

; Section header flags.
SHF_WRITE     equ 0x01 ; Section contains writable data.
SHF_ALLOC     equ 0x02 ; Section occupies memory.
SHF_EXECINSTR equ 0x04 ; Section contains instructions.
SHF_INFO_LINK equ 0x40 ; sh_info holds section index.

shdr_off equ data_seg_off + ($ - $$)

shdr:

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 0]                   NULL            00000000 000000 000000 00      0   0  0

  .null:
	dd      0                           ; name:      Section name (index into the section header string table).
	dd      SHT_NULL                    ; type:      Section type.
	dd      0                           ; flags:     Section flags.
	dd      0                           ; addr:      Address in memory image.
	dd      0                           ; off:       Offset in file.
	dd      0                           ; size:      Size in bytes.
	dd      0                           ; link:      Index of a related section.
	dd      0                           ; info:      Depends on section type.
	dd      0                           ; addralign: Alignment in bytes.
	dd      0                           ; entsize:   Size of each entry in section.

shdr.entsize equ $ - shdr

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 1] .interp           PROGBITS        08048134 000134 000013 00   A  0   0  1

  .interp:
	dd      shstrtab.interp_idx         ; name:      Section name (index into the section header string table).
	dd      SHT_PROGBITS                ; type:      Section type.
	dd      SHF_ALLOC                   ; flags:     Section flags.
	dd      interp                      ; addr:      Address in memory image.
	dd      interp_off                  ; off:       Offset in file.
	dd      interp.size                 ; size:      Size in bytes.
	dd      0                           ; link:      Index of a related section.
	dd      0                           ; info:      Depends on section type.
	dd      0x1                         ; addralign: Alignment in bytes.
	dd      0                           ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 2] .dynsym           DYNSYM          08048178 000178 000030 10   A  3   1  4

dynsym_link    equ 3
dynsym_info    equ 1
dynsym_entsize equ 0x10 ; TODO: remove

  .dynsym:
	dd      shstrtab.dynsym_idx         ; name:      Section name (index into the section header string table).
	dd      SHT_DYNSYM                  ; type:      Section type.
	dd      SHF_ALLOC                   ; flags:     Section flags.
	dd      dynsym                      ; addr:      Address in memory image.
	dd      dynsym_off                  ; off:       Offset in file.
	dd      dynsym.size                 ; size:      Size in bytes.
	dd      dynsym_link                 ; link:      Index of a related section.
	dd      dynsym_info                 ; info:      Depends on section type.
	dd      0x4                         ; addralign: Alignment in bytes.
	dd      dynsym_entsize              ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 3] .dynstr           STRTAB          080481a8 0001a8 000021 00   A  0   0  1

  .dynstr:
	dd      shstrtab.dynstr_idx         ; name:      Section name (index into the section header string table).
	dd      SHT_STRTAB                  ; type:      Section type.
	dd      SHF_ALLOC                   ; flags:     Section flags.
	dd      dynstr                      ; addr:      Address in memory image.
	dd      dynstr_off                  ; off:       Offset in file.
	dd      dynstr.size                 ; size:      Size in bytes.
	dd      0                           ; link:      Index of a related section.
	dd      0                           ; info:      Depends on section type.
	dd      0x1                         ; addralign: Alignment in bytes.
	dd      0                           ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 4] .gnu.version_r    VERNEED         080481d0 0001d0 000020 00   A  3   1  4

gnu_version_r_link equ 3
gnu_version_r_info equ 1

  .gnu_version_r:
	dd      shstrtab.gnu_version_r_idx  ; name:      Section name (index into the section header string table).
	dd      SHT_GNU_VERNEED             ; type:      Section type.
	dd      SHF_ALLOC                   ; flags:     Section flags.
	dd      gnu_version_r               ; addr:      Address in memory image.
	dd      gnu_version_r_off           ; off:       Offset in file.
	dd      gnu_version_r.size          ; size:      Size in bytes.
	dd      gnu_version_r_link          ; link:      Index of a related section.
	dd      gnu_version_r_info          ; info:      Depends on section type.
	dd      0x4                         ; addralign: Alignment in bytes.
	dd      0                           ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 5] .rel.plt          REL             080481f0 0001f0 000010 08  AI  2  10  4

rel_plt_link    equ 2
rel_plt_info    equ 10
rel_plt_entsize equ 8  ; TODO: remove

  .rel_plt:
	dd      shstrtab.rel_plt_idx        ; name:      Section name (index into the section header string table).
	dd      SHT_REL                     ; type:      Section type.
	dd      SHF_ALLOC | SHF_INFO_LINK   ; flags:     Section flags.
	dd      rel_plt                     ; addr:      Address in memory image.
	dd      rel_plt_off                 ; off:       Offset in file.
	dd      rel_plt.size                ; size:      Size in bytes.
	dd      rel_plt_link                ; link:      Index of a related section.
	dd      rel_plt_info                ; info:      Depends on section type.
	dd      0x4                         ; addralign: Alignment in bytes.
	dd      rel_plt_entsize             ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 6] .plt              PROGBITS        08049000 001000 000030 04  AX  0   0 16

plt_entsize equ 4 ; TODO: remove

  .plt:
	dd      shstrtab.plt_idx            ; name:      Section name (index into the section header string table).
	dd      SHT_PROGBITS                ; type:      Section type.
	dd      SHF_ALLOC | SHF_EXECINSTR   ; flags:     Section flags.
	dd      plt                         ; addr:      Address in memory image.
	dd      plt_off                     ; off:       Offset in file.
	dd      plt.size                    ; size:      Size in bytes.
	dd      0                           ; link:      Index of a related section.
	dd      0                           ; info:      Depends on section type.
	dd      0x10                        ; addralign: Alignment in bytes.
	dd      plt_entsize                 ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 7] .text             PROGBITS        08049030 001030 000018 00  AX  0   0 16

  .text:
	dd      shstrtab.text_idx           ; name:      Section name (index into the section header string table).
	dd      SHT_PROGBITS                ; type:      Section type.
	dd      SHF_ALLOC | SHF_EXECINSTR   ; flags:     Section flags.
	dd      text                        ; addr:      Address in memory image.
	dd      text_off                    ; off:       Offset in file.
	dd      text.size                   ; size:      Size in bytes.
	dd      0                           ; link:      Index of a related section.
	dd      0                           ; info:      Depends on section type.
	dd      0x10                        ; addralign: Alignment in bytes.
	dd      0                           ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 8] .rodata           PROGBITS        0804a000 002000 00000d 00   A  0   0  4

  .rodata:
	dd      shstrtab.rodata_idx        ; name:      Section name (index into the section header string table).
	dd      SHT_PROGBITS                ; type:      Section type.
	dd      SHF_ALLOC                   ; flags:     Section flags.
	dd      rodata                      ; addr:      Address in memory image.
	dd      rodata_off                  ; off:       Offset in file.
	dd      rodata.size                 ; size:      Size in bytes.
	dd      0                           ; link:      Index of a related section.
	dd      0                           ; info:      Depends on section type.
	dd      0x4                         ; addralign: Alignment in bytes.
	dd      0                           ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 9] .dynamic          DYNAMIC         0804bf58 002f58 0000a8 08  WA  3   0  4

dynamic_link    equ 3
dynamic_entsize equ 8 ; TODO: remove

  .dynamic:
	dd      shstrtab.dynamic_idx        ; name:      Section name (index into the section header string table).
	dd      SHT_DYNAMIC                 ; type:      Section type.
	dd      SHF_WRITE | SHF_ALLOC       ; flags:     Section flags.
	dd      dynamic                     ; addr:      Address in memory image.
	dd      dynamic_off                 ; off:       Offset in file.
	dd      dynamic.size                ; size:      Size in bytes.
	dd      dynamic_link                ; link:      Index of a related section.
	dd      0                           ; info:      Depends on section type.
	dd      0x4                         ; addralign: Alignment in bytes.
	dd      dynamic_entsize             ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [10] .got.plt          PROGBITS        0804c000 003000 000014 04  WA  0   0  4

got_plt_entsize equ 4 ; TODO: remove

  .got_plt:
	dd      shstrtab.got_plt_idx        ; name:      Section name (index into the section header string table).
	dd      SHT_PROGBITS                ; type:      Section type.
	dd      SHF_WRITE | SHF_ALLOC       ; flags:     Section flags.
	dd      got_plt                     ; addr:      Address in memory image.
	dd      got_plt_off                 ; off:       Offset in file.
	dd      got_plt.size                ; size:      Size in bytes.
	dd      0                           ; link:      Index of a related section.
	dd      0                           ; info:      Depends on section type.
	dd      0x4                         ; addralign: Alignment in bytes.
	dd      got_plt_entsize             ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [11] .shstrtab         STRTAB          00000000 003014 00005b 00      0   0  1

  .shstrtab:
	dd      shstrtab.shstrtab_idx       ; name:      Section name (index into the section header string table).
	dd      SHT_STRTAB                  ; type:      Section type.
	dd      0x0                         ; flags:     Section flags.
	dd      0                           ; addr:      Address in memory image.
	dd      shstrtab_off                ; off:       Offset in file.
	dd      shstrtab.size               ; size:      Size in bytes.
	dd      0                           ; link:      Index of a related section.
	dd      0                           ; info:      Depends on section type.
	dd      0x1                         ; addralign: Alignment in bytes.
	dd      0                           ; entsize:   Size of each entry in section.

shdr.size  equ $ - shdr
shdr.count equ shdr.size / shdr.entsize
