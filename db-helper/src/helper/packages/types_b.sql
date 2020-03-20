CREATE OR REPLACE PACKAGE BODY types IS

STRMAXSIZE NUMBER := 32767;

PROCEDURE append
  (p_dest IN OUT NOCOPY text_t
  ,p_src text_t)
IS
  v_idx BINARY_INTEGER;
BEGIN
  IF p_src.count != 0 THEN
    v_idx := p_src.first;
    WHILE v_idx IS NOT NULL
    LOOP
      p_dest(nvl(p_dest.last, 0)+1) := p_src(v_idx);
      v_idx := p_src.next(v_idx);
    END LOOP;
  END IF;
END append;

FUNCTION toText
  (p_val CLOB
  ,p_chunkSize NUMBER
  ) RETURN text_t
IS
  v_offset NUMBER := 1;
  v_result text_t;
  v_subs VARCHAR2(32767);
  v_len NUMBER := nvl(dbms_lob.getlength(p_val), 0);
BEGIN
  IF v_len > 0 THEN
    LOOP
      v_subs := dbms_lob.substr(p_val, p_chunkSize, v_offset);
      v_result(utils.decode(v_result.count, 0, 1, v_result.last+1)) := v_subs;
      v_offset := v_offset + p_chunkSize;
      EXIT WHEN v_offset > v_len;
    END LOOP;
  END IF;
  RETURN v_result;
END toText;

FUNCTION toText
  (p_val CLOB
  ,p_delim VARCHAR2
  ) RETURN text_t
IS
  v_delim_length NUMBER := length(p_delim);
  v_subs VARCHAR2(32767);
  v_result text_t;
  v_breakpos NUMBER := 0;
  v_offset NUMBER := 1;
  v_amount NUMBER := 0;
  v_len NUMBER := nvl(dbms_lob.getlength(p_val), 0);
BEGIN
  IF v_len > 0 THEN
    LOOP
      v_breakpos := dbms_lob.instr(p_val, p_delim, v_offset);
      v_amount := utils.decode(v_breakpos, 0, v_len+1, v_breakpos) - v_offset;
      temp$_exception_handler('Section without spaces cannot be more then 32767 chars', v_amount > STRMAXSIZE);
      v_subs := dbms_lob.substr(p_val, v_amount, v_offset);
      v_result(utils.decode(v_result.count, 0, 1, v_result.last+1)) := v_subs;
      v_offset := v_offset + v_amount + utils.decode(v_breakpos, 0, 0, v_delim_length);
      EXIT WHEN v_offset = v_len + 1;
    END LOOP;
  END IF;
  RETURN v_result;
END toText;

END types;
/