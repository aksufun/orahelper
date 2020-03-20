CREATE OR REPLACE PACKAGE BODY utils IS

-- todo: refactor to projection
FUNCTION slice
  (p_tab arrayofstringarray_t
  ,p_direction CHAR
  ,p_index NUMBER
  ) RETURN stringarray_t
IS
  v_result stringarray_t := stringarray_t();
BEGIN
/*  temp$_exception_handler('slice - p_index should be more then 0', p_index < 1);
  temp$_exception_handler('slice - p_tab is null or empty', p_tab IS NULL OR p_tab.count = 0);
  temp$_exception_handler('slice - less rows then index', p_tab.count < p_index);
  temp$_exception_handler('slice - less cols then index', p_tab(1).count < p_index);*/
  CASE p_direction
    WHEN SLICECOLUMN THEN
      v_result.extend(p_tab.count);
      FOR x IN p_tab.first..p_tab.last LOOP
        v_result(x) := p_tab(x)(p_index);
      END LOOP;
    WHEN SLICEROW THEN
      v_result.extend(p_tab(p_index).count);
      FOR x IN p_tab(p_index).first..p_tab(p_index).last LOOP
        v_result(x) := p_tab(p_index)(x);
      END LOOP;
  END CASE;
  RETURN v_result;
END slice;

FUNCTION stringToArrayPipelined
  (p_string VARCHAR2
  ,p_delim VARCHAR2
  ) RETURN stringarray_t
PIPELINED IS
  v_result stringarray_t;
  v_string VARCHAR2(32000) := p_string;
  v_idx PLS_INTEGER;
BEGIN
  LOOP
    v_idx := INSTR(v_string, p_delim);
    IF v_idx > 0 THEN
      PIPE ROW (SUBSTR(v_string, 1, v_idx -1));
      v_string := SUBSTR(v_string, v_idx + LENGTH(p_delim));
    ELSE
      PIPE ROW(v_string);
      EXIT;
    END IF;
  END LOOP;
  RETURN;
END stringToArrayPipelined;

FUNCTION stringToArray
  (p_string VARCHAR2
  ,p_delim VARCHAR2
  ) RETURN stringarray_t
IS
  v_result stringarray_t;
BEGIN
  SELECT column_value
    BULK COLLECT INTO v_result
  FROM TABLE(stringToArrayPipelined(p_string, p_delim));
  RETURN v_result;
END stringToArray;

FUNCTION arrayToString
  (p_array stringarray_t
  ,p_delim VARCHAR2
  ,p_lbracket VARCHAR2
  ,p_rbracket VARCHAR2
  ) RETURN VARCHAR2
IS
  v_result VARCHAR2(32000);
BEGIN
  IF p_array.count > 0 THEN
    FOR x IN p_array.first..p_array.last LOOP
      v_result := v_result || p_lbracket || p_array(x) || p_rbracket || CASE WHEN x != p_array.last THEN p_delim END;
    END LOOP;
  END IF;
  RETURN v_result;
END arrayToString;

FUNCTION bulkReplace
  (p_source VARCHAR2
  ,p_fromto types.assocstringarray_t
  ) RETURN VARCHAR2
IS
  v_result VARCHAR2(32000) := p_source;
  v_idx VARCHAR2(4000);
BEGIN
  IF p_source IS NOT NULL AND p_fromto.count != 0 THEN
    v_idx := p_fromto.first;
    WHILE (v_idx IS NOT null) LOOP
      v_result := REPLACE(v_result, v_idx, p_fromto(v_idx));
      v_idx := p_fromto.next(v_idx);
    END LOOP;
  END IF;
  RETURN v_result;
END BulkReplace;

FUNCTION NVL2
  (p_val1 VARCHAR2
  ,p_val2 VARCHAR2
  ,p_val3 VARCHAR2
  ) RETURN VARCHAR2
IS
BEGIN
  RETURN CASE WHEN p_val1 IS NOT NULL THEN p_val2 ELSE p_val3 END;
END NVL2;

FUNCTION decode
  (p_val1 VARCHAR2
  ,p_val2 VARCHAR2
  ,p_val3 VARCHAR2
  ,p_val4 VARCHAR2
  ) RETURN VARCHAR2
IS
BEGIN
  RETURN CASE WHEN p_val1 = p_val2 OR p_val1 IS NULL AND p_val2 IS NULL THEN p_val3 ELSE p_val4 END;
END decode;

END utils;
/