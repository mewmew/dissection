all: hello_elf64

%_elf64.o: %.asm
	nasm -f elf64 -o $@ $<

%: %.o
	ld -I /lib64/ld-linux-x86-64.so.2 -s -o $@ $< -lc
	strip -R .hash $@
	strip -R .gnu.hash $@
	strip -R .gnu.version $@
	strip -R .eh_frame $@
	strip -R .shstrtab $@

.PHONY: all clean

clean:
	$(RM) -v *.o
	$(RM) -v hello_elf64
