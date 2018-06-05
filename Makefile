rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2)$(filter $(subst *,%,$2),$d))

BUILD_DIR ?= $(shell pwd)/_build
BIN_DIR ?= $(shell pwd)/bin
FBARDUINO_FIRMWARE_SRC_DIR ?= src
FBARDUINO_FIRMWARE_BUILD_DIR ?= $(BUILD_DIR)/sketch
FBARDUINO_FIRMWARE_LIB_BUILD_DIR ?= $(BUILD_DIR)/libraries

ARDUINO_INSTALL_DIR ?= $(HOME)/arduino-1.8.5

# Files to be tracked for make to know to rebuild.
CXX_SRC := $(wildcard $(FBARDUINO_FIRMWARE_SRC_DIR)/*.cpp)
SRC := $(CXX_SRC)
SRC_DEPS := $(SRC) $(wildcard $(FBARDUINO_FIRMWARE_SRC_DIR)/*.h)

# Object files and Dependency files That will eventually be built.
CXX_OBJ := $(CXX_SRC:.cpp=.o)
CXX_D   := $(CXX_SRC:.cpp=.d)
D   := $(patsubst $(FBARDUINO_FIRMWARE_SRC_DIR)/%,$(FBARDUINO_FIRMWARE_BUILD_DIR)/%,$(CXX_D))
OBJ := $(patsubst $(FBARDUINO_FIRMWARE_SRC_DIR)/%,$(FBARDUINO_FIRMWARE_BUILD_DIR)/%,$(CXX_OBJ))

## Commands needed to compile and whatnot.
CXX := $(ARDUINO_INSTALL_DIR)/hardware/tools/avr/bin/avr-g++
CC := $(ARDUINO_INSTALL_DIR)/hardware/tools/avr/bin/avr-gcc
AR := $(ARDUINO_INSTALL_DIR)/hardware/tools/avr/bin/avr-gcc-ar
OBJ_COPY := $(ARDUINO_INSTALL_DIR)/hardware/tools/avr/bin/avr-objcopy
MKDIR_P := mkdir -p

CXX_FLAGS := -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD -flto -mmcu=atmega2560 -DF_CPU=16000000L -DARDUINO=10600 -DARDUINO_AVR_MEGA2560 -DARDUINO_ARCH_AVR
CFLAGS := -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections,--relax -mmcu=atmega2560

# Targets.
ARDUINO_HEX := $(BIN_DIR)/arduino-firmware.hex
ARDUINO_EEP := $(BUILD_DIR)/arduino-firmware.eep
ARDUINO_ELF := $(BUILD_DIR)/arduino-firmware.elf

FARMDUINO_HEX := $(BIN_DIR)/farmduino-firmware.hex
FARMDUINO_V14_HEX := $(BIN_DIR)/farmduino_k14-firmware.hex
BLINK_HEX := $(BIN_DIR)/blink.hex
CLEAR_EEPROM_HEX := $(BIN_DIR)/clear_eeprom.hex

.DEFAULT_GOAL := all

## Dependencies
include lib/core.Makefile
include lib/SPI.Makefile
include lib/Servo.Makefile
include lib/EEPROM.Makefile

.PHONY: all clean \
	dep_core dep_core_clean \
	dep_Servo dep_Servo_clean \
	dep_SPI dep_SPI_clean \
	dep_EEPROM dep_EEPROM_clean

DEPS := $(DEP_CORE) $(DEP_SPI) $(DEP_Servo) $(DEP_EEPROM)
DEPS_CFLAGS := $(DEP_CORE_CFLAGS) $(DEP_SPI_CFLAGS) $(DEP_Servo_CFLAGS) $(DEP_EEPROM_CFLAGS)
DEPS_LDFLAGS := $(DEP_CORE_LDFLAGS) $(DEP_SPI_LDFLAGS) $(DEP_Servo_LDFLAGS) $(DEP_EEPROM_LDFLAGS)

all: $(ARDUINO_HEX)

clean:
	$(RM) $(OBJ)
	$(RM) $(D)

$(ARDUINO_HEX): $(ARDUINO_ELF) $(ARDUINO_EEP)
	$(OBJ_COPY) -O ihex -R .eeprom  $(ARDUINO_ELF) $(ARDUINO_HEX)

$(ARDUINO_EEP): $(ARDUINO_ELF)
	$(OBJ_COPY) -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0  $(ARDUINO_ELF) $(ARDUINO_EEP)

$(ARDUINO_ELF): $(BUILD_DIR) $(BIN_DIR) $(FBARDUINO_FIRMWARE_BUILD_DIR) $(DEPS) $(SRC_DEPS) $(OBJ)
	$(CC) -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections,--relax -mmcu=atmega2560 -o $(ARDUINO_ELF) $(OBJ) $(DEP_SPI_OBJ) $(DEP_Servo_OBJ) $(DEP_CORE_LDFLAGS)

$(BUILD_DIR):
	$(MKDIR_P) $(BUILD_DIR)

$(BIN_DIR):
	$(MKDIR_P) $(BIN_DIR)

$(FBARDUINO_FIRMWARE_BUILD_DIR):
	$(MKDIR_P) $(FBARDUINO_FIRMWARE_BUILD_DIR)

$(FBARDUINO_FIRMWARE_BUILD_DIR)/%.o: $(FBARDUINO_FIRMWARE_SRC_DIR)/%.cpp
	$(CXX) $(CXX_FLAGS) $(DEPS_CFLAGS) $< -o $@
