CREATE OR REPLACE PACKAGE utils IS


SLICEROW CONSTANT CHAR := '-';
SLICECOLUMN CONSTANT CHAR := '|';
FUNCTION slice
  (p_tab arrayofstringarray_t
  ,p_direction CHAR
  ,p_index NUMBER
  ) RETURN stringarray_t;

FUNCTION stringToArrayPipelined
  (p_string VARCHAR2
  ,p_delim VARCHAR2 DEFAULT ','
  ) RETURN stringarray_t PIPELINED;

FUNCTION stringToArray
  (p_string VARCHAR2
  ,p_delim VARCHAR2 DEFAULT ','
  ) RETURN stringarray_t;

FUNCTION arrayToString
  (p_array stringarray_t
  ,p_delim VARCHAR2 DEFAULT ','
  ,p_lbracket VARCHAR2 DEFAULT ''
  ,p_rbracket VARCHAR2 DEFAULT ''
  ) RETURN VARCHAR2;

FUNCTION bulkReplace
  (p_source VARCHAR2
  ,p_fromto types.assocstringarray_t
  ) RETURN VARCHAR2;

FUNCTION NVL2
  (p_val1 VARCHAR2
  ,p_val2 VARCHAR2
  ,p_val3 VARCHAR2
  ) RETURN VARCHAR2;

FUNCTION decode
  (p_val1 VARCHAR2
  ,p_val2 VARCHAR2
  ,p_val3 VARCHAR2
  ,p_val4 VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

END utils;
/