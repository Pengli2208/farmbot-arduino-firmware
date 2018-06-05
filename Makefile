BUILD_DIR ?= $(shell pwd)/_build
BIN_DIR ?= $(shell pwd)/bin
FBARDUINO_FIRMWARE_SRC_DIR ?= src

ARDUINO_INSTALL_DIR ?= $(HOME)/arduino-1.8.5

SRC := $(wildcard $(FBARDUINO_FIRMWARE_SRC_DIR)/*.cpp)
OBJ := $(SRC:.cpp=.o)
SRC_DEPS := $(SRC) $(wildcard $(FBARDUINO_FIRMWARE_SRC_DIR)/*.h) $(wildcard $(FBARDUINO_FIRMWARE_SRC_DIR)/*.ino)

CXX := $(ARDUINO_INSTALL_DIR)/hardware/tools/avr/bin/avr-g++
CC := $(ARDUINO_INSTALL_DIR)/hardware/tools/avr/bin/avr-gcc

ARDUINO_CXX_FLAGS := \
	-I/home/connor/arduino-1.8.5/hardware/arduino/avr/cores/arduino \
	-I/home/connor/arduino-1.8.5/hardware/arduino/avr/variants/mega \
	-I/home/connor/arduino-1.8.5/hardware/arduino/avr/libraries/SPI/src \
	-I/home/connor/arduino-1.8.5/hardware/arduino/avr/libraries/EEPROM/src \
	-I/home/connor/arduino-1.8.5/libraries/Servo/src

CXX_FLAGS := -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics \
-flto -w -x c++ -E -CC -mmcu=atmega2560 -DF_CPU=16000000L -DARDUINO=10600 -DARDUINO_AVR_MEGA2560 -DARDUINO_ARCH_AVR

ARDUINO_CFLAGS :=
CFLAGS := -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections,--relax -mmcu=atmega2560

ARDUINO_LDFLAGS := 	/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/core/core.a -L/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino -lm
LDFLAGS :=

ARDUINO_HEX := $(BIN_DIR)/arduino-firmware.hex
ARDUINO_ELF := $(BUILD_DIR)/arduino-firmware.elf

FARMDUINO_HEX := $(BIN_DIR)/farmduino-firmware.hex
FARMDUINO_V14_HEX := $(BIN_DIR)/farmduino_k14-firmware.hex
BLINK_HEX := $(BIN_DIR)/blink.hex
CLEAR_EEPROM_HEX := $(BIN_DIR)/clear_eeprom.hex

.PHONY: all clean

all: $(ARDUINO_HEX)

clean:
	$(RM) $(OBJ)

$(ARDUINO_HEX): $(ARDUINO_ELF)

$(ARDUINO_ELF): $(BUILD_DIR) $(BIN_DIR) $(SRC_DEPS) $(OBJ)
	$(CC) $(ARDUINO_CFLAGS) $(CFLAGS) -o $(ARDUINO_ELF) $(OBJ) $(ARDUINO_LDFLAGS) $(LDFLAGS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

%.o: %.cpp
	$(CXX) -c $(ARDUINO_CXX_FLAGS) $(CXX_FLAGS) -o $@ $<

%.o: src/src.ino
	$(CXX) -c $(ARDUINO_CXX_FLAGS) $(CXX_FLAGS) -o $@ $<
