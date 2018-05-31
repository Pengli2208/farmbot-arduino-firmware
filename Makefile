FBARDUINO_FIRMWARE_BUILD_DIR ?= $(shell pwd)/_build
FBARDUINO_FIRMWARE_BIN_DIR ?= $(shell pwd)/_build
FBARDUINO_FIRMWARE_SRC_DIR ?= src

ARDUINO_FW=$(FBARDUINO_FIRMWARE_BIN_DIR)/arduino-firmware.hex
FARMDUINO_FW=$(FBARDUINO_FIRMWARE_BIN_DIR)/farmduino-firmware.hex
FARMDUINO_V14_FW=$(FBARDUINO_FIRMWARE_BIN_DIR)/farmduino_k14-firmware.hex
BLINK_FW=$(FBARDUINO_FIRMWARE_BIN_DIR)/blink.hex
CLEAR_EEPROM_FW=$(FBARDUINO_FIRMWARE_BIN_DIR)/clear_eeprom.hex

ARDUINO_INSTALL_DIR ?= $(HOME)/arduino-1.8.5
ARDUINO_BUILDER := $(ARDUINO_INSTALL_DIR)/arduino-builder

ARDUINO_HARDWARE_DIR := $(ARDUINO_INSTALL_DIR)/hardware
ARDUINO_HARDWARE_FLAGS := -hardware $(ARDUINO_HARDWARE_DIR)

ARDUINO_TOOLS_FLAGS := -tools $(ARDUINO_INSTALL_DIR)/tools-builder \
	-tools $(ARDUINO_HARDWARE_DIR)/tools/avr

ARDUINO_LIBS_FLAGS := -built-in-libraries $(ARDUINO_INSTALL_DIR)/libraries

ARDUINO_PREFS_FLAGS := -prefs=build.warn_data_percentage=75 \
	-prefs=runtime.tools.avrdude.path=$(ARDUINO_INSTALL_DIR)/hardware/tools/avr \
	-prefs=runtime.tools.avr-gcc.path=$(ARDUINO_INSTALL_DIR)/hardware/tools/avr \

ARDUINO_ARCH_FLAGS := -fqbn=arduino:avr:mega:cpu=atmega2560
ARDUINO_SRC_INO := $(FBARDUINO_FIRMWARE_SRC_DIR)/src.ino
ARDUINO_SRC_BLINK_INO := $(ARDUINO_INSTALL_DIR)/examples/01.Basics/Blink/Blink.ino
ARDUINO_SRC_CLEAR_EEPROM_INO := $(ARDUINO_HARDWARE_DIR)/arduino/avr/libraries/EEPROM/examples/eeprom_clear/eeprom_clear.ino

ARDUINO_BUILD_DIR := $(FBARDUINO_FIRMWARE_BUILD_DIR)/arduino
ARDUINO_CACHE_DIR := $(FBARDUINO_FIRMWARE_BUILD_DIR)/arduino-cache

ARDUINO_BUILD_DIR_FLAGS := -build-path $(ARDUINO_BUILD_DIR) \
	-build-cache $(ARDUINO_CACHE_DIR) \

ARDUINO_BUILD_COMMON = $(ARDUINO_BUILDER) \
	$(ARDUINO_HARDWARE_FLAGS) \
	$(ARDUINO_TOOLS_FLAGS) \
	$(ARDUINO_LIBS_FLAGS) \
	$(ARDUINO_ARCH_FLAGS) \
	$(ARDUINO_PREFS_FLAGS) \
	$(ARDUINO_BUILD_DIR_FLAGS) -quiet

ARDUINO_BUILD := $(ARDUINO_BUILD_COMMON) $(ARDUINO_SRC_INO)
BLINK_BUILD := $(ARDUINO_BUILD_COMMON) $(ARDUINO_SRC_BLINK_INO) > /dev/null 2>&1
CLEAR_EEPROM_BUILD := $(ARDUINO_BUILD_COMMON) $(ARDUINO_SRC_CLEAR_EEPROM_INO) > /dev/null 2>&1

SRC=$(wildcard $(FBARDUINO_FIRMWARE_SRC_DIR)/*.cpp) $(wildcard $(FBARDUINO_FIRMWARE_SRC_DIR)/*.h) $(wildcard $(FBARDUINO_FIRMWARE_SRC_DIR)/*.ino)

.PHONY: all clean firmwares farmbot_arduino_firmware_build_dirs firmwares arduino farmduino farmduino_k14 blink clear_eeprom

all: $(FBARDUINO_FIRMWARE_BUILD_DIR) $(FBARDUINO_FIRMWARE_BIN_DIR) firmwares

firmwares: arduino farmduino farmduino_k14 blink clear_eeprom

arduino:  $(SRC) farmbot_arduino_firmware_build_dirs $(ARDUINO_FW)

farmduino:  $(SRC) farmbot_arduino_firmware_build_dirs $(FARMDUINO_FW)

farmduino_k14: $(SRC) farmbot_arduino_firmware_build_dirs $(FARMDUINO_V14_FW)

blink: farmbot_arduino_firmware_build_dirs $(BLINK_FW)

clear_eeprom: farmbot_arduino_firmware_build_dirs $(CLEAR_EEPROM_FW)

$(ARDUINO_FW): $(SRC)
	$(info Building arduino fw: $@)
	$(ARDUINO_BUILD) -prefs="runtime.ide.version=10600 -_FARMBOT_BOARD_ID=0"
	@cp $(ARDUINO_BUILD_DIR)/src.ino.hex $@

$(FARMDUINO_FW): $(SRC)
	$(info Building Farmduino v10 fw: $@)
	$(ARDUINO_BUILD) -prefs="runtime.ide.version=10600 -_FARMBOT_BOARD_ID=1"
	@cp $(ARDUINO_BUILD_DIR)/src.ino.hex $@

$(FARMDUINO_V14_FW): $(SRC)
	$(info Building Farmduino v14 fw: $@)
	$(ARDUINO_BUILD) -prefs="runtime.ide.version=10600 -_FARMBOT_BOARD_ID=2"
	@cp $(ARDUINO_BUILD_DIR)/src.ino.hex $@

$(BLINK_FW):
	$(info Building Blink: $@)
	@$(BLINK_BUILD)
	@cp $(ARDUINO_BUILD_DIR)/Blink.ino.hex $@

$(CLEAR_EEPROM_FW):
	$(info Building clear eeprom utility $@)
	@$(CLEAR_EEPROM_BUILD)
	@cp $(ARDUINO_BUILD_DIR)/eeprom_clear.ino.hex $@

clean:
	$(RM) $(ARDUINO_FW) $(FARMDUINO_FW) $(FARMDUINO_V14_FW) $(BLINK_FW) $(CLEAR_EEPROM_FW)

$(FBARDUINO_FIRMWARE_BUILD_DIR):
	mkdir -p $(FBARDUINO_FIRMWARE_BUILD_DIR)

$(ARDUINO_BUILD_DIR):
	mkdir -p $(ARDUINO_BUILD_DIR)

$(ARDUINO_CACHE_DIR):
	mkdir -p $(ARDUINO_CACHE_DIR)

$(FBARDUINO_FIRMWARE_BIN_DIR):
	mkdir -p $(FBARDUINO_FIRMWARE_BIN_DIR)

farmbot_arduino_firmware_build_dirs: $(ARDUINO_BUILD_DIR) $(ARDUINO_CACHE_DIR) $(FBARDUINO_FIRMWARE_BIN_DIR)
