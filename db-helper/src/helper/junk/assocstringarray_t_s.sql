CREATE OR REPLACE TYPE assocstringarray_t AS OBJECT
(
  keys stringarray_t
, vals stringarray_t
, MEMBER PROCEDURE ins (SELF IN OUT NOCOPY assocstringarray_t, p_key VARCHAR2, p_val VARCHAR2)
, MEMBER PROCEDURE del (SELF IN OUT NOCOPY assocstringarray_t, p_key VARCHAR2)
, MEMBER PROCEDURE find (SELF IN OUT NOCOPY assocstringarray_t, p_key VARCHAR2)
)
/
