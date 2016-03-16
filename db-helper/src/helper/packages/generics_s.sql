CREATE OR REPLACE PACKAGE generics IS

CT_SLICEROW CONSTANT CHAR := '-';
CT_SLICECOL CONSTANT CHAR := '|';

TYPE tableinstance_t IS RECORD (owner VARCHAR2(30), tabname VARCHAR2(30), header arrayofstringarray_t, data arrayofstringarray_t);

FUNCTION slice
  (p_tab arrayofstringarray_t
  ,p_direction CHAR
  ,p_index NUMBER
  ) RETURN stringarray_t;

FUNCTION stringarraytostring
  (p_array stringarray_t
  ,p_delim VARCHAR2 DEFAULT ','
  ) RETURN VARCHAR2;

FUNCTION tostrbytype
  (p_type VARCHAR2
  ,p_element VARCHAR2
  ) RETURN VARCHAR2;

FUNCTION GetTableInstance
  (p_owner VARCHAR2
  ,p_tabname VARCHAR2
  ,p_fields stringarray_t DEFAULT NULL
  ,p_where VARCHAR2 DEFAULT NULL
  ,p_order VARCHAR2 DEFAULT NULL
  ) RETURN tableinstance_t;

FUNCTION GetDataArray
  (p_owner VARCHAR2
  ,p_tabname VARCHAR2
  ,p_fields stringarray_t
  ,p_where VARCHAR2
  ,p_order VARCHAR2
  ) RETURN arrayofstringarray_t;
    
END generics;
/
