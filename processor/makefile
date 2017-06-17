.PHONY: all
all: vpi compile run

.PHONY: vpi
vpi:
	iverilog-vpi ../test_bench/sim_vpi.c ../test_bench/memory.c ../test_bench/perf_metrics.c

.PHONY: compile
compile:
	iverilog -o sim_vpi.vvp test.v processor.v branch_unit.v control_unit.v forwarding_unit.v hazard_detection_unit.v mux.v ram.v register_file.v pipeline_register.v alu.v program_counter.v instruction_memory.v steer.v blt.v encoder.v

.PHONY: run
run:
	vvp -M. -m sim_vpi sim_vpi.vvp +test_name="fib3.bc.s.hex" +run_time=10000 +program_dir="../test_bench/programs/code/bin/" +out_dir="../test_bench/out/"

.PHONY: clean
clean:
	rm -f *.vvp *.vpi *.o *.out *.vcd
