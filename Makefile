FASM = fasm
LD   = ld
STRIP = strip
UPX = upx

MODE ?= debug

SRC_DIR   = src/linux_x64
BUILD_DIR = build/linux_x64
OBJ_DIR   = $(BUILD_DIR)/obj
LIB_DIR   = $(BUILD_DIR)/lib
ASSET_DIR = assets
BUILD_ASSETS = $(BUILD_DIR)/assets
INC_DIR   = $(SRC_DIR)/include
BIN       = $(BUILD_DIR)/Pixie

SOURCES = $(wildcard $(SRC_DIR)/*.asm)
OBJECTS = $(patsubst $(SRC_DIR)/%.asm,$(OBJ_DIR)/%.o,$(SOURCES))

LDFLAGS = -dynamic-linker /lib64/ld-linux-x86-64.so.2 -L$(LIB_DIR) -lraylib -lm -lc --rpath='$$ORIGIN/lib'

all: prep $(BIN)
ifeq ($(MODE),release)
	@$(STRIP) $(BIN) 2>/dev/null || true
	@$(UPX) -q $(BIN) 2>/dev/null || true
	@find $(LIB_DIR) -type l -delete 2>/dev/null || true
endif

prep:
	@mkdir -p $(OBJ_DIR) $(LIB_DIR) $(BUILD_ASSETS)
	@cp -au $(SRC_DIR)/lib/*.so* $(LIB_DIR)/ 2>/dev/null || true
	@cp -ru $(ASSET_DIR)/* $(BUILD_ASSETS)/ 2>/dev/null || true

$(BIN): $(OBJECTS)
	$(LD) -o $@ $(OBJECTS) $(LDFLAGS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm
	$(FASM) $< $@

run: all
	LD_LIBRARY_PATH=$(LIB_DIR) ./$(BIN)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean run prep

