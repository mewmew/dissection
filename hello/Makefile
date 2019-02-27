all: hello_elf32 hello_elf64

%_elf32.o: %_elf32.asm
	nasm -f elf32 -o $@ $<

%_elf64.o: %_elf64.asm
	nasm -f elf64 -o $@ $<

%_elf32: %_elf32.o
	ld -m elf_i386 -I /lib/ld-linux.so.2 -s -o $@ -L/usr/lib32 $< -lc
	strip -R .hash $@
	strip -R .gnu.hash $@
	strip -R .gnu.version $@
	strip -R .eh_frame $@
	strip -R .shstrtab $@

%_elf64: %_elf64.o
	ld -I /lib64/ld-linux-x86-64.so.2 -s -o $@ $< -lc
	strip -R .hash $@
	strip -R .gnu.hash $@
	strip -R .gnu.version $@
	strip -R .eh_frame $@
	strip -R .shstrtab $@

.PHONY: all clean

clean:
	$(RM) -v *.o
	$(RM) -v hello_elf32 hello_elf64
