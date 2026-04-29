.PHONY: alu wave clean

VERILATOR = verilator
VERILATOR_FLAGS = -Wall -Wno-DECLFILENAME --trace --timing -sv --binary -j 0

alu:
	mkdir -p waves
	$(VERILATOR) $(VERILATOR_FLAGS) --top-module alu_tb rtl/alu.sv tb/alu_tb.sv
	./obj_dir/Valu_tb

wave: alu
	gtkwave waves/alu_tb.vcd &

clean:
	rm -rf obj_dir
	rm -f waves/*.vcd waves/*.fst