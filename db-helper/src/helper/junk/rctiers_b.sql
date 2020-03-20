CREATE OR REPLACE PACKAGE BODY RCTIERS IS

/*TYPE tabinfo_t IS RECORD (tabname VARCHAR2(30), tieridfields stringarray_t, pkeycol VARCHAR2(30), pkeycurval NUMBER);
TYPE tiertabs_t IS TABLE OF tabinfo_t;*/

--gv_tierTabs tiertabs_t;

TIERTABLES CONSTANT stringarray_t := stringarray_t('ZPORTAL,TIERS,SERVICELEVEL'
                                                  ,'ZPORTAL,TIERTRANSITIONS,SOURCETIER,TARGETTIER'
                                                  ,'ZPORTAL,BOXBILLING,SERVICELEVEL'
--                                                  ,'ZPORTAL,BONUSGROUPS,SERVICELEVEL'
                                                  ,'ZPORTAL,BONUSGROUPSGROUPING,TIERID'
                                                  ,'ZPORTAL,BRANDTAXES,SERVICELEVEL'
                                                  ,'ZPORTAL,DLPLANMAPPING,SERVICELEVEL'
                                                  ,'ZPORTAL,DLPLANMIGRATION,SOURCETIER,TARGETTIER'
                                                  ,'ZPORTAL,LIMITVALUES,SERVICELEVEL'
                                                  ,'ZPORTAL,SERVICERATES,SERVICELEVEL'
                                                  ,'ZPORTAL,SERVICES,SERVICELEVEL'
                                                  ,'ZPORTAL,TIERLINEPRICES,SERVICELEVEL'
                                                  ,'ZPORTAL,WEBCALLLIMITS,SERVICELEVEL'
                                                  ,'ZPORTAL,CONFIRMATIONEMAILMAPPING,SERVICELEVEL'
                                                  ,'ZPORTAL,PHSBRANDS,SERVICELEVEL'
                                                  ,'SPORTAL,TIERS_MANAGEMENT_INFO,SERVICELEVEL'
                                      /*,'EXTENSIONTYPENAMES2'*//*,'MARKETINGLINKS'*//*,'PAPERCHECKS'*//*,'UPGRADENOTIFICATIONCONFIG'*/);

/*TABLECOUNTERS CONSTANT stringarray_t := stringarray_t('TIERTRANSITIONS,ISUPGRADE,46125'
                                                     ,'BOXBILLING,BOXPRICEID,86592'
                                                     \*,'BONUSGROUPS,GROUPID'*\);*/
/*
FUNCTION i_getTierTabs RETURN tiertabs_t IS
BEGIN
  IF gv_tierTabs IS NULL THEN
    gv_tierTabs.extend(15);
    gv_tierTabs(3).pkeycurval := 86592;
    gv_tierTabs(1).tabname := 'TIERS'; gv_tierTabs(1).tieridfields := stringarray_t('SERVICELEVEL');
    gv_tierTabs(2).tabname := 'TIERTRANSITIONS'; gv_tierTabs(2).tieridfields := stringarray_t('SOURCETIERL','TARGETTIER');
    gv_tierTabs(3).tabname := 'BOXBILLING'; gv_tierTabs(3).tieridfields := stringarray_t('SERVICELEVEL'); gv_tierTabs(3).pkeycol := 'BOXPRICEID';
  END IF;
  RETURN gv_tierTabs;
END i_getTierTabs;*/

FUNCTION Initialize
  (p_sourcetierid NUMBER
  ,p_newtierid NUMBER
  ,p_bbid NUMBER
  ,p_ttid NUMBER
  ) RETURN tier_t
IS
  v_result tier_t;
  v_tierGenInfo stringarray_t;
  v_whereCond VARCHAR2(1000);
  v_rules types.assocstringarray_t;
BEGIN
  FOR t IN TIERTABLES.first..TIERTABLES.last LOOP
    v_tierGenInfo := utils.stringToArray(TIERTABLES(t));
    v_whereCond := NULL;
    v_rules.delete;
    FOR x IN 3..v_tierGenInfo.last LOOP
      v_whereCond := v_whereCond || v_tierGenInfo(x) || ' = ' || p_sourcetierid || utils.decode(x, v_tierGenInfo.last,'', ' OR ');
      v_rules(v_tierGenInfo(x)) := 'WHEN ' || generics.q('val') || ' = ' || p_sourcetierid || ' THEN ' || p_newtierid;
    END LOOP;
    IF v_tierGenInfo(2) = 'BOXBILLING' THEN
      v_rules('BOXPRICEID') := 'WHEN 1=1 THEN ' || p_bbid || ' + ' || generics.q('rnum');
      v_rules('DATEFROM') := 'WHEN 1=1 THEN cast (trunc(current_date-1) as timestamp) at time zone ''PST''';
    ELSIF v_tierGenInfo(2) = 'TIERTRANSITIONS' THEN
      v_rules('ISUPGRADE') := 'WHEN 1=1 THEN ' || p_ttid || ' + ' || generics.q('rnum');
    END IF;
    v_result(v_tierGenInfo(2)) := generics.GetTableInstance(v_tierGenInfo(1), v_tierGenInfo(2), p_where => v_whereCond);
    generics.ModifyData(v_result(v_tierGenInfo(2)), v_rules);
  END LOOP;
  RETURN v_result;
END Initialize;

FUNCTION GetP1Main
  (p_tier tier_t
  ) RETURN out.text_t
IS
  v_result out.text_t;
BEGIN
  out.appendln(v_result, 'BEGIN');
  FOR x IN TIERTABLES.first..TIERTABLES.last LOOP
    IF instr(TIERTABLES(x), 'TIERTRANSITIONS') != 0 OR instr(TIERTABLES(x), 'TIERS_MANAGEMENT_INFO') != 0 THEN
      CONTINUE;
    END IF;
    out.append(v_result, generics.GetAsInsert(p_tier(utils.stringToArray(TIERTABLES(x))(2))));
  END LOOP;
  out.appendln(v_result, 'COMMIT;');
  out.appendln(v_result, 'END;' || chr(10) || '/');
  RETURN v_result;
END GetP1Main;

FUNCTION GetP3Main
  (p_tier tier_t
  ) RETURN out.text_t
IS
  v_result out.text_t;
BEGIN
  out.appendln(v_result, 'BEGIN');
  out.append(v_result, generics.GetAsInsert(p_tier('TIERTRANSITIONS')));
  out.appendln(v_result, 'COMMIT;');
  out.appendln(v_result, 'END;' || chr(10) || '/');
  RETURN v_result;
END GetP3Main;

FUNCTION GetP1Rback
  (p_tier tier_t
  ) RETURN out.text_t
IS
  v_result out.text_t;
BEGIN
  out.appendln(v_result, REPLACE(templates.GetTemplate('RCTIERS.GETP1RBACK'), '[SERVICELEVEL]', p_tier('TIERS').data(1)(1)));
  RETURN v_result;
END GetP1Rback;

FUNCTION GetP3Rback
  (p_tier tier_t
  ) RETURN out.text_t
IS
  v_result out.text_t;
BEGIN
  out.appendln(v_result, REPLACE(templates.GetTemplate('RCTIERS.GETP3RBACK'), '[SERVICELEVEL]', p_tier('TIERS').data(1)(1)));
  RETURN v_result;
END GetP3Rback;

FUNCTION GetCDBMain
  (p_tier tier_t
  ) RETURN out.text_t
IS
  v_result out.text_t;
BEGIN
  out.appendln(v_result, 'BEGIN');
  out.appendln(v_result, 'IF get_cdb_parameter(''read_only_mode'') = 1 THEN RETURN; END IF;');
  out.append(v_result, generics.GetAsInsert(p_tier('TIERS_MANAGEMENT_INFO')));
  out.appendln(v_result, 'COMMIT;');
  out.appendln(v_result, 'END;' || chr(10) || '/');
  RETURN v_result;
END GetCDBMain;

FUNCTION GetCDBRback
  (p_tier tier_t
  ) RETURN out.text_t
IS
  v_result out.text_t;
BEGIN
  out.appendln(v_result, 'BEGIN');
  out.appendln(v_result, 'IF get_cdb_parameter(''read_only_mode'') = 1 THEN RETURN; END IF;');
  out.appendln(v_result, 'DELETE FROM TIERS_MANAGEMENT_INFO WHERE SERVICELEVEL = ' || p_tier('TIERS').data(1)(1) || ';');
  out.appendln(v_result, 'COMMIT;');
  out.appendln(v_result, 'END;' || chr(10) || '/');
  RETURN v_result;
END GetCDBRback;

PROCEDURE PrintIns
  (p_tier tier_t)
IS
BEGIN
  FOR x IN TIERTABLES.first..TIERTABLES.last LOOP
    out.print(generics.GetAsInsert(p_tier(utils.stringToArray(TIERTABLES(x))(2))));
  END LOOP;
END PrintIns;

PROCEDURE PrintSel
  (p_tier tier_t)
IS
BEGIN
  FOR x IN TIERTABLES.first..TIERTABLES.last LOOP
    out.print(generics.GetAsSelect(p_tier(utils.stringToArray(TIERTABLES(x))(2))));
  END LOOP;
END PrintSel;

PROCEDURE changeUWStatus
  (p_tier IN OUT NOCOPY tier_t
  ,p_status NUMBER)
IS
  v_rules types.assocstringarray_t;
BEGIN
  v_rules('UPGRADE_WIZARD_STATUS') := 'when 1=1 then 1';
  generics.ModifyData(p_tier('TIERS_MANAGEMENT_INFO'), v_rules);
END changeUWStatus;

PROCEDURE changeName
  (p_tier IN OUT NOCOPY tier_t
  ,p_tiername VARCHAR2
  ,p_44param VARCHAR2
  ,p_431param VARCHAR2
  ,p_tmi_servicename VARCHAR2
  ,p_tmi_uwname VARCHAR2)
IS
  v_rules types.assocstringarray_t;
BEGIN
  IF p_tiername IS NOT NULL THEN
    v_rules.delete;
    v_rules('TIERNAME') := 'WHEN 1=1 THEN ''' || p_tiername || '''';
    generics.ModifyData(p_tier('TIERS'), v_rules);
  END IF;
  IF p_44param IS NOT NULL THEN
    v_rules.delete;
    v_rules('VALUE') := 'WHEN ' || generics.q('PARAMETER') || ' = 44 THEN unistr(''' || p_44param || ''')';
    generics.ModifyData(p_tier('SERVICES'), v_rules);
  END IF;
  IF p_431param IS NOT NULL THEN
    v_rules.delete;
    v_rules('VALUE') := 'WHEN ' || generics.q('PARAMETER') || ' = 431 THEN unistr(''' || p_431param || ''')';
    generics.ModifyData(p_tier('SERVICES'), v_rules);
  END IF;
  IF p_tmi_servicename IS NOT NULL THEN
    v_rules.delete;
    v_rules('SERVICE_NAME') := 'WHEN 1=1 THEN ''' || p_tmi_servicename || '''';
    generics.ModifyData(p_tier('TIERS_MANAGEMENT_INFO'), v_rules);
  END IF;
  IF p_tmi_uwname IS NOT NULL THEN
    v_rules.delete;
    v_rules('UPGRADE_WIZARD_NAME') := 'WHEN 1=1 THEN ''' || p_tmi_uwname || '''';
    generics.ModifyData(p_tier('TIERS_MANAGEMENT_INFO'), v_rules);
  END IF;

/*  IF p_customername IS NOT NULL THEN
    temp$_exception_handler('RCTIERS.CHANGENAME: Max len of customer tiername is 80 chars', length(p_internalshort)>16);
    v_rules('SERVICE_NAME') := 'WHEN 1=1 THEN ''' || p_customername || '''';
    generics.ModifyData(p_tier('TIERS_MANAGEMENT_INFO'), v_rules);
  END IF;
  IF p_internalshort IS NOT NULL THEN
    temp$_exception_handler('RCTIERS.CHANGENAME: Max len of internal shortname is 16 chars', length(p_internalshort)>16);
    v_rules.delete;
    v_rules('TIERNAME') := 'WHEN 1=1 THEN ''' || p_internalshort || '''';
    generics.ModifyData(p_tier('TIERS'), v_rules);
    v_rules.delete;
    v_rules('VALUE') := 'WHEN ' || generics.q('PARAMETER') || ' = 431 THEN unistr(''' || p_internalshort || ''')';
    generics.ModifyData(p_tier('SERVICES'), v_rules);
  END IF;
  IF p_uw IS NOT NULL THEN
    v_rules.delete;
    v_rules('VALUE') := 'WHEN ' || generics.q('PARAMETER') || ' = 44 THEN unistr(''' || p_uw || ''')';
    generics.ModifyData(p_tier('SERVICES'), v_rules);
    v_rules.delete;
    v_rules('UPGRADE_WIZARD_NAME') := 'WHEN 1=1 THEN ''' || substr(p_uw, 1, 64) || '''';
    generics.ModifyData(p_tier('TIERS_MANAGEMENT_INFO'), v_rules);
  END IF;*/
END changeName;

PROCEDURE changeDLUnlimPrice
  (p_tier IN OUT NOCOPY tier_t
  ,p_monthlyprice NUMBER
  ,p_annualprice NUMBER)
IS
  v_rules types.assocstringarray_t;
BEGIN
  v_rules('PRICE') := 'WHEN <[FEATURETYPE]> = 17 AND (SELECT COUNT(*) FROM zportal.DESCRIPTORCONTENTS DC WHERE dc.pricedescriptorid = <[PRICEDESCRIPTORID]> and dc.contentdescriptorid = 12) > 0 THEN ' ||p_annualprice||' WHEN <[FEATURETYPE]> = 17 AND (SELECT COUNT(*) FROM zportal.DESCRIPTORCONTENTS DC WHERE dc.pricedescriptorid = <[PRICEDESCRIPTORID]> and dc.contentdescriptorid = 12) = 0 THEN '||p_monthlyprice;
  generics.ModifyData(p_tier('BOXBILLING'), v_rules);
END changeDLUnlimPrice;

PROCEDURE changeIncludedDL
  (p_tier IN OUT NOCOPY tier_t
  ,p_count NUMBER)
IS
  v_rules types.assocstringarray_t;
BEGIN
  v_rules('VALUE') := 'WHEN ' || generics.q('PARAMETER') || ' = 313 THEN unistr(''' || p_count || ''')';
  generics.ModifyData(p_tier('SERVICES'), v_rules);
END changeIncludedDL;

PROCEDURE changeMaxDL
  (p_tier IN OUT NOCOPY tier_t
  ,p_count NUMBER)
IS
  v_rules types.assocstringarray_t;
BEGIN
  v_rules('VALUE') := 'WHEN ' || generics.q('PARAMETER') || ' = 375 THEN unistr(''' || p_count || ''')';
  generics.ModifyData(p_tier('SERVICES'), v_rules);
END changeMaxDL;

END RCTIERS;
/