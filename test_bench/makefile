
all: compile_test_bench run_test_bench

compile_test_bench: test_bench.c emulator.c memory.c
	gcc -o test_bench test_bench.c emulator.c memory.c

run_test_bench: test_bench
	./test_bench
