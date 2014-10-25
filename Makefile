all: elf hello

elf:
	nasm -f bin -o $@ $@.asm
	chmod +x $@

hello:
	nasm -f elf64 -o $@.o $@.asm
	ld -s -o $@ $@.o -lc
	strip -R .hash $@
	strip -R .gnu.version $@
	strip -R .eh_frame $@
	strip -R .shstrtab $@
