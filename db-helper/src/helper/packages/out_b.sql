CREATE OR REPLACE PACKAGE BODY out IS

PROCEDURE i_init
  (p_val IN OUT NOCOPY CLOB)
IS
BEGIN
  IF nvl(dbms_lob.istemporary(p_val),0) = 0 THEN
    dbms_lob.createtemporary(p_val, FALSE, dbms_lob.call);
  END IF;
END;

PROCEDURE append
  (p_src IN OUT NOCOPY CLOB
  ,p_val CLOB)
IS
BEGIN
  i_init(p_src);
  dbms_lob.append(p_src, p_val);
END append;

PROCEDURE appendln
  (p_src IN OUT NOCOPY CLOB
  ,p_val CLOB)
IS
BEGIN
  i_init(p_src);
  dbms_lob.append(p_src, p_val);
  dbms_lob.append(p_src, chr(10));
END appendln;

PROCEDURE print
  (p_src CLOB)
IS
BEGIN
  print(types.toText(p_src, p_delim => chr(10)));
END print;

PROCEDURE print
  (p_src types.text_t)
IS
  v_idx NUMBER;
BEGIN
  v_idx := p_src.first;
  WHILE v_idx IS NOT NULL LOOP
    dbms_output.put_line(p_src(v_idx));
    v_idx := p_src.next(v_idx);
  END LOOP;
END print;

PROCEDURE write
  (p_dir VARCHAR
  ,p_filename VARCHAR2
  ,p_text types.text_t)
IS
  v_idx PLS_INTEGER;
  v_file utl_file.file_type;
BEGIN
  v_file := utl_file.fopen(p_dir, p_filename, 'W');
  v_idx := p_text.first;
  WHILE v_idx IS NOT NULL
  LOOP
    utl_file.put_line(v_file, p_text(v_idx));
    v_idx := p_text.next(v_idx);
  END LOOP;
  utl_file.fclose(v_file);
END write;

/*FUNCTION texttoclob
  (p_text text_t
  ) RETURN CLOB
IS
  v_result CLOB;
BEGIN
  IF p_text IS NOT NULL THEN
    FOR x IN p_text.first..p_text.last LOOP
      dbms_lob.append(v_result, p_text(x));
    END LOOP;
  END IF;
END texttoclob;

PROCEDURE i_initText (p_text IN OUT NOCOPY text_t) IS
BEGIN
  IF p_text.last IS NULL THEN p_text(1000) := ''; END IF;
END i_initText;

FUNCTION clobtotext
  (p_clob CLOB
  ) RETURN text_t
IS
  v_breakpos NUMBER;
  v_curlen NUMBER := 0;
  v_result text_t;
BEGIN
  i_initText(v_result);
  IF p_clob IS NOT NULL THEN
    v_breakpos := dbms_lob.instr(p_clob, chr(10));
    WHILE ( v_breakpos > 0 ) LOOP
      v_result(v_result.last + 1) := dbms_lob.substr(p_clob,v_breakpos-1-v_curlen,v_curlen);
      v_curlen := v_curlen + length(v_result.last);
      v_breakpos := dbms_lob.instr(p_clob, chr(10), v_curlen);
    END LOOP;
  END IF;
  RETURN v_result;
END clobtotext;

PROCEDURE append
  (p_to IN OUT NOCOPY text_t
  ,p_from VARCHAR2)
IS
  v_lastbreakpos NUMBER;
BEGIN
  IF p_from IS NOT NULL THEN
    i_initText(p_to);
    IF (NVL(LENGTH(p_to(p_to.last)),0) + LENGTH(p_from)) <= 30000 THEN
      p_to(p_to.last) := p_to(p_to.last) || p_from;
    ELSE
      v_lastbreakpos := INSTR(p_to(p_to.last), CHR(10), -1, 1);
      p_to(p_to.last+1) := substr( p_to(p_to.last), v_lastbreakpos+1 ) || p_from;
      p_to(p_to.last-1) := substr(p_to(p_to.last-1), 1, v_lastbreakpos-1);
    END IF;
  END IF;
END append;

PROCEDURE appendln
  (p_to IN OUT NOCOPY text_t
  ,p_from VARCHAR2)
IS
  v_lastbreakpos NUMBER;
BEGIN
  append(p_to, p_from||chr(10));
END appendln;

PROCEDURE append
  (p_to IN OUT NOCOPY text_t
  ,p_from text_t)
IS
  v_idx PLS_INTEGER;
BEGIN
  IF p_from.count != 0 THEN
    i_initText(p_to);
    v_idx := p_from.first;
    WHILE v_idx IS NOT NULL
    LOOP
      IF p_to.last IS NULL THEN
        p_to(p_to.last) := p_from(v_idx);
      ELSE
        p_to(p_to.last + 1) := p_from(v_idx);
      END IF;
      v_idx := p_from.next(v_idx);
    END LOOP;
  END IF;
END append;

FUNCTION totext
  (p_data VARCHAR2
  ,p_bcol VARCHAR2 DEFAULT NULL, p_acol VARCHAR2 DEFAULT NULL
  ) RETURN text_t
IS
  v_result text_t;
BEGIN
  append(v_result, p_bcol);
  append(v_result, p_data);
  append(v_result, p_acol);
  RETURN v_result;
END totext;

FUNCTION totext
  (p_data stringarray_t
  ,p_bdata VARCHAR2 DEFAULT NULL, p_adata VARCHAR2 DEFAULT NULL
  ,p_bcol VARCHAR2 DEFAULT NULL, p_acol VARCHAR2 DEFAULT NULL
  ) RETURN text_t
IS
  v_result text_t;
BEGIN
  append(v_result, p_bdata);
  FOR x IN p_data.first..p_data.last LOOP
    append(v_result, totext(p_data(x), p_bcol, p_acol));
  END LOOP;
  append(v_result, p_adata);
  RETURN v_result;
END totext;

FUNCTION totext
  (p_data arrayofstringarray_t
  ,p_bdata VARCHAR2 DEFAULT NULL, p_adata VARCHAR2 DEFAULT NULL
  ,p_brow VARCHAR2 DEFAULT NULL, p_arow VARCHAR2 DEFAULT NULL
  ,p_bcol VARCHAR2 DEFAULT NULL, p_acol VARCHAR2 DEFAULT NULL
  ) RETURN text_t
IS
  v_result text_t;
BEGIN
  append(v_result, p_bdata);
  FOR x IN p_data.first..p_data.last LOOP
    append(v_result, totext(p_data(x), p_bdata, p_adata, p_bcol, p_acol));
  END LOOP;
  append(v_result, p_adata);
  RETURN v_result;
END totext;

PROCEDURE print (p_text text_t)
IS
  v_idx PLS_INTEGER;
BEGIN
  v_idx := p_text.first;
  WHILE v_idx IS NOT NULL
  LOOP
    dbms_output.put_line(substr(p_text(v_idx), 1, INSTR(p_text(v_idx), CHR(10), -1)-1));
    v_idx := p_text.next(v_idx);
  END LOOP;
END print;

PROCEDURE print2 (p_text text_t)
IS
  v_idx PLS_INTEGER;
BEGIN
  v_idx := p_text.first;
  WHILE v_idx IS NOT NULL
  LOOP
    dbms_output.put_line(p_text(v_idx));
    v_idx := p_text.next(v_idx);
  END LOOP;
END print2;

\*PROCEDURE print(p_val CLOB)
IS
BEGIN

END print;*\

*/

END out;
/