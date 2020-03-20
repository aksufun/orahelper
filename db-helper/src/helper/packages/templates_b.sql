CREATE OR REPLACE PACKAGE BODY templates IS

FUNCTION getTemplate
  (p_id VARCHAR2
  ) RETURN CLOB
IS
  v_result CLOB;
BEGIN
  SELECT t.template_source
    INTO v_result
  FROM templatestext t
  WHERE t.id = p_id;
  RETURN v_result;
END GetTemplate;

FUNCTION i_bindGetPattern
  (p_str VARCHAR2) RETURN VARCHAR2
IS
BEGIN
  RETURN lower('{{'||p_str||'}}');
END i_bindGetPattern;

PROCEDURE bind
  (p_template IN OUT NOCOPY CLOB
  ,p_oldsub VARCHAR2
  ,p_newsub VARCHAR2)
IS
BEGIN
  p_template := REPLACE(p_template, i_bindGetPattern(p_oldsub), p_newsub);
END bind;

PROCEDURE bind
  (p_template IN OUT NOCOPY CLOB
  ,p_oldsub VARCHAR2
  ,p_newsub CLOB)
IS
  v_oldsub VARCHAR2(100) := i_bindGetPattern(p_oldsub);
  v_result CLOB;
  v_pos NUMBER;
  v_amount NUMBER; v_srcoffset NUMBER; v_destoffset NUMBER;
BEGIN
  LOOP
    v_pos := dbms_lob.instr(p_template, v_oldsub);
    EXIT WHEN v_pos = 0;
    dbms_lob.createtemporary(v_result, TRUE, dbms_lob.call);
      v_amount := v_pos-1;
      v_destoffset := 1;
      v_srcoffset := 1;
    dbms_lob.copy(v_result, p_template, v_amount, v_destoffset, v_srcoffset);
--
      v_amount := dbms_lob.getlength(p_newsub);
      v_destoffset := dbms_lob.getlength(v_result)+1;
      v_srcoffset := 1;
    dbms_lob.copy(v_result, p_newsub, v_amount, v_destoffset, v_srcoffset);
--
      v_amount := dbms_lob.getlength(p_template) - (v_pos-1) - length(v_oldsub);
      v_destoffset := dbms_lob.getlength(v_result)+1;
      v_srcoffset := v_pos+length(v_oldsub);
    IF v_amount != 0 THEN
      dbms_lob.copy(v_result, p_template, v_amount, v_destoffset, v_srcoffset);
    END IF;
--
    p_template := v_result;
    dbms_lob.freetemporary(v_result);
  END LOOP;
END bind;

PROCEDURE bind
  (p_template IN OUT NOCOPY CLOB
  ,p_subs types.assocstringarray_t)
IS
  v_idx VARCHAR2(4000);
BEGIN
  v_idx := p_subs.first;
  WHILE (v_idx IS NOT NULL) LOOP
    bind(p_template, v_idx, p_subs(v_idx));
    v_idx := p_subs.next(v_idx);
  END LOOP;
END bind;


END templates;
/