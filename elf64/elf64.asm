BITS 64

%define round(n, r)     (((n + (r - 1)) / r) * r)

; Base addresses.
BASE        equ 0x400000
PAGE        equ 0x1000
BASE_R_SEG  equ BASE
BASE_RW_SEG equ BASE_R_SEG + round(r_seg.size, PAGE)
BASE_X_SEG  equ BASE_RW_SEG + round(rw_seg.size, PAGE)

; ___ [ Read-only segment ] ____________________________________________________

SECTION .rdata vstart=BASE_R_SEG align=1

r_seg_off equ 0

r_seg:

; === [ ELF file header ] ======================================================

; ELF classes.
ELFCLASS64 equ 2 ; 64-bit architecture.

; Data encodings.
ELFDATA2LSB equ 1 ; 2's complement little-endian.

; Object file types.
ET_EXEC equ 2 ; Executable.

; CPU architectures.
EM_X86_64 equ 62 ; AMD x86-64.

ehdr:

	db      0x7F, "ELF"               ; ident.magic: ELF magic number.
	db      ELFCLASS64                ; ident.class: File class.
	db      ELFDATA2LSB               ; ident.data: Data encoding.
	db      1                         ; ident.version: ELF header version.
	db      0, 0, 0, 0, 0, 0, 0, 0, 0 ; ident.pad: Padding.
	dw      ET_EXEC                   ; type: File type.
	dw      EM_X86_64                 ; machine: Machine architecture.
	dd      1                         ; version: ELF format version.
	dq      _text.start               ; entry: Entry point.
	dq      phdr_off                  ; phoff: Program header file offset.
	dq      0                         ; shoff: Section header file offset.
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
	dd      PF_R        ; flags: Segment flags
	dq      interp_off  ; offset: Segment file offset
	dq      interp      ; vaddr: Segment virtual address
	dq      interp      ; paddr: Segment physical address
	dq      interp.size ; filesz: Segment size in file
	dq      interp.size ; memsz: Segment size in memory
	dq      0x1         ; align: Segment alignment

.entsize equ $ - phdr

; --- [ Dynamic array program header ] -----------------------------------------

  .dynamic:
	dd      PT_DYNAMIC    ; type: Segment type
	dd      PF_R          ; flags: Segment flags
	dq      dynamic_off   ; offset: Segment file offset
	dq      dynamic       ; vaddr: Segment virtual address
	dq      dynamic       ; paddr: Segment physical address
	dq      dynamic.size  ; filesz: Segment size in file
	dq      dynamic.size  ; memsz: Segment size in memory
	dq      dynamic_align ; align: Segment alignment

; --- [ Read-only segment program header ] -------------------------------------

  .r_seg:
	dd      PT_LOAD    ; type: Segment type
	dd      PF_R       ; flags: Segment flags
	dq      r_seg_off  ; offset: Segment file offset
	dq      r_seg      ; vaddr: Segment virtual address
	dq      r_seg      ; paddr: Segment physical address
	dq      r_seg.size ; filesz: Segment size in file
	dq      r_seg.size ; memsz: Segment size in memory
	dq      PAGE       ; align: Segment alignment

; --- [ Read-write segment program header ] ------------------------------------

  .rw_seg:
	dd      PT_LOAD     ; type: Segment type
	dd      PF_R | PF_W ; flags: Segment flags
	dq      rw_seg_off  ; offset: Segment file offset
	dq      rw_seg      ; vaddr: Segment virtual address
	dq      rw_seg      ; paddr: Segment physical address
	dq      rw_seg.size ; filesz: Segment size in file
	dq      rw_seg.size ; memsz: Segment size in memory
	dq      PAGE        ; align: Segment alignment

; --- [ Executable segment program header ] ------------------------------------

  .x_seg:
	dd      PT_LOAD     ; type: Segment type
	dd      PF_R | PF_X ; flags: Segment flags
	dq      x_seg_off   ; offset: Segment file offset
	dq      x_seg       ; vaddr: Segment virtual address
	dq      x_seg       ; paddr: Segment physical address
	dq      x_seg.size  ; filesz: Segment size in file
	dq      x_seg.size  ; memsz: Segment size in memory
	dq      PAGE        ; align: Segment alignment

.size  equ $ - phdr
.count equ .size / .entsize

; === [/ Program headers ] =====================================================

; === [ Sections ] =============================================================

; --- [ .interp section ] ------------------------------------------------------

interp_off equ interp - BASE_R_SEG

interp:

	db      "/lib64/ld-linux-x86-64.so.2", 0

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

dynamic_align equ 8

align dynamic_align, db 0x00

dynamic_off equ dynamic - BASE_R_SEG

dynamic:

  .strtab:
	dq      DT_STRTAB ; tag: Entry type.
	dq      dynstr    ; val: Integer/Address value.

.entsize equ $ - dynamic

  .symtab:
	dq      DT_SYMTAB ; tag: Entry type.
	dq      dynsym    ; val: Integer/Address value.

  .jmprel:
	dq      DT_JMPREL ; tag: Entry type.
	dq      rela_plt  ; val: Integer/Address value.

  .pltgot:
	dq      DT_PLTGOT ; tag: Entry type.
	dq      got_plt   ; val: Integer/Address value.

  .libc:
	dq      DT_NEEDED       ; tag: Entry type.
	dq      dynstr.libc_off ; val: Integer/Address value.

  .null:
	dq      DT_NULL ; tag: Entry type.
	dq      0       ; val: Integer/Address value.

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
	db      STT_FUNC | STB_GLOBAL<<4 ; info: Type and binding information.
	db      STV_DEFAULT              ; other: Symbol visibility.
	dw      0                        ; shndx: Section index of symbol.
	dq      0                        ; value: Symbol value.
	dq      0                        ; size: Size of associated object.
.entsize equ $ - dynsym
  .exit:
	dd      dynstr.exit_off          ; name: String table offset of name.
	db      STT_FUNC | STB_GLOBAL<<4 ; info: Type and binding information.
	db      STV_DEFAULT              ; other: Symbol visibility.
	dw      0                        ; shndx: Section index of symbol.
	dq      0                        ; value: Symbol value.
	dq      0                        ; size: Size of associated object.

; libc.so.6
.printf_idx equ (.printf - dynsym) / .entsize
.exit_idx   equ (.exit - dynsym) / .entsize

; --- [/ .dynsym section ] -----------------------------------------------------

; --- [ .rela.plt section ] ----------------------------------------------------

; Relocation types.
R_386_JMP_SLOT equ 7 ; Set GOT entry to code address.

rela_plt:

; libc.so.6
  .printf:
	dq      got_plt.printf                         ; offset: Location to be relocated.
	dq      R_386_JMP_SLOT | dynsym.printf_idx<<32 ; info: Relocation type and symbol index.
	dq      0                                      ; addend: Addend.
  .exit:
	dq      got_plt.exit                           ; offset: Location to be relocated.
	dq      R_386_JMP_SLOT | dynsym.exit_idx<<32   ; info: Relocation type and symbol index.
	dq      0                                      ; addend: Addend.

; --- [/ .rela.plt section ] ---------------------------------------------------

; --- [ .rdata section ] -------------------------------------------------------

_rdata:

  .hello:
	db      "hello world", 10, 0

; --- [/ .rdata section ] ------------------------------------------------------

align PAGE, db 0x00

r_seg.size equ $ - r_seg

; ___ [/ Read-only segment ] ___________________________________________________

; ___ [ Read-write segment ] ___________________________________________________

SECTION .data vstart=BASE_RW_SEG follows=.rdata align=1

rw_seg_off equ r_seg_off + r_seg.size

rw_seg:

; --- [ .got.plt section ] -----------------------------------------------------

got_plt:

  .dynamic:
	dq      dynamic

  .link_map:
	dq      0

  .dl_runtime_resolve:
	dq      0

; libc.so.6
  .printf:
	dq      plt.resolve_printf
  .exit:
	dq      plt.resolve_exit

; --- [/ .got.plt section ] ----------------------------------------------------

align PAGE, db 0x00

rw_seg.size equ $ - rw_seg

; ___ [/ Read-write segment ] __________________________________________________

; ___ [ Executable segment ] ___________________________________________________

SECTION .text vstart=BASE_X_SEG follows=.data align=1

x_seg_off equ rw_seg_off + rw_seg.size

x_seg:

; --- [ .plt section ] ---------------------------------------------------------

plt:

  .resolve:
	push    qword [rel got_plt.link_map]
	jmp     [rel got_plt.dl_runtime_resolve]

; libc.so.6
  .printf:
	jmp     [rel got_plt.printf]
  .resolve_printf:
	push    qword dynsym.printf_idx
	jmp     near .resolve
  .exit:
	jmp     [rel got_plt.exit]
  .resolve_exit:
	push    qword dynsym.exit_idx
	jmp     near .resolve

; --- [/ .plt section ] --------------------------------------------------------

; --- [ .text section ] --------------------------------------------------------

_text:

  .start:
	lea     rdi, [rel _rdata.hello]   ; arg1, "hello world\n"
	call    plt.printf                ; printf
	mov     rdi, 42                   ; arg1, 42
	call    plt.exit                  ; exit
	ret

; --- [/ .text section ] -------------------------------------------------------

; === [/ Sections ] ============================================================

align PAGE, int3

x_seg.size equ $ - x_seg

; ___ [/ Executable segment ] __________________________________________________
