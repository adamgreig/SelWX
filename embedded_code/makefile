# SelWX Makefile
# Inspired by libopenstm32

BINARY		= selwx

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
	$(OBJCOPY) -Obinary $(BINARY) $(BINARY).bin
	$(OBJDUMP) -S $(BINARY) > $(BINARY).list

$(BINARY): $(OBJS) $(LDSCRIPT)
	$(LD) $(LDFLAGS) -o $(BINARY) $(OBJS) -lopenstm32

%.o: %.c Makefile
	$(CC) $(CFLAGS) -o $@ -c $<

upload: images
	$(STM32LOADER) -p $(PORT) -b $(BAUD) -e -v -w $(BINARY).bin

clean:
	rm -f *.o
	rm -f $(BINARY)
	rm -f $(BINARY).bin
	rm -f $(BINARY).list

.PHONY: images clean upload

