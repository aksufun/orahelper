CREATE OR REPLACE PACKAGE types AS

-- Associative Array of strings
TYPE assocstringarray_t IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(4000);
-- Associative Array of Associative arry of strings
TYPE assocarrayofassocstringarray_t IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(4000);
--PROCEDURE asa_add (p_arr assocstringarray_t, p_key VARCHAR2, p_val VARCHAR2);
--PROCEDURE asa_del (p_arr assocstringarray_t, p_key VARCHAR2);
--PROCEDURE asa_find (p_arr assocstringarray_t, p_key VARCHAR2);
-- ========================================

SUBTYPE text_t is dbms_sql.varchar2a;

PROCEDURE append
  (p_dest IN OUT NOCOPY text_t
  ,p_src text_t);

FUNCTION toText
  (p_val CLOB
  ,p_chunkSize NUMBER
  ) RETURN text_t;

FUNCTION toText
  (p_val CLOB
  ,p_delim VARCHAR2
  ) RETURN text_t;

END types;
/