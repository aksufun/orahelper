DECLARE
  PROCEDURE p (p_Str VARCHAR2) IS BEGIN dbms_output.put_line(p_Str); END;
BEGIN
  p('ZPORTAL' ||'.'|| 'ACTION' || '.' || 'MAILBOX' || '(');
  FOR x IN (SELECT a.owner
                 , a.object_id
                 , a.object_name
                 , a.package_name
                 , a.argument_name
                 , a.in_out
                 , a.data_type
                 , a.type_owner
                 , a.type_name
            FROM all_procedures p
              JOIN all_arguments a ON a.object_id = p.object_id AND a.argument_name IS NOT NULL AND a.in_out IN ('IN', 'IN/OUT')
            WHERE ((a.package_name = p.object_name AND a.object_name = p.procedure_name)
                   OR (a.package_name IS NULL AND p.PROCEDURE_NAME IS NULL AND a.object_name = p.object_name))
              AND p.owner = 'ZPORTAL'
              AND p.object_name = 'ACTION'
              AND p.procedure_name = 'MAILBOX'
            ORDER BY a.POSITION)
  LOOP
    dbms_output.put_line(x.
      

  