TIME_SCALE  = 1ns/1ns
RUN_TIME = 1000000
MODULE_TOP  = sys_tb

DEBUSSY_PATH = /opt/CAD/Verdi2008
VCS_OPTIONS = -timescale=$(TIME_SCALE) +v2k +notimingcheck -P $(DEBUSSY_PATH)/share/PLI/vcs/LINUX/debussy.tab $(DEBUSSY_PATH)/share/PLI/vcs/LINUX/pli.a   +lint=PCWM
SIM_OPTIONS = +vcs+finish+$(RUN_TIME)
VCS_COV_OPTIONS = -timescale=$(TIME_SCALE) +v2k +notimingcheck -P $(DEBUSSY_PATH)/share/PLI/vcs/LINUX/debussy.tab $(DEBUSSY_PATH)/share/PLI/vcs/LINUX/pli.a -cm line+cond -lca  +lint=PCWM
SIM_COV_OPTIONS = -cm line+cond -cm_name $(MODULE_TOP).data -l $(MODULE_TOP).log
CLEAN_THESE = INCA_libs simv.daidir csrc *.shm core *.key *.stats *.err .simcontrol *log *Log \
                  *.fcov tmpfile *.df *.out worklib cds.lib hdl.var *.rpt cov_work hdls_work *.msg \
		 simv*  novas.rc

all : compile sim view_fsdb clean

prepare:
	ls *.v > vlog.txt
compile:
	vcs $(VCS_OPTIONS) -f vlog.txt 
sim    :
	./simv $(SIM_OPTIONS)
verdi_com:
	vericom -2001 -f vlog.txt
	Verdi -top tb_onu -ssf wave.fsdb
view_fsdb :
	$(DEBUSSY_PATH)/bin/nWave -ssf wave.fsdb 
clean   :
	\rm -rf $(CLEAN_THESE)  

