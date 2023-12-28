debImport "-f" "filelist.f"
debLoadSimResult /home/ICer/myprj/rv32e_debug/sim/rv32e_pipeline.fsdb
wvCreateWindow
wvSetCursor -win $_nWave2 916222.920893
wvRestoreSignal -win $_nWave2 \
           "/home/ICer/myprj/rv32e_debug/sim/rc_file/add_addi.rc" \
           -overWriteAutoAlias on -appendSignals on
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
