CREATE OR REPLACE PROCEDURE temp$_exception_handler(p_description VARCHAR, p_condition BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF p_condition THEN
    raise_application_error(-20000, p_description);
  END IF;
END temp$_exception_handler;
/