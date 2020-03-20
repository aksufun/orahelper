DECLARE
  v_text types.text_t;
BEGIN
  FOR x IN (SELECT * FROM templatestext) LOOP
    out.print('-- TEMPLATE : ' || x.id);
    out.print('DECLARE' || CHR(10) || '  v_clob CLOB;' || CHR(10) || '  v_id varchar2(61) := '''||x.id||''';');
    out.print('  v_descr varchar2(200) := ''' || x.description ||''';' || CHR(10) ||'BEGIN');
    v_text := types.toText(x.template_source, p_chunkSize => 50);
    FOR x IN v_text.first..v_text.last LOOP
      v_text(x) := '  out.append(v_clob, utl_raw.cast_to_varchar2(''' || utl_raw.cast_to_raw(v_text(x)) || '''));';
    END LOOP;
    out.print(v_text);
    out.print('  --'||CHR(10)||'  INSERT INTO templatestext(id, template_source, description) values (v_id, v_clob, v_descr);');
    out.print('  --' ||CHR(10)|| '  COMMIT;' || CHR(10) || 'END;' || CHR(10) || '/');
    out.print('--' || RPAD('=',80,'='));
  END LOOP;
END;