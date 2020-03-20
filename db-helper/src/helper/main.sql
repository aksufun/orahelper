set echo on
set timing on
set scan off
set serveroutput on


-------ddl dml section------------
-- ezdebug
@src/helper/ddl_dml/ezdebuglogs_creation.sql
-- runstats
@src/helper/ddl_dml/runstats.sql
-- templates
@src/helper/ddl_dml/templates.sql
-- plsql developer profiler
@src/helper/ddl_dml/plsql_developer_profiler.sql
------ synonyms section ----------


------ types section -------------
@src/helper/types/stringarray_t.sql
@src/helper/types/arrayofstringarray_t.sql

------ views section -------------
@src/helper/views/vstats.sql

------ functions section ---------

------ procedures section --------
@src/helper/procedures/temp$_exception_handler.sql

------ packages section ----------
-- templates
@src/helper/packages/templates_s.sql
@src/helper/packages/templates_b.sql
-- types
@src/helper/packages/types_s.sql
@src/helper/packages/types_b.sql
-- out
@src/helper/packages/out_s.sql
@src/helper/packages/out_b.sql
-- stats
@src/helper/packages/stats_s.sql
@src/helper/packages/stats_b.sql
-- ezdebug
@src/helper/packages/ezdebug_s.sql
@src/helper/packages/ezdebug_b.sql
-- runstats
@src/helper/packages/runstats_pkg_s.sql
@src/helper/packages/runstats_pkg_b.sql
-- utils
@src/helper/packages/utils_b.sql
@src/helper/packages/utils_s.sql
-- generics
@src/helper/packages/generics_s.sql
@src/helper/packages/generics_b.sql
-- rc tiers
@src/helper/packages/rctiers_s.sql
@src/helper/packages/rctiers_b.sql
-- xls
@src/helper/packages/as_xlsx_s.sql
@src/helper/packages/as_xlsx_b.sql

------ triggers section ----------


------ grants section ------------
@src/helper/ddl_dml/grants_to_public.sql

-- Templates section -------------
@src/helper/ddl_dml/templates_dml.sql

/********************************/

set scan on

execute dbms_utility.compile_schema(schema=>user,compile_all=>false,reuse_settings=>true);

select * from user_errors;