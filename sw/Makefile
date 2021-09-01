ifndef CROSS_COMPILE
CROSS_COMPILE = mips-linux-gnu-
endif
CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

OBJECTS = inst_rom.o
TEXTSZ = 256

export	CROSS_COMPILE

# ********************
# Rules of Compilation
# ********************

all: inst_rom.om inst_rom.bin inst_rom.data

%.o: %.S
	$(CC) -mips32 $< -o $@
inst_rom.om: ram.ld $(OBJECTS)
	$(LD) -T ram.ld $(OBJECTS) -o $@
inst_rom.bin: inst_rom.om
	$(OBJCOPY) -O binary $<  $@
inst_rom.data: inst_rom.bin
	#$(shell echo -n "ibase=16;" > .tmpsz)
	#echo "ibase=16;"$(shell $(OBJDUMP) -h inst_rom.o|grep ".text"|awk '{print $$3}') > .tmpstr
	#hexdump -n 16 -v -e '4/1 "%02X" "\n"' $< > $@
	hexdump -n $(TEXTSZ) -v -e '4/1 "%02X" "\n"' $< > $@
clean:
	rm -f *.o *.om *.bin *.data *.mif *.asm .tmpsz
