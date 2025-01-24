global env   
fsdbDumpfile "test.fsdb"
fsdbDumpvars "rvv_backend_top" "+all" "+functions" "+mda" "+packedmda" "+struct" "+parameter"
fsdbDumpSVA
run 

