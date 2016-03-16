CREATE OR REPLACE FUNCTION BulkReplace
  (p_source VARCHAR2
  ,p_from stringarray_t
  ,p_to stringarray_t
  ) RETURN VARCHAR2
IS
  v_result VARCHAR2(32000) := p_source;
BEGIN
  IF p_from IS NOT NULL AND p_to IS NOT NULL THEN
    FOR x IN p_from.first..p_from.last LOOP
      v_result := REPLACE(v_result, p_from(x), p_to(x));
    END LOOP;
  END IF;
  RETURN v_result;
END BulkReplace;
/