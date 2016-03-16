set echo on
set timing on
set scan off
set serveroutput on


-------ddl dml section------------
-- ezdebug
@src/helper/ddl_dml/ezdebuglogs_creation.sql
-- runstats
@src/helper/ddl_dml/runstats.sql
-- generics
@src/helper/ddl_dml/generics.sql

------ synonyms section ----------


------ types section -------------
@src/helper/types/stringarray_t.sql
@src/helper/types/arrayofstringarray_t.sql

------ views section -------------
@src/helper/views/vstats.sql

------ functions section ---------
@src/helper/functions/bulkreplace.sql

------ procedures section --------
@src/helper/procedures/temp$_exception_handler.sql

------ packages section ----------
-- stats
@src/helper/packages/stats_s.sql
@src/helper/packages/stats_b.sql
-- ezdebug
@src/helper/packages/ezdebug_s.sql
@src/helper/packages/ezdebug_b.sql
-- runstats
@src/helper/packages/runstats_pkg_s.sql
@src/helper/packages/runstats_pkg_b.sql
-- generics
@src/helper/packages/generics_s.sql
@src/helper/packages/generics_b.sql

------ triggers section ----------


------ grants section ------------
@src/helper/ddl_dml/grants_to_public.sql

/********************************/

set scan on

execute dbms_utility.compile_schema(schema=>user,compile_all=>false,reuse_settings=>true);

select * from user_errors;