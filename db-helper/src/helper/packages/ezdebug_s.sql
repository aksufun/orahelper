CREATE OR REPLACE PACKAGE ezdebug
IS

PROCEDURE GenMetaLogString
  (p_Owner VARCHAR2
  ,p_ObjName VARCHAR2
  ,p_ProcName VARCHAR2);

PROCEDURE GenMetaLogString
  (p_Owner VARCHAR2
  ,p_ObjName VARCHAR2
  ,p_RowNum NUMBER);

PROCEDURE GenMetaLogString
  (p_Owner VARCHAR2
  ,p_ObjName VARCHAR2);

END;
/