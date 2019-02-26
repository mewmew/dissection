all: elf hello

elf:
	nasm -f bin -o $@ $@.asm
	chmod +x $@

check: elf
	./elf

hello:
	nasm -f elf64 -o $@.o $@.asm
	ld -I /lib64/ld-linux-x86-64.so.2 -s -o $@ $@.o -lc
	@rm $@.o
	strip -R .hash $@
	strip -R .gnu.version $@
	strip -R .eh_frame $@
	strip -R .shstrtab $@
