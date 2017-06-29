
all: compile_test_bench run_test_bench

compile_test_bench: test_bench.c 
	gcc -o test_bench test_bench.c ../common/logs.c ../common/instruction.c `pkg-config --cflags --libs glib-2.0`

run_test_bench: test_bench
	./test_bench

clean:
	rm programs/asm/bin/*.hex programs/asm/mips/*.m
	rm programs/code/asm/*.s programs/code/bin/*.hex programs/code/mips/*.m
	rm -r out/sim/*/ out/emu/*/
