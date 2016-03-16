set instance &&1
set timing on
set echo on
set serveroutput on

@src/xpasswords.sql

spool uninstall_&&1..log

connect sys/&&password_sys as sysdba
@src/sys/rback.sql

spool off

exit