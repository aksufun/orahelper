CREATE TABLE genericstemplates
(
  procname VARCHAR2(30)
, template_source CLOB
, description VARCHAR2(200)
, PRIMARY KEY (procname)
)
/
DECLARE
  v_source CLOB :=
'SELECT stringarray_t(<FIELDS>)
FROM <OWNERTABLE> 
WHERE 1 = 1 <WHERE> 
ORDER BY <ORDER>';
BEGIN
  INSERT INTO genericstemplates
  VALUES (UPPER('gettablearray'), v_source, 'Template for GenTableArray proc');
--
  COMMIT;
END;
/
