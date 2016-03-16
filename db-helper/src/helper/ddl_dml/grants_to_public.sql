DECLARE
  CURSOR public_pkgs IS
    SELECT DISTINCT uo.OBJECT_NAME
    FROM user_objects uo
    WHERE uo.object_type = 'PACKAGE'
      AND uo.object_name NOT LIKE 'I_%';
BEGIN
  FOR pkg IN public_pkgs LOOP
    EXECUTE IMMEDIATE 'GRANT EXECUTE ON ' || pkg.object_name || ' TO PUBLIC';
  END LOOP;
END;
/