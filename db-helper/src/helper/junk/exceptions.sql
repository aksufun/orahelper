CREATE TABLE EXCEPTIONS
(
  id    NUMBER        NOT NULL
, name  VARCHAR2(28)  NOT NULL
, descr VARCHAR2(256)
--
,CONSTRAINT id_negative CHECK (ID < 0)
,CONSTRAINT descr_chk CHECK ((ID BETWEEN -20999 AND -20000 AND descr IS NOT NULL) OR
                             (NOT(ID BETWEEN -20999 AND -20000) AND descr IS NULL))
,CONSTRAINT exceptions_pk PRIMARY KEY (ID)
)
/