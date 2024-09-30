Aligner: Aligner.sv
	@vcs -full64 -sverilog Aligner.sv -o Aligner

Aligner_tb: Aligner_tb.sv Aligner.sv
	@vcs -full64 -sverilog Aligner.sv Aligner_tb.sv -o Aligner_tb

.PHONY : clean

clean:
	@rm -f Aligner Aligner_tb
