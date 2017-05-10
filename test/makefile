.PHONY: all
all: vpi compile run

.PHONY: vpi
vpi:
	iverilog-vpi memory_controller.c memory_simulator.c 

.PHONY: compile
compile:
	iverilog -o memory_controller.vvp top.v memory_controller.v memory_controller.sft

.PHONY: run
run:
	vvp -M. -m memory_controller memory_controller.vvp

.PHONY: clean
clean:
	rm -f *.vvp *.vpi *.o *.out
