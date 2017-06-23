
all: compile_test_bench run_test_bench

compile_test_bench: test_bench.c emulator.c memory.c
	gcc -o test_bench test_bench.c emulator.c memory.c

run_test_bench: test_bench
	./test_bench

clean:
	rm programs/asm/bin/*.hex programs/asm/mips/*.m
	rm programs/code/asm/*.s programs/code/bin/*.hex programs/code/mips/*.m
	rm out/*.mem out/*.reg out/*.perf
