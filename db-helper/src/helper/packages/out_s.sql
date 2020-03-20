CREATE OR REPLACE PACKAGE out IS

PROCEDURE append
  (p_src IN OUT NOCOPY CLOB
  ,p_val CLOB);

PROCEDURE appendln
  (p_src IN OUT NOCOPY CLOB
  ,p_val CLOB);

PROCEDURE print
  (p_src CLOB);

PROCEDURE print
  (p_src types.text_t);

PROCEDURE write
  (p_dir VARCHAR
  ,p_filename VARCHAR2
  ,p_text types.text_t);

/*PROCEDURE appendln
  (p_src IN OUT NOCOPY CLOB
  ,p_val CLOB);*/

/*TODBMSOUTPUT CONSTANT NUMBER := 1;
TODATAPUMPDIR CONSTANT NUMBER := 2;

SUBTYPE text_t IS dbms_sql.varchar2a;

FUNCTION texttoclob
  (p_text text_t
  ) RETURN CLOB;

FUNCTION clobtotext
  (p_clob CLOB
  ) RETURN text_t;

PROCEDURE append
  (p_to IN OUT NOCOPY text_t
  ,p_from VARCHAR2);

PROCEDURE appendln
  (p_to IN OUT NOCOPY text_t
  ,p_from VARCHAR2);

PROCEDURE append
  (p_to IN OUT NOCOPY text_t
  ,p_from VARCHAR2);

PROCEDURE appendln
  (p_to IN OUT NOCOPY text_t
  ,p_from VARCHAR2);

PROCEDURE append
  (p_to IN OUT NOCOPY text_t
  ,p_from text_t);

FUNCTION totext
  (p_data VARCHAR2
  ,p_bcol VARCHAR2 DEFAULT NULL, p_acol VARCHAR2 DEFAULT NULL
  ) RETURN text_t;

FUNCTION totext
  (p_data stringarray_t
  ,p_bdata VARCHAR2 DEFAULT NULL, p_adata VARCHAR2 DEFAULT NULL
  ,p_bcol VARCHAR2 DEFAULT NULL, p_acol VARCHAR2 DEFAULT NULL
  ) RETURN text_t;

FUNCTION totext
  (p_data arrayofstringarray_t
  ,p_bdata VARCHAR2 DEFAULT NULL, p_adata VARCHAR2 DEFAULT NULL
  ,p_brow VARCHAR2 DEFAULT NULL, p_arow VARCHAR2 DEFAULT NULL
  ,p_bcol VARCHAR2 DEFAULT NULL, p_acol VARCHAR2 DEFAULT NULL
  ) RETURN text_t;

PROCEDURE print (p_text text_t);
PROCEDURE print2 (p_text text_t);

--PROCEDURE print(p_val CLOB);;*/

END out;
/