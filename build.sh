fasm pixie.asm

ld -o Pixie pixie.o -dynamic-linker /lib64/ld-linux-x86-64.so.2 -L. -lc -lraylib -lm

