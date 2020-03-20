CREATE OR REPLACE PACKAGE BODY stuff
IS

PKGCREATESTART CONSTANT VARCHAR2(100) := 'CREATE OR REPLACE PACKAGE <PKGNAME>';
PKGCREATEEND   CONSTANT VARCHAR2(100) := 'END <PKGNAME>;';

PROCEDURE recreateExceptnsPkg
IS
  vStatement dbms_sql.varchar2a;
  vCursorID NUMBER;
  vDummy NUMBER;
BEGIN
  vStatement(1) := replace(PKGCREATESTART, '<PKGNAME>', 'E');
  vStatement(2) := '-- Generated at : ' || current_date;
  vStatement(3) := 'IS';
  vStatement(4) := '--';
  
  FOR excs IN (
               SELECT rownum rn, e.*
               FROM EXCEPTIONS e
               ORDER BY e.id
              )
  LOOP
    vStatement((excs.rn-1)*4+5) := '  ' || excs.name      || ' CONSTANT NUMBER := ' || to_char(excs.id,'09999') || ';';
    vStatement((excs.rn-1)*4+6) := '  ' || excs.name||'#' || ' EXCEPTION;';
    vStatement((excs.rn-1)*4+7) := '  PRAGMA EXCEPTION_INIT (' || excs.name||'#, ' || to_char(excs.id,'09999') || ');';
    vStatement((excs.rn-1)*4+8) := '--';
  END LOOP;
  vStatement(vStatement.count()+1) := replace(PKGCREATEEND, '<PKGNAME>', 'E');
  
  FOR x IN  vStatement.first..vStatement.last LOOP
    dbms_output.put_line(vStatement(x));
  END LOOP;
  vCursorID := dbms_sql.open_cursor;
  dbms_sql.parse(vCursorID, vStatement, vStatement.first, vStatement.last, TRUE, dbms_sql.native);
  dbms_sql .close_cursor(vCursorID);
END recreateExceptnsPkg;

PROCEDURE recreateAll
IS
BEGIN
  recreateExceptnsPkg;
END recreateAll;

END stuff;
/
