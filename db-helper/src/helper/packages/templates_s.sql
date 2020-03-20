CREATE OR REPLACE PACKAGE templates IS

FUNCTION getTemplate
  (p_id VARCHAR2
  ) RETURN CLOB;

PROCEDURE bind
  (p_template IN OUT NOCOPY CLOB
  ,p_oldsub VARCHAR2
  ,p_newsub VARCHAR2);

PROCEDURE bind
  (p_template IN OUT NOCOPY CLOB
  ,p_oldsub VARCHAR2
  ,p_newsub CLOB);

PROCEDURE bind
  (p_template IN OUT NOCOPY CLOB
  ,p_subs types.assocstringarray_t);

END templates;
/