FASM = fasm

LD = ld

BIN = Pixie

SOURCES = pixie.asm

OBJ = $(SOURCES:.asm=.o)

LDFLAGS = -dynamic-linker /lib64/ld-linux-x86-64.so.2 -L. -lc -lraylib -lm

$(BIN): $(OBJ)
	$(LD) -o $(BIN) $(OBJ) $(LDFLAGS)

%.o: %.asm
	$(FASM) $<

clean:
	rm -f $(OBJ) $(BIN)
