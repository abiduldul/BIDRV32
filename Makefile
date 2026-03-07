#SIMULATION
.PHONY: clean run wave

TARGET = train_fsm
VERILATOR = verilator
CXX = g++
OBJ_DIR = obj_dir
SOURCES = $(TARGET).v
TOP_MODULE = V$(TARGET)

# Flags untuk Verilator
# --cc:      Generate C++ output
# --trace:   Enable VCD tracing
# --exe:     Build an executable
# -Wall:     Enable all warnings
VFLAGS := --cc --trace --exe -Wall

# Flags untuk Compiler C++
# -O3:       Optimasi level 3
# -I:        Sertakan direktori (include path)
CXXFLAGS := -O3 -I/usr/share/verilator/include -I$(OBJ_DIR)
LDFLAGS := -L/usr/share/verilator/include -lverilated -lverilated_vcd_c

# Target default: membangun executable
all: $(OBJ_DIR)/$(TOP_MODULE)

# Aturan untuk menjalankan Verilator dan mengompilasi
$(OBJ_DIR)/$(TOP_MODULE): $(SOURCES) sim_main.cpp
	@echo "Verilating $(SOURCES)..."
	$(VERILATOR) $(VFLAGS) $(SOURCES) --top-module $(TARGET) --exe sim_main.cpp
	@echo "Compiling..."
	make -C $(OBJ_DIR) -f $(TOP_MODULE).mk $(TOP_MODULE)
run: all
	./$(OBJ_DIR)/$(TOP_MODULE)
wave:
	gtkwave waveform.vcd &
clean:
	rm -rf $(OBJ_DIR) *.vcd


# COMP		= riscv-none-elf-
# GCC			= $(COMP)gcc
# OBJDUMP		= $(COMP)objdump
# OBJCOPY		= $(COMP)objcopy
# SIZE		= $(COMP)size
# HEXDUMP		= hexdump
# XXD			= xxd
# MACH		= rv32i
# MABI		= ilp32
# CFLAGS		= -O0 -g -c --specs=nosys.specs -Wall -march=$(MACH)
# LDFLAFGS	= -O0 -g -nostartfiles --specs=nosys.specs -march=$(MACH) -mabi=$(MABI) -Wl,-T,sections.lds,-Map,program.map
# all: boot.o ram_init.o main.o program.elf program.elf.objdump program.elf.lst program.bin program.h size program.hex program.v

# main.o:main.c
# 	$(GCC) $(CFLAGS) -o $@ $^

# boot.o:boot.S
# 	$(GCC) $(CFLAGS) -o $@ $^

# ram_init.o:ram_init.c
# 	$(GCC) $(CFLAGS) -o $@ $^
	
# program.elf:boot.o ram_init.o main.o
# 	$(GCC) $(LDFLAFGS) -o $@ $^
	
# program.elf.objdump:program.elf
# 	$(OBJDUMP) -D $^ > $@

# program.elf.lst:program.elf
# 	$(OBJDUMP) -h $^ > $@

# program.bin:program.elf
# 	$(OBJCOPY) -O binary $^ $@

# program.h:program.bin
# 	$(XXD) -i $^ > $@

# program.hex: program.bin
# 	$(HEXDUMP) -ve '1/4 "%08x\n"' $^ > $@

# program.v: program.hex
# 	python3 hex_to_verilog.py $^
	
# size:program.elf
# 	$(SIZE) $^
	
# clean:
# 	rm -rf *.o *.elf *.objdump *.lst *.map *.bin *.hex *.v program.h