BITS 32

%define round(n, r)     (((n + (r - 1)) / r) * r)

; Base addresses.
BASE           equ 0x0
PAGE           equ 0x1000
BASE_R_SEG     equ BASE
BASE_X_SEG     equ BASE_R_SEG + round(r_seg.size, PAGE)
BASE_RDATA_SEG equ BASE_X_SEG + round(x_seg.size, PAGE)
BASE_RW_SEG    equ BASE_RDATA_SEG + 0xFA0

; ___ [ Read-only segment ] ____________________________________________________

SECTION .r_seg vstart=BASE_R_SEG align=1

r_seg_off equ 0

r_seg:

; === [ ELF file header ] ======================================================

; ELF classes.
ELFCLASS32 equ 1 ; 32-bit architecture.

; Data encodings.
ELFDATA2LSB equ 1 ; 2's complement little-endian.

; Object file types.
ET_EXEC equ 2 ; Executable.
ET_DYN  equ 3 ; Shared object.

; CPU architectures.
EM_386 equ 3 ; Intel i386.

_text.start equ 0x00001000 ; TODO: remove

shdr.entsize equ 0x28 ; TODO: remove
shdr.count equ 0x08 ; TODO: remove
shdr.shstrtab_idx equ 0x07 ; TODO: remove

ehdr:

	db      0x7F, "ELF"               ; ident.magic: ELF magic number.
	db      ELFCLASS32                ; ident.class: File class.
	db      ELFDATA2LSB               ; ident.data: Data encoding.
	db      1                         ; ident.version: ELF header version.
	db      0, 0, 0, 0, 0, 0, 0, 0, 0 ; ident.pad: Padding.
	dw      ET_DYN                    ; type: File type.
	dw      EM_386                    ; machine: Machine architecture.
	dd      1                         ; version: ELF format version.
	dd      _text.start               ; entry: Entry point.
	dd      phdr_off                  ; phoff: Program header file offset.
	dd      shdr_off                  ; shoff: Section header file offset.
	dd      0                         ; flags: Architecture-specific flags.
	dw      ehdr.size                 ; ehsize: Size of ELF header in bytes.
	dw      phdr.entsize              ; phentsize: Size of program header entry.
	dw      phdr.count                ; phnum: Number of program header entries.
	dw      shdr.entsize              ; shentsize: Size of section header entry.
	dw      shdr.count                ; shnum: Number of section header entries.
	dw      shdr.shstrtab_idx         ; shstrndx: Section name strings section.

.size equ $ - ehdr

; === [/ ELF file header ] =====================================================

; === [ Program headers ] ======================================================

; Segment types.
PT_LOAD    equ 1 ; Loadable segment.
PT_DYNAMIC equ 2 ; Dynamic linking information segment.

; Segment flags.
PF_R equ 0x4 ; Readable.
PF_W equ 0x2 ; Writable.
PF_X equ 0x1 ; Executable.

phdr_off equ phdr - BASE_R_SEG

phdr:

; --- [ Read-only segment program header ] -------------------------------------

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x000000 0x00000000 0x00000000 0x0014d 0x0014d R   0x1000

  .r_seg:
	dd      PT_LOAD    ; type: Segment type
	dd      r_seg_off  ; offset: Segment file offset
	dd      r_seg      ; vaddr: Segment virtual address
	dd      r_seg      ; paddr: Segment physical address
	dd      r_seg.size ; filesz: Segment size in file
	dd      r_seg.size ; memsz: Segment size in memory
	dd      PF_R       ; flags: Segment flags
	dd      PAGE       ; align: Segment alignment

.entsize equ $ - phdr

; --- [ Executable segment program header ] ------------------------------------

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x001000 0x00001000 0x00001000 0x00006 0x00006 R E 0x1000

  .x_seg:
	dd      PT_LOAD     ; type: Segment type
	dd      x_seg_off   ; offset: Segment file offset
	dd      x_seg       ; vaddr: Segment virtual address
	dd      x_seg       ; paddr: Segment physical address
	dd      x_seg.size  ; filesz: Segment size in file
	dd      x_seg.size  ; memsz: Segment size in memory
	dd      PF_R | PF_X ; flags: Segment flags
	dd      PAGE        ; align: Segment alignment

; --- [ .rdata segment program header ] ----------------------------------------

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x002000 0x00002000 0x00002000 0x00000 0x00000 R   0x1000

  .rdata_seg:
	dd      PT_LOAD        ; type: Segment type
	dd      rdata_seg_off  ; offset: Segment file offset
	dd      rdata_seg      ; vaddr: Segment virtual address
	dd      rdata_seg      ; paddr: Segment physical address
	dd      rdata_seg.size ; filesz: Segment size in file
	dd      rdata_seg.size ; memsz: Segment size in memory
	dd      PF_R           ; flags: Segment flags
	dd      PAGE           ; align: Segment alignment

; --- [ Read-write segment program header ] ------------------------------------

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  LOAD           0x002fa0 0x00002fa0 0x00002fa0 0x00060 0x00060 RW  0x1000

  .rw_seg:
	dd      PT_LOAD     ; type: Segment type
	dd      rw_seg_off  ; offset: Segment file offset
	dd      rw_seg      ; vaddr: Segment virtual address
	dd      rw_seg      ; paddr: Segment physical address
	dd      rw_seg.size ; filesz: Segment size in file
	dd      rw_seg.size ; memsz: Segment size in memory
	dd      PF_R | PF_W ; flags: Segment flags
	dd      PAGE        ; align: Segment alignment

; --- [ Dynamic array program header ] -----------------------------------------

;  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
;  DYNAMIC        0x002fa0 0x00002fa0 0x00002fa0 0x00060 0x00060 RW  0x4

  .dynamic:
	dd      PT_DYNAMIC    ; type: Segment type
	dd      dynamic_off   ; offset: Segment file offset
	dd      dynamic       ; vaddr: Segment virtual address
	dd      dynamic       ; paddr: Segment physical address
	dd      dynamic.size  ; filesz: Segment size in file
	dd      dynamic.size  ; memsz: Segment size in memory
	dd      PF_R | PF_W   ; flags: Segment flags
	dd      dynamic_align ; align: Segment alignment

.size  equ $ - phdr
.count equ .size / .entsize

; === [/ Program headers ] =====================================================

; 000000d4
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; |................|
; 000000e0
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; |................|
; 000000f0
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; |................|
; 00000100
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00 ; |................|
; 00000110
db 0x01, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00 ; |................|
; 00000120
db 0x01, 0x00, 0x00, 0x00, 0x89, 0x73, 0x88, 0x0b


; --- [ .dynsym section ] ------------------------------------------------------

dynsym_off equ $ - BASE_R_SEG

STT_NOTYPE equ 0 ; Unspecified type.
STT_FUNC   equ 2 ; Function.

STB_LOCAL  equ 0 ; Local symbol
STB_GLOBAL equ 1 ; Global symbol

STV_DEFAULT equ 0 ; Default visibility (see binding).

; 00000128

dynsym:

;   Num:    Value  Size Type    Bind   Vis      Ndx Name
;     0: 00000000     0 NOTYPE  LOCAL  DEFAULT  UND

  .null:
	dd      dynstr.null_off           ; name: String table index of name.
	dd      0                         ; value: Symbol value.
	dd      0                         ; size: Size of associated object.
	db      STB_LOCAL<<4 | STT_NOTYPE ; info: Type and binding information.
	db      STV_DEFAULT               ; other: Reserved (not used).
	dw      0                         ; shndx: Section index of symbol.

.entsize equ $ - dynsym

;   Num:    Value  Size Type    Bind   Vis      Ndx Name
;     1: 00001000     0 NOTYPE  GLOBAL DEFAULT    5 foo

; TODO: figure out why section index 5 (i.e. .eh_frame_idx) is used.

  .foo:
	dd      dynstr.foo_off             ; name: String table index of name.
	dd      0x1000                     ; value: Symbol value.
	dd      0                          ; size: Size of associated object.
	db      STB_GLOBAL<<4 | STT_NOTYPE ; info: Type and binding information.
	db      STV_DEFAULT                ; other: Reserved (not used).
	dw      shdr.eh_frame_idx          ; shndx: Section index of symbol.

.foo_idx equ (.foo - dynsym) / .entsize

dynsym.size equ $ - dynsym

; --- [/ .dynsym section ] -----------------------------------------------------

; --- [ .dynstr section ] ------------------------------------------------------

dynstr_off equ $ - BASE_R_SEG

; 000001a8

dynstr:

  .null:
	db      0

  .foo:
	db      "foo", 0

.null_off equ .null - dynstr ; 0
.foo_off  equ .foo - dynstr  ; 1

dynstr.size equ $ - dynstr

; --- [/ .dynstr section ] -----------------------------------------------------

r_seg.size equ $ - r_seg

align PAGE, db 0x00

; ___ [/ Read-only segment ] ___________________________________________________

; ___ [ Executable segment ] ___________________________________________________

SECTION .x_seg vstart=BASE_X_SEG follows=.r_seg align=1

x_seg_off equ r_seg_off + round(r_seg.size, PAGE)

x_seg:

; --- [ .text section ] --------------------------------------------------------

text_off equ x_seg_off

; 00001000

text:

  .start:
	mov     eax, 42
	ret

text.size equ $ - text

; --- [/ .text section ] -------------------------------------------------------

x_seg.size equ $ - x_seg

align PAGE, db 0x00

; ___ [/ Executable segment ] __________________________________________________

; ___ [ .rdata segment? ] ______________________________________________________

SECTION .rdata_seg vstart=BASE_RDATA_SEG follows=.x_seg align=1

rdata_seg_off equ x_seg_off + round(x_seg.size, PAGE)

rdata_seg:

; --- [ .eh_frame section ] ----------------------------------------------------

eh_frame_off equ rdata_seg_off

; 00002000

eh_frame:
	; no data

eh_frame.size equ $ - eh_frame

; --- [/ .eh_frame section ] ---------------------------------------------------

rdata_seg.size equ $ - rdata_seg

times (0x2FA0 - 0x2000) db 0x00 ; padding

; ___ [/ .rdata segment? ] _____________________________________________________

; ___ [ Read-write segment ] ___________________________________________________

SECTION .rw_seg vstart=BASE_RW_SEG follows=.rdata_seg align=1

rw_seg_off equ rdata_seg_off + 0xFA0

rw_seg:

; --- [ .dynamic section ] -----------------------------------------------------

; Dynamic tags.
DT_NULL     equ 0          ; Terminating entry.
DT_NEEDED   equ 1          ; String table offset of a needed shared library.
DT_HASH     equ 4          ; Address of symbol hash table.
DT_PLTGOT   equ 3          ; Processor-dependent address.
DT_STRTAB   equ 5          ; Address of string table.
DT_SYMTAB   equ 6          ; Address of symbol table.
DT_STRSZ    equ 10         ; Size of string table.
DT_SYMENT   equ 11         ; Size of each symbol table entry.
DT_JMPREL   equ 23         ; Address of PLT relocations.
DT_GNU_HASH equ 0x6FFFFEF5 ; Address of GNU symbol hash table.

dynamic_align equ 4

align dynamic_align, db 0x00

dynamic_off equ dynamic - BASE_R_SEG

dynamic:

;  Tag        Type                         Name/Value
; 0x00000004 (HASH)                       0xf4

hash equ 0xf4 ; TODO: remove

  .hash:
	dd      DT_HASH ; tag: Entry type.
	dd      hash    ; val: Integer/Address value.

.entsize equ $ - dynamic

;  Tag        Type                         Name/Value
; 0x6ffffef5 (GNU_HASH)                   0x108

gnu_hash equ 0x108 ; TODO: remove

  .gnu_hash:
	dd      DT_GNU_HASH ; tag: Entry type.
	dd      gnu_hash    ; val: Integer/Address value.

;  Tag        Type                         Name/Value
; 0x00000005 (STRTAB)                     0x148

  .strtab:
	dd      DT_STRTAB ; tag: Entry type.
	dd      dynstr    ; val: Integer/Address value.

;  Tag        Type                         Name/Value
; 0x00000006 (SYMTAB)                     0x128

  .symtab:
	dd      DT_SYMTAB ; tag: Entry type.
	dd      dynsym    ; val: Integer/Address value.

;  Tag        Type                         Name/Value
; 0x0000000a (STRSZ)                      5 (bytes)

  .strsz:
	dd      DT_STRSZ    ; tag: Entry type.
	dd      dynstr.size ; val: Integer/Address value.

;  Tag        Type                         Name/Value
; 0x0000000b (SYMENT)                     16 (bytes)

dynsym.entsize equ 16 ; TODO: remove

  .syment:
	dd      DT_SYMENT      ; tag: Dynamic entry type
	dd      dynsym.entsize ; val: Integer or address value

;  Tag        Type                         Name/Value
; 0x00000000 (NULL)                       0x0

  .null:
	dd      DT_NULL ; tag: Entry type.
	dd      0       ; val: Integer/Address value.

times (0x3000 - 0x2FD8) db 0x00 ; padding

.size equ $ - dynamic

; --- [/ .dynamic section ] ----------------------------------------------------

rw_seg.size equ $ - rw_seg

; ___ [/ Read-write segment ] __________________________________________________

; --- [ .shstrtab section ] ----------------------------------------------------

shstrtab_off equ rw_seg_off + rw_seg.size

; 00003000

shstrtab:

  .null:
	db 0

  .shstrtab_off equ $ - shstrtab
	db      ".shstrtab", 0

  .gnu_hash_off equ $ - shstrtab
	db      ".gnu.hash", 0

  .dynsym_off equ $ - shstrtab
	db      ".dynsym", 0

  .dynstr_off equ $ - shstrtab
	db      ".dynstr", 0

  .text_off equ $ - shstrtab
	db      ".text", 0

  .eh_frame_off equ $ - shstrtab
	db      ".eh_frame", 0

  .dynamic_off equ $ - shstrtab
	db      ".dynamic", 0

shstrtab.size equ $ - shstrtab

; --- [/ .shstrtab section ] ---------------------------------------------------

align 0x4, db 0x00

; === [ Section headers ] ======================================================

; 00003040

; Section header types.
SHT_NULL        equ 0          ; inactive
SHT_PROGBITS    equ 1          ; program defined information
SHT_STRTAB      equ 3          ; string table section
SHT_DYNAMIC     equ 6          ; dynamic section
SHT_REL         equ 9          ; relocation section - no addends
SHT_DYNSYM      equ 11         ; dynamic symbol table section
SHT_GNU_HASH    equ 0x6FFFFFF6 ; GNU hash table
SHT_GNU_VERNEED equ 0x6FFFFFFE ; GNU version needs section

; Section header flags.
SHF_WRITE     equ 0x01 ; Section contains writable data.
SHF_ALLOC     equ 0x02 ; Section occupies memory.
SHF_EXECINSTR equ 0x04 ; Section contains instructions.
SHF_INFO_LINK equ 0x40 ; sh_info holds section index.

shdr_off equ shstrtab_off + round(shstrtab.size, 4)

shdr:

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 0]                   NULL            00000000 000000 000000 00      0   0  0

  .null:
	dd      0        ; name:      Section name (index into the section header string table).
	dd      SHT_NULL ; type:      Section type.
	dd      0        ; flags:     Section flags.
	dd      0        ; addr:      Address in memory image.
	dd      0        ; off:       Offset in file.
	dd      0        ; size:      Size in bytes.
	dd      0        ; link:      Index of a related section.
	dd      0        ; info:      Depends on section type.
	dd      0        ; addralign: Alignment in bytes.
	dd      0        ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 1] .gnu.hash         GNU_HASH        00000108 000108 000020 04   A  2   0  4

gnu_hash         equ 0x108 ; TODO: remove
gnu_hash_off     equ 0x108 ; TODO: remove
gnu_hash.size    equ 0x20 ; TODO: remove
gnu_hash.entsize equ 4 ; TODO: remove

  .gnu_hash:
	dd      shstrtab.gnu_hash_off ; name:      Section name (index into the section header string table).
	dd      SHT_GNU_HASH          ; type:      Section type.
	dd      SHF_ALLOC             ; flags:     Section flags.
	dd      gnu_hash              ; addr:      Address in memory image.
	dd      gnu_hash_off          ; off:       Offset in file.
	dd      gnu_hash.size         ; size:      Size in bytes.
	dd      shdr.dynsym_idx       ; link:      Index of a related section.
	dd      0                     ; info:      Depends on section type.
	dd      0x4                   ; addralign: Alignment in bytes.
	dd      gnu_hash.entsize      ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 2] .dynsym           DYNSYM          00000128 000128 000020 10   A  3   1  4

  .dynsym:
	dd      shstrtab.dynsym_off ; name:      Section name (index into the section header string table).
	dd      SHT_DYNSYM          ; type:      Section type.
	dd      SHF_ALLOC           ; flags:     Section flags.
	dd      dynsym              ; addr:      Address in memory image.
	dd      dynsym_off          ; off:       Offset in file.
	dd      dynsym.size         ; size:      Size in bytes.
	dd      shdr.dynstr_idx     ; link:      Index of a related section.
	dd      shdr.gnu_hash_idx   ; info:      Depends on section type.
	dd      0x4                 ; addralign: Alignment in bytes.
	dd      dynsym.entsize      ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 3] .dynstr           STRTAB          00000148 000148 000005 00   A  0   0  1

  .dynstr:
	dd      shstrtab.dynstr_off ; name:      Section name (index into the section header string table).
	dd      SHT_STRTAB          ; type:      Section type.
	dd      SHF_ALLOC           ; flags:     Section flags.
	dd      dynstr              ; addr:      Address in memory image.
	dd      dynstr_off          ; off:       Offset in file.
	dd      dynstr.size         ; size:      Size in bytes.
	dd      0                   ; link:      Index of a related section.
	dd      0                   ; info:      Depends on section type.
	dd      0x1                 ; addralign: Alignment in bytes.
	dd      0                   ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 4] .text             PROGBITS        00001000 001000 000006 00  AX  0   0 16

  .text:
	dd      shstrtab.text_off         ; name:      Section name (index into the section header string table).
	dd      SHT_PROGBITS              ; type:      Section type.
	dd      SHF_ALLOC | SHF_EXECINSTR ; flags:     Section flags.
	dd      text                      ; addr:      Address in memory image.
	dd      text_off                  ; off:       Offset in file.
	dd      text.size                 ; size:      Size in bytes.
	dd      0                         ; link:      Index of a related section.
	dd      0                         ; info:      Depends on section type.
	dd      0x10                      ; addralign: Alignment in bytes.
	dd      0                         ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 5] .eh_frame         PROGBITS        00002000 002000 000000 00   A  0   0  4

  .eh_frame:
	dd      shstrtab.eh_frame_off ; name:      Section name (index into the section header string table).
	dd      SHT_PROGBITS          ; type:      Section type.
	dd      SHF_ALLOC             ; flags:     Section flags.
	dd      eh_frame              ; addr:      Address in memory image.
	dd      eh_frame_off          ; off:       Offset in file.
	dd      eh_frame.size         ; size:      Size in bytes.
	dd      0                     ; link:      Index of a related section.
	dd      0                     ; info:      Depends on section type.
	dd      0x4                   ; addralign: Alignment in bytes.
	dd      0                     ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 6] .dynamic          DYNAMIC         00002fa0 002fa0 000060 08  WA  3   0  4

  .dynamic:
	dd      shstrtab.dynamic_off  ; name:      Section name (index into the section header string table).
	dd      SHT_DYNAMIC           ; type:      Section type.
	dd      SHF_WRITE | SHF_ALLOC ; flags:     Section flags.
	dd      dynamic               ; addr:      Address in memory image.
	dd      dynamic_off           ; off:       Offset in file.
	dd      dynamic.size          ; size:      Size in bytes.
	dd      shdr.dynstr_idx       ; link:      Index of a related section.
	dd      0                     ; info:      Depends on section type.
	dd      0x4                   ; addralign: Alignment in bytes.
	dd      dynamic.entsize       ; entsize:   Size of each entry in section.

;  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
;  [ 7] .shstrtab         STRTAB          00000000 003000 00003e 00      0   0  1

  .shstrtab:
	dd      shstrtab.shstrtab_off ; name:      Section name (index into the section header string table).
	dd      SHT_STRTAB            ; type:      Section type.
	dd      0x0                   ; flags:     Section flags.
	dd      0                     ; addr:      Address in memory image.
	dd      shstrtab_off          ; off:       Offset in file.
	dd      shstrtab.size         ; size:      Size in bytes.
	dd      0                     ; link:      Index of a related section.
	dd      0                     ; info:      Depends on section type.
	dd      0x1                   ; addralign: Alignment in bytes.
	dd      0                     ; entsize:   Size of each entry in section.

.null_idx     equ (.null - shdr) / .entsize
.gnu_hash_idx equ (.gnu_hash - shdr) / .entsize
.dynsym_idx   equ (.dynsym - shdr) / .entsize
.dynstr_idx   equ (.dynstr - shdr) / .entsize
.text_idx     equ (.text - shdr) / .entsize
.eh_frame_idx equ (.eh_frame - shdr) / .entsize
.dynamic_idx  equ (.dynamic - shdr) / .entsize
.shstrtab_idx equ (.shstrtab - shdr) / .entsize

shdr.size  equ $ - shdr
shdr.count equ shdr.size / shdr.entsize

; === [/ Section headers ] =====================================================
