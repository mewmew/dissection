BITS 32

; Base addresses.
BASE        equ 0x400000
PAGE        equ 0x1000
BASE_R_SEG  equ BASE
BASE_RW_SEG equ BASE + 1*PAGE + r_seg.size
BASE_RX_SEG equ BASE + 2*PAGE + r_seg.size + rw_seg.size

; ___ [ Read-only segment ] ____________________________________________________

SECTION .rdata vstart=BASE_R_SEG align=1

r_seg_off equ r_seg - BASE_R_SEG

r_seg:

; === [ ELF file header ] ======================================================

; ELF classes.
ELFCLASS32 equ 1 ; 32-bit architecture.

; Data encodings.
ELFDATA2LSB equ 1 ; 2's complement little-endian.

; Object file types.
ET_EXEC equ 2 ; Executable.

; CPU architectures.
EM_386 equ 3 ; Intel i386.

ehdr:

	db      0x7F, "ELF"               ; ident.magic: ELF magic number.
	db      ELFCLASS32                ; ident.class: File class.
	db      ELFDATA2LSB               ; ident.data: Data encoding.
	db      1                         ; ident.version: ELF header version.
	db      0, 0, 0, 0, 0, 0, 0, 0, 0 ; ident.pad: Padding.
	dw      ET_EXEC                   ; type: File type.
	dw      EM_386                    ; machine: Machine architecture.
	dd      1                         ; version: ELF format version.
	dd      _text.start               ; entry: Entry point.
	dd      phdr_off                  ; phoff: Program header file offset.
	dd      0                         ; shoff: Section header file offset.
	dd      0                         ; flags: Architecture-specific flags.
	dw      ehdr.size                 ; ehsize: Size of ELF header in bytes.
	dw      phdr.entsize              ; phentsize: Size of program header entry.
	dw      phdr.count                ; phnum: Number of program header entries.
	dw      0                         ; shentsize: Size of section header entry.
	dw      0                         ; shnum: Number of section header entries.
	dw      0                         ; shstrndx: Section name strings section.

.size equ $ - ehdr

; === [/ ELF file header ] =====================================================

; === [ Program headers ] ======================================================

; Segment types.
PT_LOAD    equ 1 ; Loadable segment.
PT_DYNAMIC equ 2 ; Dynamic linking information segment.
PT_INTERP  equ 3 ; Pathname of interpreter.

; Segment flags.
PF_R equ 0x4 ; Readable.
PF_W equ 0x2 ; Writable.
PF_X equ 0x1 ; Executable.

phdr_off equ phdr - BASE_R_SEG

phdr:

; --- [ Interpreter program header ] -------------------------------------------

  .interp:
	dd      PT_INTERP   ; type: Segment type
	dd      interp_off  ; offset: Segment file offset
	dd      interp      ; vaddr: Segment virtual address
	dd      interp      ; paddr: Segment physical address
	dd      interp.size ; filesz: Segment size in file
	dd      interp.size ; memsz: Segment size in memory
	dd      PF_R        ; flags: Segment flags
	dd      0x1         ; align: Segment alignment

.entsize equ $ - phdr

; --- [ Dynamic array program header ] -----------------------------------------

  .dynamic:
	dd      PT_DYNAMIC   ; type: Segment type
	dd      dynamic_off  ; offset: Segment file offset
	dd      dynamic      ; vaddr: Segment virtual address
	dd      dynamic      ; paddr: Segment physical address
	dd      dynamic.size ; filesz: Segment size in file
	dd      dynamic.size ; memsz: Segment size in memory
	dd      PF_R         ; flags: Segment flags
	dd      0x4          ; align: Segment alignment

; --- [ Read-only segment program header ] -------------------------------------

  .r_seg:
	dd      PT_LOAD    ; type: Segment type
	dd      r_seg_off  ; offset: Segment file offset
	dd      r_seg      ; vaddr: Segment virtual address
	dd      r_seg      ; paddr: Segment physical address
	dd      r_seg.size ; filesz: Segment size in file
	dd      r_seg.size ; memsz: Segment size in memory
	dd      PF_R       ; flags: Segment flags
	dd      PAGE       ; align: Segment alignment

; --- [ Read-write segment program header ] ------------------------------------

  .rw_seg:
	dd      PT_LOAD     ; type: Segment type
	dd      rw_seg_off  ; offset: Segment file offset
	dd      rw_seg      ; vaddr: Segment virtual address
	dd      rw_seg      ; paddr: Segment physical address
	dd      rw_seg.size ; filesz: Segment size in file
	dd      rw_seg.size ; memsz: Segment size in memory
	dd      PF_R | PF_W ; flags: Segment flags
	dd      PAGE        ; align: Segment alignment

; --- [ Executable segment program header ] ------------------------------------

  .rx_seg:
	dd      PT_LOAD     ; type: Segment type
	dd      rx_seg_off  ; offset: Segment file offset
	dd      rx_seg      ; vaddr: Segment virtual address
	dd      rx_seg      ; paddr: Segment physical address
	dd      rx_seg.size ; filesz: Segment size in file
	dd      rx_seg.size ; memsz: Segment size in memory
	dd      PF_R | PF_X ; flags: Segment flags
	dd      PAGE        ; align: Segment alignment

.size  equ $ - phdr
.count equ .size / .entsize

; === [/ Program headers ] =====================================================

; === [ Sections ] =============================================================

; --- [ .interp section ] ------------------------------------------------------

interp_off equ interp - BASE_R_SEG

interp:

	db      "/lib/ld-linux.so.2", 0

.size equ $ - interp

; --- [/ .interp section ] -----------------------------------------------------

; --- [ .dynamic section ] -----------------------------------------------------

; Dynamic tags.
DT_NULL   equ 0  ; Terminating entry.
DT_NEEDED equ 1  ; String table offset of a needed shared library.
DT_PLTGOT equ 3  ; Processor-dependent address.
DT_STRTAB equ 5  ; Address of string table.
DT_SYMTAB equ 6  ; Address of symbol table.
DT_JMPREL equ 23 ; Address of PLT relocations.

dynamic_off equ dynamic - BASE_R_SEG

dynamic:

  .strtab:
	dd      DT_STRTAB ; tag: Entry type.
	dd      dynstr    ; val: Integer/Address value.

.entsize equ $ - dynamic

  .symtab:
	dd      DT_SYMTAB ; tag: Entry type.
	dd      dynsym    ; val: Integer/Address value.

  .jmprel:
	dd      DT_JMPREL ; tag: Entry type.
	dd      rel_plt   ; val: Integer/Address value.

  .pltgot:
	dd      DT_PLTGOT ; tag: Entry type.
	dd      got_plt   ; val: Integer/Address value.

  .libc:
	dd      DT_NEEDED       ; tag: Entry type.
	dd      dynstr.libc_off ; val: Integer/Address value.

  .null:
	dd      DT_NULL ; tag: Entry type.
	dd      0       ; val: Integer/Address value.

.size equ $ - dynamic

; --- [/ .dynamic section ] ----------------------------------------------------

; --- [ .dynstr section ] ------------------------------------------------------

dynstr:

; libc.so.6
  .libc:
	db      "libc.so.6", 0
  .printf:
	db      "printf", 0
  .exit:
	db      "exit", 0

; libc.so.6
.libc_off   equ .libc - dynstr
.printf_off equ .printf - dynstr
.exit_off   equ .exit - dynstr

; --- [/ .dynstr section ] -----------------------------------------------------

; --- [ .dynsym section ] ------------------------------------------------------

; Symbol bindings.
STB_GLOBAL equ 1 ; Global symbol.

; Symbol types.
STT_FUNC equ 2 ; Function.

; Symbol visibility.
STV_DEFAULT equ 0 ; Default visibility.

dynsym:

; libc.so.6
  .printf:
	dd      dynstr.printf_off        ; name: String table offset of name.
	dd      0                        ; value: Symbol value.
	dd      0                        ; size: Size of associated object.
	db      STT_FUNC | STB_GLOBAL<<4 ; info: Type and binding information.
	db      STV_DEFAULT              ; other: Symbol visibility.
	dw      0                        ; shndx: Section index of symbol.
.entsize equ $ - dynsym
  .exit:
	dd      dynstr.exit_off          ; name: String table offset of name.
	dd      0                        ; value: Symbol value.
	dd      0                        ; size: Size of associated object.
	db      STT_FUNC | STB_GLOBAL<<4 ; info: Type and binding information.
	db      STV_DEFAULT              ; other: Symbol visibility.
	dw      0                        ; shndx: Section index of symbol.

; libc.so.6
.printf_idx equ (.printf - dynsym) / .entsize
.exit_idx   equ (.exit - dynsym) / .entsize

; --- [/ .dynsym section ] -----------------------------------------------------

; --- [ .rel.plt section ] -----------------------------------------------------

; Relocation types.
R_386_JMP_SLOT equ 7 ; Set GOT entry to code address.

rel_plt:

; libc.so.6
  .printf:
	dd      got_plt.printf                        ; offset: Location to be relocated.
	dd      R_386_JMP_SLOT | dynsym.printf_idx<<8 ; info: Relocation type and symbol index.
  .exit:
	dd      got_plt.exit                        ; offset: Location to be relocated.
	dd      R_386_JMP_SLOT | dynsym.exit_idx<<8 ; info: Relocation type and symbol index.

; libc.so.6
.printf_off equ .printf - rel_plt
.exit_off   equ .exit - rel_plt

; --- [/ .rel.plt section ] ----------------------------------------------------

; --- [ .rdata section ] -------------------------------------------------------

_rdata:

  .hello:
	db      "hello world", 10, 0

; --- [/ .rdata section ] ------------------------------------------------------

r_seg.size equ $ - r_seg

; ___ [/ Read-only segment ] ___________________________________________________

; ___ [ Read-write segment ] ___________________________________________________

SECTION .data vstart=BASE_RW_SEG follows=.rdata align=1

rw_seg_off equ rw_seg - BASE_RW_SEG + r_seg.size

rw_seg:

; --- [ .got.plt section ] -----------------------------------------------------

got_plt:

  .dynamic:
	dd      dynamic

  .link_map:
	dd      0

  .dl_runtime_resolve:
	dd      0

; libc.so.6
  .printf:
	dd      plt.resolve_printf
  .exit:
	dd      plt.resolve_exit

; --- [/ .got.plt section ] ----------------------------------------------------

rw_seg.size equ $ - rw_seg

; ___ [/ Read-write segment ] __________________________________________________

; ___ [ Executable segment ] ___________________________________________________

SECTION .text vstart=BASE_RX_SEG follows=.data align=1

rx_seg_off equ rx_seg - BASE_RX_SEG + r_seg.size + rw_seg.size

rx_seg:

; --- [ .plt section ] ---------------------------------------------------------

plt:

  .resolve:
	push    dword [got_plt.link_map]
	jmp     [got_plt.dl_runtime_resolve]

; libc.so.6
  .printf:
	jmp     [got_plt.printf]
  .resolve_printf:
	push    dword rel_plt.printf_off
	jmp     near .resolve
  .exit:
	jmp     [got_plt.exit]
  .resolve_exit:
	push    dword rel_plt.exit_off
	jmp     near .resolve

; --- [/ .plt section ] --------------------------------------------------------

; --- [ .text section ] --------------------------------------------------------

_text:

  .start:
	push    _rdata.hello   ;    arg1, "hello world\n"
	call    plt.printf     ; printf
	add     esp, 4
	push    42             ;    arg1, 42
	call    plt.exit       ; exit
	add     esp, 4
	ret

; --- [/ .text section ] -------------------------------------------------------

; === [/ Sections ] ============================================================

rx_seg.size equ $ - rx_seg

; ___ [/ Executable segment ] __________________________________________________
