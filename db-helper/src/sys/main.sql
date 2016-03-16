set echo on
set timing on
set scan off
set serveroutput on


-------ddl dml section------------
@src/sys/ddl_dml/create_user_and_grants.sql

------ synonyms section ----------


------ types section -------------


------ views section -------------


------ functions section ---------


------ procedures section --------


------ packages section ----------


------ triggers section ----------


------ grants section ------------


/********************************/

set scan on

select * from user_errors;