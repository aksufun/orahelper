set instance &&1
set timing on
set echo on
set serveroutput on

@src/xpasswords.sql

spool install_&&1..log

connect sys/&&password_sys as sysdba
@src/sys/main.sql

connect helper/&&password_helper
@src/helper/main.sql

spool off

exit