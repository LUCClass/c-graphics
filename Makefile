

CC := gcc
CFLAGS := -O0 -ffreestanding -m32 -march=i386 -fno-pie -fno-stack-protector -g3 -Wall $(CONFIGS)

ODIR = obj
SDIR = src

OBJS = \
	stage1.o \
	stage1main.o \
	clibfuncs.o \
	mustafa.o \

OBJ = $(patsubst %,$(ODIR)/%,$(OBJS))

$(ODIR)/%.o: $(SDIR)/%.c
	$(CC) $(CFLAGS) -c -g -o $@ $^

$(ODIR)/%.o: $(SDIR)/%.s
	nasm -f elf32 -g -o $@ $^

all: bin img

setup:
	mkdir -p obj

bin: $(OBJ)
	ld -Ttext=0x7e00 -melf_i386 $^ -Tstage1.ld -o obj/stage1.elf
	objcopy -O binary obj/stage1.elf stage1.bin
	size obj/stage1.elf

clean:
	rm -f obj/*
	rm -f disk.img stage1.bin rootfs.img

debug:
	qemu-system-i386 -hda disk.img -S -s &
	gdb -x gdb_init_prot_mode.txt

run:
	qemu-system-i386 -hda disk.img

disassemble:
	objdump -b binary -D --adjust-vma=0x7e00 -m i8086 stage1.bin

img:
	rm -f disk.img
	test -s rootfs.img || { dd if=/dev/zero of=rootfs.img bs=1024 count=64; mkfs.fat -F12 rootfs.img; } # Make rootfs image
	dd if=/dev/zero of=disk.img count=131072 bs=512 # Make big disk image (64MB) filled with zeros
	dd if=mbr.img of=disk.img conv=notrunc # Copy MBR to disk img, not truncating original file.
	# Appends chainloader.bin to the end of disk image, starting one 512-byte sector after the beginning of the file.
	dd if=stage1.bin of=disk.img seek=1 conv=notrunc
	# Write rootfs image to first partition starting at sector 2048
	dd if=rootfs.img of=disk.img seek=2048 conv=notrunc
	#  Repartition the disk to occupy the whole image
	./partition.sh disk.img

