# ───────────────────────────────────────────────
# Project: bidrv32 CPU simulation
# Tools:   iverilog, vvp, gtkwave
# ───────────────────────────────────────────────

# Directories
RTL_DIR    := rtl
TB_DIR     := tb
BUILD_DIR  := build

# Source files
RTL_SRCS   := $(wildcard $(RTL_DIR)/*.sv)
TB_SRCS    := $(wildcard $(TB_DIR)/*.sv)
ALL_SRCS   := $(RTL_SRCS) $(TB_SRCS)

# Top-level testbench module name (must match `module tb_top;` in your TB)
TOP        := tb_top

# Outputs
SIM_BIN    := $(BUILD_DIR)/sim.vvp
WAVE_FILE  := $(BUILD_DIR)/wave.vcd

# iverilog flags
#   -g2012  → enable SystemVerilog 2012 syntax (needed for `logic`, `always_ff`, etc.)
#   -Wall   → show all warnings
#   -s TOP  → specify top module
IVERILOG_FLAGS := -g2012 -Wall -s $(TOP)

# ───────────────────────────────────────────────
# Targets
# ───────────────────────────────────────────────

.PHONY: all sim wave clean help

# Default: compile + run + open waves
all: wave

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile: combine all .sv files into a single simulation binary
$(SIM_BIN): $(ALL_SRCS) | $(BUILD_DIR)
	@echo "▶ Compiling with iverilog..."
	iverilog $(IVERILOG_FLAGS) -o $@ $(ALL_SRCS)
	@echo "✓ Compilation done: $@"

# Simulate: run the compiled binary, which dumps wave.vcd
sim: $(SIM_BIN)
	@echo "▶ Running simulation..."
	cd $(BUILD_DIR) && vvp $(notdir $(SIM_BIN))
	@echo "✓ Simulation done. Waveform: $(WAVE_FILE)"

# View waves: open the generated VCD in GTKWave
wave: sim
	@echo "▶ Opening GTKWave..."
	gtkwave $(WAVE_FILE) &

# Clean: remove all generated files
clean:
	@echo "▶ Cleaning..."
	rm -rf $(BUILD_DIR)
	@echo "✓ Done"

# Help
help:
	@echo "Available targets:"
	@echo "  make        - compile, simulate, and open GTKWave (default)"
	@echo "  make sim    - compile and simulate (no GUI)"
	@echo "  make wave   - same as default"
	@echo "  make clean  - remove build/ directory"
	@echo "  make help   - show this message"