CREATE OR REPLACE PACKAGE BODY generics IS

/*FUNCTION projection
  (p_tab arrayofarraystring_t
  ,p_rule */

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
    WHEN CT_SLICECOL THEN
      v_result.extend(p_tab.count);
      FOR x IN p_tab.first..p_tab.last LOOP
        v_result(x) := p_tab(x)(p_index);
      END LOOP;
    WHEN CT_SLICEROW THEN
      v_result.extend(p_tab(p_index).count);
      FOR x IN p_tab(p_index).first..p_tab(p_index).last LOOP
        v_result(x) := p_tab(p_index)(x);
      END LOOP;
  END CASE;
  RETURN v_result;
END slice;

FUNCTION stringarraytostring
  (p_array stringarray_t
  ,p_delim VARCHAR2
  ) RETURN VARCHAR2
IS
  v_result VARCHAR2(32000);
BEGIN
  FOR x IN p_array.first..p_array.last LOOP
    v_result := v_result || '''' || p_array(x) || '''' || CASE WHEN x != p_array.last THEN p_delim END;
  END LOOP;
  RETURN v_result;
END stringarraytostring;

FUNCTION tostrbytype
  (p_type VARCHAR2
  ,p_element VARCHAR2
  ) RETURN VARCHAR2
IS
  v_result VARCHAR2(4000);
BEGIN
  CASE
    WHEN p_element IS NULL THEN
      v_result := 'NULL';
    WHEN p_type LIKE 'NUMBER%' THEN
      v_result := p_element;
    WHEN p_type LIKE 'VARCHAR2%' THEN
      v_result := '''' || p_element || '''';
    WHEN p_type LIKE 'DATE%' THEN
      v_result := 'to_date(' || p_element || ', ''dd-mm-yyyy hh24:mi'')';
    WHEN p_type LIKE 'TIMESTAMP%' THEN
      v_result := 'to_timestamp(' || p_element || ', ''dd-mm-yyyy hh24:mi'')';
  ELSE
    v_result := '### UNDEFINED TYPE! ###';
  END CASE;
  RETURN v_result;
END;

FUNCTION i_GetTemplate
  (p_procname VARCHAR2
  ) RETURN CLOB
IS 
  v_res CLOB;
BEGIN
  SELECT t.template_source
    INTO v_res
  FROM genericstemplates t
  WHERE t.procname = UPPER(p_procname);
--
  RETURN v_res;
END i_GetTemplate;

FUNCTION GetDataArray
  (p_owner VARCHAR2
  ,p_tabname VARCHAR2
  ,p_fields stringarray_t
  ,p_where VARCHAR2
  ,p_order VARCHAR2
  ) RETURN arrayofstringarray_t
IS
  v_templatesource CLOB := i_GetTemplate('GetTableArray');
  v_temp VARCHAR2(32000);
  v_result arrayofstringarray_t;
BEGIN
  FOR x IN p_fields.first..p_fields.last LOOP
    v_temp := v_temp || p_fields(x) || CASE WHEN x != p_fields.last THEN ',' END;
  END LOOP;
  v_templatesource := replace(v_templatesource, '<FIELDS>', v_temp);
  v_temp := NULL;
  v_templatesource := replace(v_templatesource, '<OWNERTABLE>', p_owner || '.' || p_tabname);
--  v_templatesource := replace(v_templatesource, '<TABLESIZE>', p_fields.count);
  v_templatesource := replace(v_templatesource, '<WHERE>', p_where);
  v_templatesource := replace(v_templatesource, '<ORDER>', p_order);
/*  FOR x IN p_fields.first..p_fields.last LOOP
    v_temp := v_temp || 'v_res(v_res.count)(' || x || ') := x.' || p_fields(x) || ';' || CHR(10);
  END LOOP;*/
--  v_templatesource := replace(v_templatesource, '<COLUMNSFILLER>', v_temp);
  EXECUTE IMMEDIATE v_templatesource BULK COLLECT INTO v_result;
  RETURN v_result;
END GetDataArray;

FUNCTION GetTableInstance
  (p_owner VARCHAR2
  ,p_tabname VARCHAR2
  ,p_fields stringarray_t
  ,p_where VARCHAR2
  ,p_order VARCHAR2
  ) RETURN tableinstance_t
IS
  v_result tableinstance_t;
  v_header arrayofstringarray_t;
BEGIN
  v_header := GetDataArray('sys', 'dba_tab_columns', stringarray_t('column_name', 'data_type')
                          , 'AND owner = ''' || p_owner || ''' AND table_name = ''' || p_tabname ||''''
                            || CASE WHEN NOT (p_fields IS NULL OR p_fields.count = 0) THEN
                                 'AND column_name in (' || stringarraytostring(p_fields) || ')' END
                          ,'column_id');
  IF v_header.count = 0 THEN temp$_exception_handler('NO SUCH TABLE FOR THIS OWNER!'); END IF;
--
  v_result.owner := p_owner;
  v_result.tabname := p_tabname;
  v_result.header := v_header;
  v_result.data := GetDataArray(p_owner, p_tabname, slice(v_header, CT_SLICECOL, 1)
                               , CASE WHEN p_where IS NOT NULL THEN 'AND ' || p_where END
                               , CASE WHEN p_order IS NULL THEN '''a''' ELSE p_order END);
  RETURN v_result;
END GetTableInstance;

END generics;
/
