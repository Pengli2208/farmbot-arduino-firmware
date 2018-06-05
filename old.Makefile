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
	$(ARDUINO_BUILD_DIR_FLAGS) -verbose

ARDUINO_BUILD := $(ARDUINO_BUILD_COMMON) $(ARDUINO_SRC_INO)
BLINK_BUILD := $(ARDUINO_BUILD_COMMON) $(ARDUINO_SRC_BLINK_INO) > /dev/null 2>&1
CLEAR_EEPROM_BUILD := $(ARDUINO_BUILD_COMMON) $(ARDUINO_SRC_CLEAR_EEPROM_INO) > /dev/null 2>&1

SRC=$(wildcard $(FBARDUINO_FIRMWARE_SRC_DIR)/*.cpp) $(wildcard $(FBARDUINO_FIRMWARE_SRC_DIR)/*.h) $(wildcard $(FBARDUINO_FIRMWARE_SRC_DIR)/*.ino)

.PHONY: all clean firmwares farmbot_arduino_firmware_build_dirs firmwares arduino farmduino farmduino_k14 blink clear_eeprom clean_arduino_cache

all: $(FBARDUINO_FIRMWARE_BUILD_DIR) $(FBARDUINO_FIRMWARE_BIN_DIR) firmwares

firmwares: arduino farmduino farmduino_k14 blink clear_eeprom

arduino:  $(SRC) farmbot_arduino_firmware_build_dirs $(ARDUINO_FW)

farmduino:  $(SRC) farmbot_arduino_firmware_build_dirs $(FARMDUINO_FW)

farmduino_k14: $(SRC) farmbot_arduino_firmware_build_dirs $(FARMDUINO_V14_FW)

blink: farmbot_arduino_firmware_build_dirs $(BLINK_FW)

clear_eeprom: farmbot_arduino_firmware_build_dirs $(CLEAR_EEPROM_FW)

clean_arduino_cache:
	$(RM) -r $(ARDUINO_CACHE_DIR)
	mkdir -p $(ARDUINO_CACHE_DIR)

blah:
	"/home/connor/arduino-1.8.5/hardware/tools/avr/bin/avr-g++" \
	-c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics  -flto -w -x c++ -E -CC -mmcu=atmega2560 -DF_CPU=16000000L -DARDUINO=10600 -DARDUINO_AVR_MEGA2560 -DARDUINO_ARCH_AVR   \
	"-I/home/connor/arduino-1.8.5/hardware/arduino/avr/cores/arduino" "-I/home/connor/arduino-1.8.5/hardware/arduino/avr/variants/mega" \
	"/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/src.ino.cpp" -o "/dev/null"
	"/home/connor/arduino-1.8.5/hardware/tools/avr/bin/avr-g++" -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics  -flto -w -x c++ -E -CC -mmcu=atmega2560 -DF_CPU=16000000L -DARDUINO=10600 -DARDUINO_AVR_MEGA2560 -DARDUINO_ARCH_AVR   "-I/home/connor/arduino-1.8.5/hardware/arduino/avr/cores/arduino" "-I/home/connor/arduino-1.8.5/hardware/arduino/avr/variants/mega" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/CurrentState.cpp" -o "/dev/null"


boop:
	"/home/connor/arduino-1.8.5/hardware/tools/avr/bin/avr-gcc" -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections,--relax -mmcu=atmega2560  \
	-o "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/src.ino.elf" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/Command.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/CurrentState.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F09Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F11Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F12Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F13Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F14Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F15Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F16Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F20Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F21Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F22Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F31Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F32Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F41Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F42Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F43Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F44Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F61Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F81Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F82Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F83Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/F84Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/G00Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/G28Handler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/GCodeHandler.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/GCodeProcessor.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/MemoryFree.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/ParameterList.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/PinControl.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/PinGuard.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/PinGuardPin.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/ServoControl.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/StatusList.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/StepperControl.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/StepperControlAxis.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/StepperControlEncoder.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/TimerOne.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/farmbot_arduino_controller.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/sketch/src.ino.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/libraries/SPI/SPI.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/libraries/Servo/avr/Servo.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/libraries/Servo/nrf52/Servo.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/libraries/Servo/sam/Servo.cpp.o" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/libraries/Servo/samd/Servo.cpp.o" \
	"/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/libraries/Servo/stm32f4/Servo.cpp.o" \
	"/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/core/core.a" "-L/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino" \
	-lm
	"/home/connor/arduino-1.8.5/hardware/tools/avr/bin/avr-objcopy" -O ihex -j .eeprom \
	--set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0  \
	"/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/src.ino.elf" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/src.ino.eep"
	"/home/connor/arduino-1.8.5/hardware/tools/avr/bin/avr-objcopy" -O ihex -R .eeprom  \
	"/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/src.ino.elf" "/home/connor/farmbot/farmbot-arduino-firmware/_build/arduino/src.ino.hex"

$(ARDUINO_FW): $(SRC) clean_arduino_cache
	$(info Building arduino fw: $@)
	$(ARDUINO_BUILD) -prefs="runtime.ide.version=10600 -DFARMBOT_BOARD_ID=0"
	@cp $(ARDUINO_BUILD_DIR)/src.ino.hex $@

$(FARMDUINO_FW): $(SRC) clean_arduino_cache
	$(info Building Farmduino v10 fw: $@)
	$(ARDUINO_BUILD) -prefs="runtime.ide.version=10600 -DFARMBOT_BOARD_ID=1"
	@cp $(ARDUINO_BUILD_DIR)/src.ino.hex $@

$(FARMDUINO_V14_FW): $(SRC) clean_arduino_cache
	$(info Building Farmduino v14 fw: $@)
	$(ARDUINO_BUILD) -prefs="runtime.ide.version=10600 -DFARMBOT_BOARD_ID=2"
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
