set echo on
set timing on
set scan off
set serveroutput on

------ grants section ------------


------ triggers section ----------


------ packages section ----------


------ procedures section --------


------ functions section ---------


------ views section -------------


------ types section -------------


------ synonyms section ----------


-------ddl dml section------------
@src/sys/rback/create_user_and_grants_rback.sql

/********************************/

set scan on

select * from user_errors;