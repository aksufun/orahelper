CREATE OR REPLACE PACKAGE generics IS

TYPE tableinstance_t IS RECORD (owner VARCHAR2(30), tabname VARCHAR2(30), header arrayofstringarray_t, data arrayofstringarray_t);

FMSTORETOARRAY CONSTANT NUMBER := 1;
FMRETRIVEFROMARRAY CONSTANT NUMBER := 2;
FUNCTION fm (p_value VARCHAR2, p_type VARCHAR2, p_mode NUMBER DEFAULT 1) RETURN VARCHAR2;

FUNCTION q(p_str VARCHAR2) RETURN VARCHAR2;

FUNCTION GetTableInstance
  (p_owner VARCHAR2
  ,p_tabname VARCHAR2
  ,p_fields VARCHAR2 DEFAULT NULL
  ,p_where VARCHAR2 DEFAULT NULL
  ,p_order VARCHAR2 DEFAULT NULL
  ) RETURN tableinstance_t;

/*FUNCTION GetAsInsert
  (p_instance tableinstance_t
  ,p_ending VARCHAR2 DEFAULT NULL
  ) RETURN types.text_t;*/

FUNCTION GetAsSelect
  (p_instance tableinstance_t
  ) RETURN CLOB;

PROCEDURE ModifyData
  (p_instance IN OUT NOCOPY tableinstance_t
  ,p_rules types.assocstringarray_t);

END generics;
/