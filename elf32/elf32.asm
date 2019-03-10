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
ELFCLASS32 equ 1 ; 32-bit object

; Data encodings.
ELFDATA2LSB equ 1 ; 2's complement with little-endian encoding

; Object file types.
ET_EXEC equ 2 ; Executable file

; Architecture.
EM_386 equ 3 ; Intel i386

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
	dd      0                         ; shoff: Section header table file offset
	dd      0                         ; flags: Processor-specific flags
	dw      ehdr.size                 ; ehsize: ELF header size in bytes
	dw      phdr.entsize              ; phentsize: Program header table entry size
	dw      phdr.count                ; phnum: Program header table entry count
	dw      0                         ; shentsize: Section header table entry size
	dw      0                         ; shnum: Section header table entry count
	dw      0                         ; shstrndx: Section header string table index

.size equ $ - ehdr

; === [/ ELF file header ] =====================================================

; === [ Program headers ] ======================================================

; Segment types.
PT_LOAD    equ 1 ; Loadable program segment
PT_DYNAMIC equ 2 ; Dynamic linking information
PT_INTERP  equ 3 ; Program interpreter

; Segment flags.
PF_R equ 0x4 ; Segment is readable
PF_W equ 0x2 ; Segment is writable
PF_X equ 0x1 ; Segment is executable

phdr_off equ phdr - BASE_R_SEG

phdr:

; --- [ Interpreter program header ] -------------------------------------------

  .interp:
	dd      PT_INTERP                ; type: Segment type
	dd      interp_off               ; offset: Segment file offset
	dd      interp                   ; vaddr: Segment virtual address
	dd      interp                   ; paddr: Segment physical address
	dd      interp.size              ; filesz: Segment size in file
	dd      interp.size              ; memsz: Segment size in memory
	dd      PF_R                     ; flags: Segment flags
	dd      0x1                      ; align: Segment alignment

.entsize equ $ - phdr

; --- [ Dynamic array program header ] -----------------------------------------

  .dynamic:
	dd      PT_DYNAMIC             ; type: Segment type
	dd      dynamic_off            ; offset: Segment file offset
	dd      dynamic                ; vaddr: Segment virtual address
	dd      dynamic                ; paddr: Segment physical address
	dd      dynamic.size           ; filesz: Segment size in file
	dd      dynamic.size           ; memsz: Segment size in memory
	dd      PF_R                   ; flags: Segment flags
	dd      0x4                    ; align: Segment alignment

; --- [ Read-only segment program header ] -------------------------------------

  .r_seg:
	dd      PT_LOAD                  ; type: Segment type
	dd      r_seg_off                ; offset: Segment file offset
	dd      r_seg                    ; vaddr: Segment virtual address
	dd      r_seg                    ; paddr: Segment physical address
	dd      r_seg.size               ; filesz: Segment size in file
	dd      r_seg.size               ; memsz: Segment size in memory
	dd      PF_R                     ; flags: Segment flags
	dd      PAGE                     ; align: Segment alignment

; --- [ Read-write segment program header ] ------------------------------------

  .rw_seg:
	dd      PT_LOAD                  ; type: Segment type
	dd      rw_seg_off               ; offset: Segment file offset
	dd      rw_seg                   ; vaddr: Segment virtual address
	dd      rw_seg                   ; paddr: Segment physical address
	dd      rw_seg.size              ; filesz: Segment size in file
	dd      rw_seg.size              ; memsz: Segment size in memory
	dd      PF_R | PF_W              ; flags: Segment flags
	dd      PAGE                     ; align: Segment alignment

; --- [ Executable segment program header ] ------------------------------------

  .rx_seg:
	dd      PT_LOAD                  ; type: Segment type
	dd      rx_seg_off               ; offset: Segment file offset
	dd      rx_seg                   ; vaddr: Segment virtual address
	dd      rx_seg                   ; paddr: Segment physical address
	dd      rx_seg.size              ; filesz: Segment size in file
	dd      rx_seg.size              ; memsz: Segment size in memory
	dd      PF_R | PF_X              ; flags: Segment flags
	dd      PAGE                     ; align: Segment alignment

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
DT_NULL     equ 0  ; Marks the end of the dynamic array
DT_NEEDED   equ 1  ; String table offset of a required library
DT_PLTGOT   equ 3  ; Address of the PLT and/or GOT
DT_STRTAB   equ 5  ; Address of the string table
DT_SYMTAB   equ 6  ; Address of the symbol table
DT_JMPREL   equ 23 ; Address of the relocation entities of the PLT

dynamic_off equ dynamic - BASE_R_SEG

dynamic:

  .strtab:
	dd      DT_STRTAB              ; tag: Dynamic entry type
	dd      dynstr                 ; val: Integer or address value

.entsize equ $ - dynamic

  .symtab:
	dd      DT_SYMTAB              ; tag: Dynamic entry type
	dd      dynsym                 ; val: Integer or address value

  .jmprel:
	dd      DT_JMPREL              ; tag: Dynamic entry type
	dd      rel_plt                ; val: Integer or address value

  .pltgot:
	dd      DT_PLTGOT              ; tag: Dynamic entry type
	dd      got_plt                ; val: Integer or address value

  .libc:
	dd      DT_NEEDED              ; tag: Dynamic entry type
	dd      dynstr.libc_off        ; val: Integer or address value

  .null:
	dd      DT_NULL                ; tag: Dynamic entry type
	dd      0                      ; val: Integer or address value

.size equ $ - dynamic

; --- [/ .dynamic section ] ----------------------------------------------------

; --- [ .dynstr section ] ------------------------------------------------------

dynstr:

  .libc:
	db      "libc.so.6", 0
  .printf:
	db      "printf", 0
  .exit:
	db      "exit", 0

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
	dd      dynstr.printf_off        ; name: Symbol name (string table offset)
	dd      0                        ; value: Symbol value
	dd      0                        ; size: Symbol size
	db      STB_GLOBAL<<4 | STT_FUNC ; info: Symbol type and binding
	db      STV_DEFAULT              ; other: Symbol visibility
	dw      0                        ; shndx: Section index

.entsize equ $ - dynsym

  .exit:
	dd      dynstr.exit_off          ; name: Symbol name (string table offset)
	dd      0                        ; value: Symbol value
	dd      0                        ; size: Symbol size
	db      STB_GLOBAL<<4 | STT_FUNC ; info: Symbol type and binding
	db      STV_DEFAULT              ; other: Symbol visibility
	dw      0                        ; shndx: Section index

.printf_idx equ (.printf - dynsym) / .entsize
.exit_idx   equ (.exit - dynsym) / .entsize

; --- [/ .dynsym section ] -----------------------------------------------------

; --- [ .rel.plt section ] -----------------------------------------------------

; Relocation types.
R_386_JMP_SLOT equ 7

rel_plt:

  .printf:
	dd      got_plt.printf                         ; offset: Address
	dd      dynsym.printf_idx<<8 | R_386_JMP_SLOT  ; info: Relocation type and symbol index

  .exit:
	dd      got_plt.exit                           ; offset: Address
	dd      dynsym.exit_idx<<8 | R_386_JMP_SLOT    ; info: Relocation type and symbol index

.printf_off equ .printf - rel_plt
.exit_off   equ .exit - rel_plt

; --- [/ .rel.plt section ] ----------------------------------------------------

; --- [ .rodata section ] ------------------------------------------------------

rodata:

  .hello:
	db      "hello world", 10, 0

; --- [/ .rodata section ] -----------------------------------------------------

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

text:

  .start:
	push    rodata.hello   ; arg1, "hello world\n"
	call    plt.printf     ; printf
	add     esp, 4
	push    42             ; arg1, 42
	call    plt.exit       ; exit
	add     esp, 4
	ret

; --- [/ .text section ] -------------------------------------------------------

; === [/ Sections ] ============================================================

rx_seg.size equ $ - rx_seg

; ___ [/ Executable segment ] __________________________________________________
