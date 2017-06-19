
all: test_bench run

test_bench: test_bench.c emulator.c memory.c
	gcc -o test_bench test_bench.c emulator.c memory.c

.PHONY: run
run:
	./test_bench
