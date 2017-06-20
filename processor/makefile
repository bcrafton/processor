
verilog_depends = test.v processor.v branch_unit.v control_unit.v forwarding_unit.v hazard_detection_unit.v mux.v ram.v register_file.v pipeline_register.v alu.v program_counter.v instruction_memory.v steer.v blt.v encoder.v

vpi_depends = ../test_bench/sim_vpi.c ../test_bench/memory.c ../test_bench/perf_metrics.c

all: vpi_compile verilog_compile

vpi_compile: $(vpi_depends)
	iverilog-vpi $(vpi_depends)

verilog_compile: $(verilog_depends)
	iverilog -o sim_vpi.vvp $(verilog_depends)

clean:
	rm -f *.vvp *.vpi *.o *.out *.vcd
