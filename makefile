
all: compile assemble sim emu tb 

compile: compiler
	cd compiler && $(MAKE) && ./main

assemble: assembler
	cd assembler && $(MAKE) && ./main

sim: processor
	cd processor && $(MAKE)

emu: emulator
	cd emulator && $(MAKE)

tb: test_bench
	cd test_bench && $(MAKE)

clean:
	cd compiler && $(MAKE) clean
	cd assembler && $(MAKE) clean
	cd processor && $(MAKE) clean
	cd test_bench && $(MAKE) clean
