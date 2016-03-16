CREATE OR REPLACE PACKAGE stats
IS

PROCEDURE sstart
  (p_sid NUMBER);

PROCEDURE eend
  (p_sid NUMBER);

END stats;
/