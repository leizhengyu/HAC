TIME_SCALE      = 1ns/1ns
RUN_TIME        = 5us
MODULE_TOP      = sys_tb 


VLOG_OPTIONS    = -q -V1995  -work worklib -nowarn NONPRT -nowarn PARRNG 
VHDL_OPTIONS    = -q -V93    -work worklib -nowarn NONPRT -nowarn PARRNG 
ELAB_OPTIONS	= -access +rcw -timescale $(TIME_SCALE) -notimingchecks  $(ELAB_OP)
NCSIM_OPTIONS   = -input run_sim.tcl -logfile sim.msg -notimezeroasrtmsg 

SNAPSHOT        = worklib.$(MODULE_TOP)
CLEAN_THESE     = INCA_libs simv.daidir csrc *.shm core *.key *.stats *.err .simcontrol *log *Log \
                  *.fcov tmpfile *.df *.out worklib cds.lib hdl.var *.rpt cov_work hdls_work *.msg \
		  simv*

all : prepare system elaborate nsim view_fsdb clean

prepare:
	#ls *.v > vlog.f
	echo "run $(RUN_TIME)" >  run_sim.tcl
	echo "finish "         >> run_sim.tcl
system:
	ncvlog $(VLOG_OPTIONS) $(TEST_CASE) -f vlog.f 
elaborate:
	ncelab $(ELAB_OPTIONS) $(SNAPSHOT)  
nsim    :
	ncsim  $(NCSIM_OPTIONS) $(SNAPSHOT)
verdi_com:
	vericom -2001 -f vlog.txt
	Verdi -top tb_onu -ssf wave.fsdb
view_fsdb :
	nWave -ssf wave.fsdb 
clean   :
	\rm -rf $(CLEAN_THESE)  

