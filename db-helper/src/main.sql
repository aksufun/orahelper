set instance &&1
set timing on
set echo on
set serveroutput on

spool install_&&1..log

connect &&2
@src/helper/main.sql

spool off

exit