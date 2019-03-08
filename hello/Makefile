all: hello_32 hello_64 hello_elf32

%_elf32: %_elf32.asm
	nasm -f bin -o $@ $<
	chmod +x $@

%_32.o: %_32.asm
	nasm -f elf32 -o $@ $<

%_64.o: %_64.asm
	nasm -f elf64 -o $@ $<

%_32: %_32.o
	ld -m elf_i386 -I /lib/ld-linux.so.2 -s -o $@ -L/usr/lib32 $< -lc
	strip -R .hash $@
	strip -R .gnu.hash $@
	strip -R .gnu.version $@
	strip -R .eh_frame $@
	strip -R .shstrtab $@

%_64: %_64.o
	ld -I /lib64/ld-linux-x86-64.so.2 -s -o $@ $< -lc
	strip -R .hash $@
	strip -R .gnu.hash $@
	strip -R .gnu.version $@
	strip -R .eh_frame $@
	strip -R .shstrtab $@

.PHONY: all clean

clean:
	$(RM) -v *.o
	$(RM) -v hello_32 hello_64
	$(RM) -v hello_elf32
