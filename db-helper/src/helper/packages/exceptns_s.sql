CREATE OR REPLACE PACKAGE exceptns
IS

  exTabOrViewNotExists EXCEPTION;
  PRAGMA EXCEPTION_INIT (exTabOrViewNotExists, -00942);

END exceptns;
/