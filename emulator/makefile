
all: emu

emu: emulator.c ../common/memory.c
	gcc -o emulator emulator.c ../common/memory.c ../common/logs.c ../common/instruction.c `pkg-config --cflags --libs glib-2.0`
