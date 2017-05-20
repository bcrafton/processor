
all: compile assemble execute

compile: compiler
	cd compiler && $(MAKE) && ./main

assemble: assembler
	cd assembler && $(MAKE) && ./main

execute: processor
	cd processor && $(MAKE)

clean:
	cd compiler && $(MAKE) clean
	cd assembler && $(MAKE) clean
	cd processor && $(MAKE) clean
	rm test/actual/*.reg test/actual/*.mem
	rm test/programs/asm/bin/*.hex test/programs/asm/mips/*.m
	rm test/programs/code/asm/*.s test/programs/code/bin/*.hex test/programs/code/mips/*.m
