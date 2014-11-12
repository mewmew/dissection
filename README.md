dissection
==========

This project contains the dissection of a simple _"hello world"_ ELF executable and presents a color-coded representation of its contents. Each file offset of the executable consists of 8 bytes and is denoted in the image below with a darker shade of the color used by its corresponding target segment, section or program header. Starting at the middle of the ELF file header, at offset `0x20`, is the file offset (red) to the program table (bright red). The program table contains five program headers which specify the size and file offsets of two sections and three segments, namely the `.interp` (gray) and the `.dynamic` (purple) sections, and a _read-only_ (blue), a _read-write_ (green) and a _read-execute_ (yellow) segment.

![Color-coded file contents](https://raw.github.com/mewrev/dissection/master/elf.png)

public domain
-------------

This code is hereby released into the *[public domain][]*.

[public domain]: https://creativecommons.org/publicdomain/zero/1.0/
