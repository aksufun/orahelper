CREATE OR REPLACE PACKAGE rctiers IS

TYPE table_billet_t IS RECORD (xrules types.assocstringarray_t, xwhere VARCHAR2(32000));
TYPE table_t IS RECORD (instance generics.tableinstance_t, billet table_billet_t);
TYPE tables_t IS TABLE OF table_t INDEX BY VARCHAR2(61);

gv_tier tables_t;

PROCEDURE setStartId (p_tabname VARCHAR2, p_num NUMBER);
FUNCTION getNextId (p_tabname VARCHAR2) RETURN NUMBER;

PROCEDURE Initialize
  (p_sourcetierid NUMBER
  ,p_newtierid NUMBER);

PROCEDURE ExecAndFill;

PROCEDURE DebugPrintAll;

FUNCTION GetP1Main RETURN CLOB;
FUNCTION GetP1Rback RETURN CLOB;
FUNCTION GetP3Main RETURN CLOB;
FUNCTION GetP3Rback RETURN CLOB;
FUNCTION GetCDBMain RETURN CLOB;
FUNCTION GetCDBRback RETURN CLOB;

PROCEDURE chgServices
  (p_parameter NUMBER
  ,p_value NVARCHAR2);

PROCEDURE c$Names
  (p_tiername VARCHAR2
  ,p_44param VARCHAR2
  ,p_431param VARCHAR2
  ,p_tmi_servicename VARCHAR2
  ,p_tmi_uwname VARCHAR2);

PROCEDURE c$UWStatus
  (p_status NUMBER);

PROCEDURE c$UnlimDLPrices
  (p_monthlyPrice NUMBER
  ,p_annualPrice NUMBER);

FUNCTION c$BillingPlans
  (p_monthlyPrice NUMBER
  ,p_annualPrice NUMBER
  ) RETURN CLOB;

END rctiers;
/