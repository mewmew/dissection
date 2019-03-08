all: e32

%: %.asm
	nasm -f bin -o $@ $<
	chmod +x $@

.PHONY: all clean

clean:
	$(RM) -v e32
