CREATE OR REPLACE PACKAGE BODY stats
IS
-- global cursors
CURSOR CUR_STAT (p_sid number) IS
  SELECT sn.STATISTIC#, sn.NAME, st.value
  FROM v$sesstat st
    JOIN v$statname sn ON sn.STATISTIC# = st.statistic#
  WHERE st.sid = p_sid
  ORDER BY sn.statistic#;

-- global types
TYPE T_STATS IS TABLE OF CUR_STAT%ROWTYPE;

-- global vars
vStatsBefore T_STATS;
vStatsAfter T_STATS;

PROCEDURE i_flush
IS
BEGIN
  vStatsBefore := T_STATS();
  vStatsAfter := T_STATS();
END;

PROCEDURE i_fetch
  (p_sid NUMBER
  ,p_Stats OUT T_STATS)
IS
BEGIN
  OPEN CUR_STAT(p_sid);
  FETCH CUR_STAT BULK COLLECT INTO p_Stats;
  CLOSE CUR_STAT;
END;

PROCEDURE sstart
  (p_sid number)
IS
BEGIN
  i_flush;
  i_fetch(p_sid, vStatsBefore);
END sstart;

PROCEDURE eend
  (p_sid number)
IS
  v_Diff NUMBER;
BEGIN
  i_fetch(p_sid, vStatsAfter);
  FOR x IN vStatsBefore.first..vStatsBefore.last LOOP
    v_Diff := vStatsAfter(x).value - vStatsBefore(x).value;
    IF v_Diff != 0 THEN
      dbms_output.put_line(rpad(vStatsBefore(x).statistic#, 5, '.') || rpad(vStatsBefore(x).name, 70, '.') || v_Diff);
    END IF;
  END LOOP;
  i_flush;
END eend;


END stats;
/
