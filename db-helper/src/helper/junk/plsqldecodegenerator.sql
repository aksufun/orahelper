DECLARE
  v_body VARCHAR2(4000) :=
'FUNCTION pdecode
  (p_source <TYPE>
<PARAMS>
  ,p_else <TYPE> DEFAULT NULL
  ) RETURN <TYPE>
IS
BEGIN
  RETURN
    CASE
<CASEWHEN>
    ELSE
      p_else
    END;
END pdecode;
';
  v_params VARCHAR2(4000) :=
'  ,p_if<i> <TYPE>
  ,p_then<i> <TYPE>';
  v_casewhen VARCHAR2(4000) :=
'      WHEN p_source = p_if<i> THEN p_then<i>';
  v_tempbody VARCHAR2(4000);
  v_temp1params VARCHAR2(4000);
  v_temp2params VARCHAR2(4000);
  v_temp1casewhen VARCHAR2(4000);
  v_temp2casewhen VARCHAR2(4000);
  v_temp VARCHAR2(4000);
  v_result VARCHAR2(8000);
BEGIN
  FOR x IN (/*SELECT 'NUMBER' val FROM dual UNION */SELECT 'VARCHAR2' val FROM dual/* UNION SELECT 'DATE' val FROM dual*/) LOOP
    v_tempbody := REPLACE(v_body, '<TYPE>', x.val);
    v_temp1params := REPLACE(v_params, '<TYPE>', x.val);
    v_temp1casewhen := REPLACE(v_casewhen, '<TYPE>', x.val);
    FOR k IN 1..2 LOOP
      v_temp2params := NULL;
      v_temp2casewhen := NULL;
      FOR l IN 1..k LOOP
        v_temp2params := v_temp2params || REPLACE(v_temp1params, '<i>', l) || CASE WHEN l != k THEN chr(10) END;
        v_temp2casewhen := v_temp2casewhen || REPLACE(v_temp1casewhen, '<i>', l) || CASE WHEN l != k THEN chr(10) END;
      END LOOP;
      v_result := REPLACE(v_tempbody, '<PARAMS>', v_temp2params );
      v_result := REPLACE(v_result, '<CASEWHEN>', v_temp2casewhen);
      dbms_output.put_line(v_result);
    END LOOP;
  END LOOP;
END;
