CREATE OR REPLACE PACKAGE BODY ezdebug
IS

PROCEDURE GenMetaLogString
  (p_Owner VARCHAR2
  ,p_ObjName VARCHAR2
  ,p_ProcName VARCHAR2)
IS
  vRes NUMBER;
BEGIN
  SELECT COUNT(*)
    INTO vRes
  FROM all_procedures ap
  WHERE ap.owner = TRIM(UPPER(p_Owner))
    AND ap.object_name = TRIM(UPPER(p_ObjName))
    AND ap.PROCEDURE_NAME = trim(upper(p_ProcName))
    AND rownum <= 1;

  IF vRes = 0 THEN
    raise_application_error(-20000, 'BLANK ERROR! NEED TO FIX');
  ELSE
    NULL;
  END IF;
END;

PROCEDURE GenMetaLogString
  (p_Owner VARCHAR2
  ,p_ObjName VARCHAR2
  ,p_RowNum NUMBER)
IS
BEGIN
  NULL;
END;

PROCEDURE GenMetaLogString
  (p_Owner VARCHAR2
  ,p_ObjName VARCHAR2)
IS
BEGIN
  NULL;
END;

END;
/