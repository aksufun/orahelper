CREATE OR REPLACE PACKAGE BODY generics IS

FUNCTION fm (p_value VARCHAR2, p_type VARCHAR2, p_mode NUMBER) RETURN VARCHAR2
IS
  FMDTFORMAT CONSTANT VARCHAR2(30) := 'dd mm yyyy hh24 mi ss';
  FMTSFORMAT CONSTANT VARCHAR2(30) := 'dd mm yyyy hh24 mi ssxff';
  FMTSTZFORMAT CONSTANT VARCHAR2(30) := 'dd mm yyyy hh24 mi ssxff tzr';
  v_result VARCHAR2(4000);
  FUNCTION pmode (p_valifstore VARCHAR2, p_valifretrive VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE fm.p_mode WHEN FMSTORETOARRAY THEN p_valifstore WHEN FMRETRIVEFROMARRAY THEN p_valifretrive END;
  END pmode;
BEGIN
  CASE
    WHEN p_value IS NULL THEN
      v_result := pmode('','NULL');
    WHEN p_type LIKE 'NUMBER%' THEN
      v_result := pmode(p_value, p_value);
    WHEN p_type LIKE 'VARCHAR2%' OR p_type LIKE 'CHAR%' THEN
      v_result := pmode(p_value, '''' || replace(p_value,'''','''''') || '''');
    WHEN p_type LIKE 'NVARCHAR2%' THEN
      v_result := pmode('asciistr(' || p_value || ')', 'unistr(''' || p_value || ''')');
    WHEN p_type LIKE 'DATE%' THEN
      v_result := pmode('to_char(' || p_value || ', '''||FMDTFORMAT||''')' , 'to_date(''' || p_value || ''', '''||FMDTFORMAT||''')');
    WHEN p_type LIKE 'TIMESTAMP%TIME%ZONE' THEN
      v_result := pmode('to_char(' || p_value || ', '''||FMTSTZFORMAT||''')', 'to_timestamp_tz(''' || p_value || ''', '''||FMTSTZFORMAT||''')');
    WHEN p_type LIKE 'TIMESTAMP%' THEN
      v_result := pmode('to_char(' || p_value || ', '''||FMTSFORMAT||''')', 'to_timestamp(''' || p_value || ''', '''||FMTSFORMAT||''')');
    WHEN p_type LIKE 'CLOB%' THEN
      v_result := pmode('to_char(' || p_value || ')' , 'to_clob(''' || p_value || ')');
    WHEN p_type LIKE 'NCLOB%' THEN
      v_result := pmode('to_nchar(' || p_value || ')' , 'to_nclob(''' || p_value || ')');
    WHEN p_type LIKE 'RAW%' THEN
      v_result := pmode(p_value, '''' || p_value || '''');
  ELSE
    v_result := '### UNDEFINED TYPE! ###';
  END CASE;
  RETURN v_result;
END;

FUNCTION i_GetTemplate
  (p_procname VARCHAR2
  ) RETURN VARCHAR2
IS
BEGIN
  RETURN templates.GetTemplate('GENERICS.'||upper(p_procname));
END i_GetTemplate;

FUNCTION GetDataArray
  (p_owner VARCHAR2
  ,p_tabname VARCHAR2
  ,p_fields VARCHAR2
  ,p_where VARCHAR2
  ,p_order VARCHAR2
  ) RETURN arrayofstringarray_t
IS
  v_templatesource CLOB := i_GetTemplate('GetTableArray');
  v_result arrayofstringarray_t;
BEGIN
  v_templatesource := replace(v_templatesource, '<FIELDS>', p_fields);
  v_templatesource := replace(v_templatesource, '<OWNERTABLE>', p_owner || '.' || p_tabname);
  v_templatesource := replace(v_templatesource, '<WHERE>', utils.NVL2(p_where,'WHERE ' || p_where,NULL));
  v_templatesource := replace(v_templatesource, '<ORDER>', utils.NVL2(p_order,'ORDER BY ' || p_order,NULL));
  EXECUTE IMMEDIATE v_templatesource BULK COLLECT INTO v_result;
  RETURN v_result;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(v_templatesource);
    RAISE;
END GetDataArray;

FUNCTION GetTableInstance
  (p_owner VARCHAR2
  ,p_tabname VARCHAR2
  ,p_fields VARCHAR2
  ,p_where VARCHAR2
  ,p_order VARCHAR2
  ) RETURN tableinstance_t
IS
  v_result tableinstance_t;
  v_header arrayofstringarray_t;
BEGIN
  v_header := GetDataArray('sys', 'dba_tab_columns'
                          , 'column_name, data_type, generics.fm(column_name, data_type, 1), generics.fm(''{{x}}'', data_type, 2)'
                          , 'owner = ''' || p_owner || ''' AND table_name = ''' || p_tabname ||''''
                            || utils.NVL2(p_fields
                                         ,'AND column_name in ('
                                           || utils.arrayToString(utils.stringToArray(replace(upper(p_fields),' ','')), ',', '''', '''') || ')'
                                         , NULL)
                          ,'column_id');
  IF v_header.count = 0 THEN temp$_exception_handler('NO SUCH TABLE FOR THIS OWNER!'); END IF;
--
  v_result.owner := p_owner;
  v_result.tabname := p_tabname;
  v_result.header := v_header;
  v_result.data := GetDataArray(p_owner, p_tabname
                               , utils.arrayToString(utils.slice(v_header, utils.SLICECOLUMN, 3))
                               , p_where
                               , p_order);
  RETURN v_result;
END GetTableInstance;

/*FUNCTION GetAsInsert
  (p_instance tableinstance_t
  ,p_ending VARCHAR2
  ) RETURN types.text_t
IS
  v_text types.text_t;
BEGIN
--  out.totext();
  out.appendln(v_text, '-- ' || p_instance.owner || '.' || p_instance.tabname);
  IF p_instance.data.count != 0 THEN
    out.appendln(v_text, 'INSERT INTO ' || p_instance.tabname
                       || '(' || utils.arrayToString(utils.slice(p_instance.header, utils.SLICECOLUMN, 1)) || ')');
    FOR x IN p_instance.data.first..p_instance.data.last LOOP
      out.append(v_text, 'SELECT ');
      FOR k IN p_instance.data(x).first..p_instance.data(x).last LOOP
        out.append(v_text, fm(p_instance.data(x)(k), p_instance.header(k)(2), FMRETRIVEFROMARRAY) || utils.decode(k, p_instance.data(x).last, NULL, ', '));
      END LOOP;
      out.appendln(v_text, ' FROM DUAL' || utils.decode(x, p_instance.data.last, p_ending, ' UNION'));
    END LOOP;
  END IF;
  RETURN v_text;
END GetAsInsert;*/

FUNCTION GetAsSelect
  (p_instance tableinstance_t
  ) RETURN CLOB
IS
  v_text CLOB;
BEGIN
  out.appendln(v_text, '-- ' || p_instance.owner || '.' || p_instance.tabname);
  out.appendln(v_text, 'SELECT '  || utils.arrayToString(utils.slice(p_instance.header, utils.SLICECOLUMN, 1), p_lbracket => 'NULL ')
                     || ' FROM DUAL WHERE 1=2' || utils.decode(p_instance.data.count, 0, '', ' UNION'));
  IF p_instance.data.count != 0 THEN
    FOR x IN p_instance.data.first..p_instance.data.last LOOP
      out.append(v_text, 'SELECT ');
      FOR k IN p_instance.data(x).first..p_instance.data(x).last LOOP
        out.append(v_text, fm(p_instance.data(x)(k), p_instance.header(k)(2), FMRETRIVEFROMARRAY) || utils.decode(k, p_instance.data(x).last, NULL, ', '));
      END LOOP;
      out.append(v_text, ' FROM DUAL' || utils.decode(x, p_instance.data.last, '', ' UNION' || chr(10)));
    END LOOP;
  END IF;
--  dbms_lob.freetemporary(v_text);
  RETURN v_text;
END GetAsSelect;

FUNCTION q(p_str VARCHAR2) RETURN VARCHAR2 IS BEGIN RETURN '<['||p_str||']>'; END q;

PROCEDURE ModifyData
  (p_instance IN OUT NOCOPY tableinstance_t
  ,p_rules types.assocstringarray_t)
IS
--<[r]>,<[c]>,<[>=]>,<[<=]>,<[=]>,<[v]>
  v_quants types.assocstringarray_t;

  PROCEDURE FlushQ
    ( p_row stringarray_t, p_rownum NUMBER, p_colnum NUMBER) IS
  BEGIN
    FOR x IN p_row.first..p_row.last LOOP
      v_quants(q(p_instance.header(x)(1))) := fm(p_row(x), p_instance.header(x)(2), FMRETRIVEFROMARRAY);
    END LOOP;
    v_quants(q('rnum')) := p_rownum;
    v_quants(q('cnum')) := p_colnum;
    v_quants(q('cnam')) := fm(p_instance.header(p_colnum)(1), 'VARCHAR2', 2);
    v_quants(q('val')) := fm(p_row(p_colnum), p_instance.header(p_colnum)(2), 2);
  END FlushQ;

  FUNCTION GetAnswer (p_colinfo stringarray_t) RETURN VARCHAR2 IS
    v_result VARCHAR2(4000);
    v_sql VARCHAR2(4000) := utils.bulkReplace('CASE ' || p_rules(p_colinfo(1)) || ' ELSE <[val]> END', v_quants);
  BEGIN
    v_sql := 'SELECT ' || replace(generics.fm('#<!#', p_colinfo(2)), '#<!#', v_sql) || ' FROM DUAL';
    EXECUTE IMMEDIATE v_sql INTO v_result;
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(v_sql);
      RAISE;
  END GetAnswer;

BEGIN
  IF p_instance.data.count > 0 THEN
    FOR r IN p_instance.data.first..p_instance.data.last LOOP
      FOR c IN p_instance.data(r).first..p_instance.data(r).last LOOP
        IF p_rules.exists(p_instance.header(c)(1)) THEN
          FlushQ(p_instance.data(r), r, c);
          p_instance.data(r)(c) := GetAnswer(p_instance.header(c));
        END IF;
      END LOOP;
    END LOOP;
  END IF;
END ModifyData;

END generics;
/