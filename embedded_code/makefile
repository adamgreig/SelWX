# SelWX Makefile
# Inspired by libopenstm32

BINARY		= blink

PREFIX		?= arm-none-eabi
CC		= $(PREFIX)-gcc
LD		= $(PREFIX)-ld
OBJCOPY		= $(PREFIX)-objcopy
OBJDUMP		= $(PREFIX)-objdump

TOOLCHAIN_DIR	= `dirname \`which $(CC)\``/../$(PREFIX)
CFLAGS		= -Os -Wall -Wextra -I$(TOOLCHAIN_DIR)/include -fno-common \
		  -mcpu=cortex-m3 -mthumb
LDSCRIPT	= $(BINARY).ld
LDFLAGS	        = -L$(TOOLCHAIN_DIR)/lib -T$(LDSCRIPT) -nostartfiles
OBJS		= $(BINARY).o

STM32LOADER	= ./stm32loader.py
PORT		= /dev/ttyUSB0
BAUD		= 115200

all: images

images: $(BINARY)
	$(Q)$(OBJCOPY) -Obinary $(BINARY) $(BINARY).bin
	$(Q)$(OBJDUMP) -S $(BINARY) > $(BINARY).list

$(BINARY): $(OBJS) $(LDSCRIPT)
	$(Q)$(LD) $(LDFLAGS) -o $(BINARY) $(OBJS) -lopenstm32

%.o: %.c Makefile
	$(Q)$(CC) $(CFLAGS) -o $@ -c $<

upload: images
	$(STM32LOADER) -p $(POST) -b $(BAUD) -e -v -w $(BINARY).bin

clean:
	$(Q)rm -f *.o
	$(Q)rm -f $(BINARY)
	$(Q)rm -f $(BINARY).bin
	$(Q)rm -f $(BINARY).list

.PHONY: images clean upload

