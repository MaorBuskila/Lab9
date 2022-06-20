
all: myELF

myELF: skeleton.o
	ld -m elf_i386 skeleton.o -o myELF

skeleton.o: skeleton.s
	nasm -f elf32 skeleton.s -o skeleton.o

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean:
	rm -f *.o myELF