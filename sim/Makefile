vcs: clean com vcs_sim 
vd: clean com vd_sim verdi
 
clean:
	rm -rf csrc DVEfiles *log* *.vpd *fsdb simv.daidir *.key simv *.conf verdiLog *.rc
 
com:
	vcs -full64 -f filelist.f -R +v2k -debug -timescale=1ns/1ns -fsdb -l com.log +incdir+/home/ICer/myprj/rv32e_debug/src
 
vcs_sim:
	./simv -gui &
 
vd_sim:
	./simv -l sim.log 

verdi:
	verdi -f filelist.f -ssf *.fsdb -nologo &