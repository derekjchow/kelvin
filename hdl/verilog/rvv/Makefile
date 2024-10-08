Aligner: Aligner.sv
	@vcs -full64 -sverilog Aligner.sv -o Aligner

Aligner_tb: Aligner_tb.sv Aligner.sv
	@vcs -full64 -sverilog Aligner.sv Aligner_tb.sv -o Aligner_tb

MultiFifo: MultiFifo.sv
	@vcs -full64 -sverilog MultiFifo.sv -o MultiFifo

MultiFifo_tb: MultiFifo_tb.sv MultiFifo.sv
	@vcs -full64 -sverilog MultiFifo.sv MultiFifo_tb.sv -o MultiFifo_tb

RVVFrontEnd: interfaces.sv RVVFrontEnd.sv
	@vcs -full64 -sverilog interfaces.sv RVVFrontEnd.sv -o RVVFrontEnd

RVVFrontEnd_tb: interfaces.sv RVVFrontEnd.sv RVVFrontEnd_tb.sv
	@vcs -full64 -sverilog \
		interfaces.sv \
		RVVFrontEnd.sv \
		RVVFrontEnd_tb.sv \
		-o RVVFrontEnd_tb

.PHONY : clean

clean:
	@rm -f Aligner Aligner_tb MultiFifo MultiFifo_tb RVVFrontEnd RVVFrontEnd_tb
