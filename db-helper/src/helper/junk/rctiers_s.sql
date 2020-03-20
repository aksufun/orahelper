CREATE OR REPLACE PACKAGE RCTIERS IS

TYPE tier_t IS TABLE OF generics.tableinstance_t INDEX BY VARCHAR2(30);
-- counters
/*
SELECT (SELECT MAX(isupgrade) + 1 FROM tiertransitions)
       || ', ' || (SELECT MAX(boxpriceid) + 1 FROM boxbilling)
       || ', ' || (SELECT MAX(groupid) + 1 FROM bonusgroups)
FROM dual
*/

FUNCTION Initialize
  (p_sourcetierid NUMBER
  ,p_newtierid NUMBER
  ,p_bbid NUMBER
  ,p_ttid NUMBER
  ) RETURN tier_t;
                          
PROCEDURE changeUWStatus
  (p_tier IN OUT NOCOPY tier_t
  ,p_status NUMBER);

PROCEDURE changeName
  (p_tier IN OUT NOCOPY tier_t
  ,p_tiername VARCHAR2
  ,p_44param VARCHAR2
  ,p_431param VARCHAR2
  ,p_tmi_servicename VARCHAR2
  ,p_tmi_uwname VARCHAR2);

PROCEDURE changeDLUnlimPrice
  (p_tier IN OUT NOCOPY tier_t
  ,p_monthlyprice NUMBER
  ,p_annualprice NUMBER);

PROCEDURE changeIncludedDL
  (p_tier IN OUT NOCOPY tier_t
  ,p_count NUMBER);

PROCEDURE changeMaxDL
  (p_tier IN OUT NOCOPY tier_t
  ,p_count NUMBER);

FUNCTION GetCDBMain
  (p_tier tier_t
  ) RETURN out.text_t;

FUNCTION GetCDBRback
  (p_tier tier_t
  ) RETURN out.text_t;

FUNCTION GetP1Main
  (p_tier tier_t
  ) RETURN out.text_t;

  FUNCTION GetP1Rback
  (p_tier tier_t
  ) RETURN out.text_t;

FUNCTION GetP3Main
  (p_tier tier_t
  ) RETURN out.text_t;

FUNCTION GetP3Rback
  (p_tier tier_t
  ) RETURN out.text_t;


PROCEDURE PrintIns (p_tier tier_t);
PROCEDURE PrintSel(p_tier tier_t);

END RCTIERS;
/