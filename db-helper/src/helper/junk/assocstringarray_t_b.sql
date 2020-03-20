CREATE OR REPLACE TYPE BODY assocstringarray_t AS

keys stringarray_t;
vals stringarray_t;

MEMBER PROCEDURE ins (SELF IN OUT NOCOPY assocstringarray_t, p_key VARCHAR2, p_val VARCHAR2)
IS
BEGIN

END ins;

MEMBER PROCEDURE del (SELF IN OUT NOCOPY assocstringarray_t, p_key VARCHAR2)
IS
BEGIN
  NULL;
END del;

MEMBER PROCEDURE find (SELF IN OUT NOCOPY assocstringarray_t, p_key VARCHAR2)
IS
BEGIN
  NULL;
END find;

END;
/
