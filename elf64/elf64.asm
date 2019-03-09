BITS 64

; Base addresses.
BASE        equ 0x400000
PAGE        equ 0x1000
BASE_RODATA equ BASE
BASE_DATA   equ BASE + 1*PAGE + rodata_seg.size
BASE_CODE   equ BASE + 2*PAGE + rodata_seg.size + data_seg.size

; ___ [ Read-only data segment ] _______________________________________________

SECTION .rdata vstart=BASE_RODATA align=1

rodata_seg:

; === [ ELF file header ] ======================================================

; ELF classes.
ELFCLASS64 equ 2 ; 64-bit object

; Data encodings.
ELFDATA2LSB equ 1 ; 2's complement with little-endian encoding

; Object file types.
ET_EXEC equ 2 ; Executable file

; Architecture.
EM_X86_64 equ 62 ; AMD x86-64 architecture

ehdr:

	db      0x7F, "ELF"               ; ident.magic: ELF magic number
	db      ELFCLASS64                ; ident.class: File class
	db      ELFDATA2LSB               ; ident.data: Data encoding
	db      1                         ; ident.version: ELF header version
	db      0, 0, 0, 0, 0, 0, 0, 0, 0 ; ident.pad: Padding
	dw      ET_EXEC                   ; type: Object file type
	dw      EM_X86_64                 ; machine: Architecture
	dd      1                         ; version: Object file version
	dq      text.start                ; entry: Entry point virtual address
	dq      phdr - BASE_RODATA        ; phoff: Program header table file offset
	dq      0                         ; shoff: Section header table file offset
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
PF_X equ 0x1 ; Segment is executable
PF_W equ 0x2 ; Segment is writable
PF_R equ 0x4 ; Segment is readable

phdr:

; --- [ Interpreter program header ] -------------------------------------------

  .interp:
	dd      PT_INTERP                ; type: Segment type
	dd      PF_R                     ; flags: Segment flags
	dq      interp - BASE_RODATA     ; offset: Segment file offset
	dq      interp                   ; vaddr: Segment virtual address
	dq      interp                   ; paddr: Segment physical address
	dq      interp.size              ; filesz: Segment size in file
	dq      interp.size              ; memsz: Segment size in memory
	dq      0x1                      ; align: Segment alignment

.entsize equ $ - phdr

; --- [ Dynamic array program header ] -----------------------------------------

  .dynamic:
	dd      PT_DYNAMIC             ; type: Segment type
	dd      PF_R                   ; flags: Segment flags
	dq      dynamic - BASE_RODATA  ; offset: Segment file offset
	dq      dynamic                ; vaddr: Segment virtual address
	dq      dynamic                ; paddr: Segment physical address
	dq      dynamic.size           ; filesz: Segment size in file
	dq      dynamic.size           ; memsz: Segment size in memory
	dq      0x8                    ; align: Segment alignment

; --- [ Read-only data segment program header ] --------------------------------

  .rodata_seg:
	dd      PT_LOAD                  ; type: Segment type
	dd      PF_R                     ; flags: Segment flags
	dq      rodata_seg - BASE_RODATA ; offset: Segment file offset
	dq      rodata_seg               ; vaddr: Segment virtual address
	dq      rodata_seg               ; paddr: Segment physical address
	dq      rodata_seg.size          ; filesz: Segment size in file
	dq      rodata_seg.size          ; memsz: Segment size in memory
	dq      PAGE                     ; align: Segment alignment

; --- [ Data segment program header ] ------------------------------------------

data_seg_off equ data_seg - BASE_DATA + rodata_seg.size

  .data_seg:
	dd      PT_LOAD                  ; type: Segment type
	dd      PF_R | PF_W              ; flags: Segment flags
	dq      data_seg_off             ; offset: Segment file offset
	dq      data_seg                 ; vaddr: Segment virtual address
	dq      data_seg                 ; paddr: Segment physical address
	dq      data_seg.size            ; filesz: Segment size in file
	dq      data_seg.size            ; memsz: Segment size in memory
	dq      PAGE                     ; align: Segment alignment

; --- [ Code segment program header ] ------------------------------------------

code_seg_off equ code_seg - BASE_CODE + rodata_seg.size + data_seg.size

  .code_seg:
	dd      PT_LOAD                  ; type: Segment type
	dd      PF_R | PF_X              ; flags: Segment flags
	dq      code_seg_off             ; offset: Segment file offset
	dq      code_seg                 ; vaddr: Segment virtual address
	dq      code_seg                 ; paddr: Segment physical address
	dq      code_seg.size            ; filesz: Segment size in file
	dq      code_seg.size            ; memsz: Segment size in memory
	dq      PAGE                     ; align: Segment alignment

.size  equ $ - phdr
.count equ .size / .entsize

; === [/ Program headers ] =====================================================

; === [ Sections ] =============================================================

; --- [ .interp section ] ------------------------------------------------------

interp:

	db      "/lib64/ld-linux-x86-64.so.2", 0

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

  .strtab:
	dq      DT_STRTAB              ; tag: Dynamic entry type
	dq      dynstr                 ; val: Integer or address value

.entsize equ $ - dynamic

  .symtab:
	dq      DT_SYMTAB              ; tag: Dynamic entry type
	dq      dynsym                 ; val: Integer or address value

  .jmprel:
	dq      DT_JMPREL              ; tag: Dynamic entry type
	dq      rela_plt               ; val: Integer or address value

  .pltgot:
	dq      DT_PLTGOT              ; tag: Dynamic entry type
	dq      got_plt                ; val: Integer or address value

  .libc:
	dq      DT_NEEDED              ; tag: Dynamic entry type
	dq      dynstr.libc_off        ; val: Integer or address value

  .null:
	dq      DT_NULL                ; tag: Dynamic entry type
	dq      0                      ; val: Integer or address value

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
	db      STB_GLOBAL<<4 | STT_FUNC ; info: Symbol type and binding
	db      STV_DEFAULT              ; other: Symbol visibility
	dw      0                        ; shndx: Section index
	dq      0                        ; value: Symbol value
	dq      0                        ; size: Symbol size

.entsize equ $ - dynsym

  .exit:
	dd      dynstr.exit_off          ; name: Symbol name (string table offset)
	db      STB_GLOBAL<<4 | STT_FUNC ; info: Symbol type and binding
	db      STV_DEFAULT              ; other: Symbol visibility
	dw      0                        ; shndx: Section index
	dq      0                        ; value: Symbol value
	dq      0                        ; size: Symbol size

.printf_idx equ (.printf - dynsym) / .entsize
.exit_idx   equ (.exit - dynsym) / .entsize

; --- [/ .dynsym section ] -----------------------------------------------------

; --- [ .rela.plt section ] ----------------------------------------------------

; Relocation types.
R_386_JMP_SLOT equ 7

rela_plt:

  .printf:
	dq      got_plt.printf                         ; offset: Address
	dq      dynsym.printf_idx<<32 | R_386_JMP_SLOT ; info: Relocation type and symbol index
	dq      0                                      ; addend: Addend

  .exit:
	dq      got_plt.exit                           ; offset: Address
	dq      dynsym.exit_idx<<32 | R_386_JMP_SLOT   ; info: Relocation type and symbol index
	dq      0                                      ; addend: Addend

; --- [/ .rela.plt section ] ---------------------------------------------------

; --- [ .rodata section ] ------------------------------------------------------

rodata:

  .hello:
	db      "hello world", 10, 0

; --- [/ .rodata section ] -----------------------------------------------------

rodata_seg.size equ $ - rodata_seg

; ___ [/ Read-only data segment ] ______________________________________________

; ___ [ Data segment ] _________________________________________________________

SECTION .data vstart=BASE_DATA follows=.rdata align=1

data_seg:

; --- [ .got.plt section ] -----------------------------------------------------

got_plt:

  .dynamic:
	dq      dynamic

  .link_map:
	dq      0

  .dl_runtime_resolve:
	dq      0

  .printf:
	dq      plt.resolve_printf

  .exit:
	dq      plt.resolve_exit

; --- [/ .got.plt section ] ----------------------------------------------------

data_seg.size equ $ - data_seg

; ___ [/ Data segment ] ________________________________________________________

; ___ [ Code segment ] _________________________________________________________

SECTION .text vstart=BASE_CODE follows=.data align=1

code_seg:

; --- [ .plt section ] ---------------------------------------------------------

plt:

  .resolve:
	push    qword [rel got_plt.link_map]
	jmp     [rel got_plt.dl_runtime_resolve]

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

text:

  .start:
	lea     rdi, [rel rodata.hello]   ; arg1, "hello world\n"
	call    plt.printf                ; printf
	mov     rdi, 42                   ; arg1, 42
	call    plt.exit                  ; exit
	ret

; --- [/ .text section ] -------------------------------------------------------

; === [/ Sections ] ============================================================

code_seg.size equ $ - code_seg

; ___ [/ Code segment ] ________________________________________________________
