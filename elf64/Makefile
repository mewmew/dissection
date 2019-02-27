all: elf64

%: %.asm
	nasm -f bin -o $@ $<
	chmod +x $@

.PHONY: all clean

clean:
	$(RM) -v elf64
