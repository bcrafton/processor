.PHONY: all
all: vpi compile run

.PHONY: vpi
vpi:
	iverilog-vpi ../test_bench/memory_controller.c ../test_bench/test_bench.c ../test_bench/perf_metrics.c

.PHONY: compile
compile:
	iverilog -o memory_controller.vvp test.v processor.v branch_unit.v control_unit.v forwarding_unit.v hazard_detection_unit.v mux.v ram.v register_file.v pipeline_register.v alu.v program_counter.v instruction_memory.v steer.v lut.v

.PHONY: run
run:
	vvp -M. -m memory_controller memory_controller.vvp

.PHONY: clean
clean:
	rm -f *.vvp *.vpi *.o *.out *.vcd
