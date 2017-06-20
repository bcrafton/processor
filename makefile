
all: compile assemble processor test_bench

compile: compiler
	cd compiler && $(MAKE) && ./main

assemble: assembler
	cd assembler && $(MAKE) && ./main

processor: processor
	cd processor && $(MAKE)

test_bench: test_bench
	cd test_bench && $(MAKE)

clean:
	cd compiler && $(MAKE) clean
	cd assembler && $(MAKE) clean
	cd processor && $(MAKE) clean
	#rm test_bench/actual/*.reg test_bench/actual/*.mem
	rm test_bench/programs/asm/bin/*.hex test_bench/programs/asm/mips/*.m
	rm test_bench/programs/code/asm/*.s test_bench/programs/code/bin/*.hex test_bench/programs/code/mips/*.m
	#rm test_bench/performance/*.perf
	rm test_bench/out/*.mem test_bench/out/*.reg test_bench/out/*.perf
