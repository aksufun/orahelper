CREATE OR REPLACE PACKAGE BODY rctiers IS

gv_sourcetierid NUMBER; gv_newtierid NUMBER; gv_brandid NUMBER;
gv_counters types.assocstringarray_t;

gv_shitreplacements TYPEs.assocstringarray_t;

PROCEDURE setStartId (p_tabname VARCHAR2, p_num NUMBER)
IS
BEGIN
  gv_counters(p_tabname) := p_num;
END setStartId;

FUNCTION getNextId (p_tabname VARCHAR2) RETURN NUMBER
IS
BEGIN
  gv_counters(p_tabname) := gv_counters(p_tabname) + 1;
  RETURN gv_counters(p_tabname);
END getNextId;

FUNCTION getCurId (p_tabname VARCHAR2) RETURN NUMBER
IS
BEGIN
  RETURN gv_counters(p_tabname);
END getCurId;

PROCEDURE i_flush_global_vars
IS
BEGIN
  gv_tier.delete;
  gv_sourcetierid := NULL; gv_newtierid := NULL;
END i_flush_global_vars;

PROCEDURE i_appendToBillet
  (p_tabname VARCHAR2
  ,p_rulesfieldname VARCHAR2 DEFAULT NULL
  ,p_rulesruleval VARCHAR2 DEFAULT NULL
  ,p_where VARCHAR2 DEFAULT NULL)
IS
  v_tabname VARCHAR2(32000) := upper(replace(p_tabname,' ',''));
  v_rulesfieldname VARCHAR2(32000) := upper(replace(p_rulesfieldname,' ',''));
  v_where VARCHAR2(32000) := upper(replace(p_where,' ',''));
BEGIN
  temp$_exception_handler('i_appendToBillet : p_tabname cannot be blank!', v_tabname IS NULL);
  IF v_where IS NOT NULL THEN
    BEGIN
      gv_tier(v_tabname).billet.xwhere := gv_tier(v_tabname).billet.xwhere || ' ' ||p_where;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        gv_tier(v_tabname).billet.xwhere := p_where;
    END;
  END IF;
  IF v_rulesfieldname IS NOT NULL THEN
    BEGIN
      gv_tier(v_tabname).billet.xrules(v_rulesfieldname) := gv_tier(v_tabname).billet.xrules(v_rulesfieldname) || ' ' || p_rulesruleval;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        gv_tier(v_tabname).billet.xrules(v_rulesfieldname) := p_rulesruleval;
    END;
  END IF;
END i_appendToBillet;

PROCEDURE Initialize
  (p_sourcetierid NUMBER
  ,p_newtierid NUMBER)

IS
BEGIN
  i_flush_global_vars;
  gv_sourcetierid := p_sourcetierid; gv_newtierid := p_newtierid;
  SELECT brandid INTO gv_brandid FROM zportal.tiers t WHERE t.servicelevel = gv_sourcetierid;
  -- TIERS
  i_appendToBillet('ZPORTAL.TIERS', 'SERVICELEVEL', 'WHEN 1=1 THEN ' || gv_newtierid, 'SERVICELEVEL = ' || gv_sourcetierid);
  -- BOXBILLING
  i_appendToBillet('ZPORTAL.BOXBILLING', 'SERVICELEVEL', 'WHEN 1=1 THEN ' || gv_newtierid, 'SERVICELEVEL = ' || gv_sourcetierid);
--  i_appendToBillet('ZPORTAL.BOXBILLING', 'DATEFROM', 'WHEN 1=1 THEN current_date-1', p_where => 'AND dateto is null');
  i_appendToBillet('ZPORTAL.BOXBILLING', 'BOXPRICEID', 'WHEN 1=1 THEN rctiers.getNextId(''boxbilling'')');
  -- BONUSGROUPSGROUPING
--  i_appendToBillet('ZPORTAL.BONUSGROUPSGROUPING', 'TIERID', 'WHEN 1=1 THEN ' || gv_newtierid, 'TIERID = ' || gv_sourcetierid);
  -- BRANDTAXES
  i_appendToBillet('ZPORTAL.BRANDTAXES', 'SERVICELEVEL', 'WHEN 1=1 THEN ' || gv_newtierid, 'SERVICELEVEL = ' || gv_sourcetierid);
  -- DLPLANMAPPING
--  i_appendToBillet('ZPORTAL.DLPLANMAPPING', 'SERVICELEVEL', 'WHEN 1=1 THEN ' || gv_newtierid, 'SERVICELEVEL = ' || gv_sourcetierid);
  -- DLPLANMIGRATION
--  i_appendToBillet('ZPORTAL.DLPLANMIGRATION', 'SOURCETIER', 'WHEN '||generics.q('val')||' = '||gv_sourcetierid||' THEN ' || gv_newtierid);
--  i_appendToBillet('ZPORTAL.DLPLANMIGRATION', 'TARGETTIER', 'WHEN '||generics.q('val')||' = '||gv_sourcetierid||' THEN ' || gv_newtierid);
--  i_appendToBillet('ZPORTAL.DLPLANMIGRATION', p_where => gv_sourcetierid || ' IN (SOURCETIER, TARGETTIER)');
-- LIMIVALUES
  i_appendToBillet('ZPORTAL.LIMITVALUES', 'SERVICELEVEL', 'WHEN 1=1 THEN ' || gv_newtierid, 'SERVICELEVEL = ' || gv_sourcetierid);
  -- SERVICERATES
--  i_appendToBillet('ZPORTAL.SERVICERATES', 'SERVICELEVEL', 'WHEN 1=1 THEN ' || gv_newtierid, 'SERVICELEVEL = ' || gv_sourcetierid);
  -- SERVICES
  i_appendToBillet('ZPORTAL.SERVICES', 'SERVICELEVEL', 'WHEN 1=1 THEN ' || gv_newtierid, '1 = 2');
  -- TIERLINEPRICES
--  i_appendToBillet('ZPORTAL.TIERLINEPRICES', 'SERVICELEVEL', 'WHEN 1=1 THEN ' || gv_newtierid, 'SERVICELEVEL = ' || gv_sourcetierid);
  -- CONFIRMATIONEMAILMAPPING
--  i_appendToBillet('ZPORTAL.CONFIRMATIONEMAILMAPPING', 'SERVICELEVEL', 'WHEN 1=1 THEN ' || gv_newtierid, 'SERVICELEVEL = ' || gv_sourcetierid);
  -- PHSBRANDS
  -- TIERTRANSITIONS
  i_appendToBillet('ZPORTAL.TIERTRANSITIONS', 'SOURCETIER', 'WHEN '||generics.q('val')||' = '||gv_sourcetierid||' THEN ' || gv_newtierid);
  i_appendToBillet('ZPORTAL.TIERTRANSITIONS', 'TARGETTIER', 'WHEN '||generics.q('val')||' = '||gv_sourcetierid||' THEN ' || gv_newtierid);
  i_appendToBillet('ZPORTAL.TIERTRANSITIONS', p_where => gv_sourcetierid || ' IN (SOURCETIER, TARGETTIER)');
  i_appendToBillet('ZPORTAL.TIERTRANSITIONS', 'ISUPGRADE', 'WHEN 1=1 THEN rctiers.getNextId(''tiertransitions'')');
--  i_appendToBillet('ZPORTAL.PHSBRANDS', 'SERVICELEVEL', 'WHEN 1=1 THEN ' || gv_newtierid, 'SERVICELEVEL = ' || gv_sourcetierid);
  -- TIERS_MANAGEMENT_INFO
  i_appendToBillet('SPORTAL.TIERS_MANAGEMENT_INFO', 'SERVICELEVEL', 'WHEN 1=1 THEN ' || gv_newtierid, 'SERVICELEVEL = ' || gv_sourcetierid);
END Initialize;

PROCEDURE ExecAndFill
IS
  v_tableidx VARCHAR2(61);
  v_splittednames stringarray_t;
BEGIN
  v_tableidx := gv_tier.first;
  WHILE (v_tableidx IS NOT NULL) LOOP
    v_splittednames := utils.stringToArray(v_tableidx, '.');
    gv_tier(v_tableidx).instance := generics.GetTableInstance(v_splittednames(1), v_splittednames(2), p_where => gv_tier(v_tableidx).billet.xwhere);
    generics.ModifyData(gv_tier(v_tableidx).instance, gv_tier(v_tableidx).billet.xrules);
    v_tableidx := gv_tier.next(v_tableidx);
  END LOOP;
END ExecAndFill;

FUNCTION GetP1Main RETURN CLOB
IS
  v_template CLOB := templates.GetTemplate(p_id => 'RCTIERS.GETP1MAIN');
BEGIN
  templates.bind(v_template, 'sourcetierid', gv_sourcetierid);
  templates.bind(v_template, 'newtierid', gv_newtierid);
  templates.bind(v_template, 'tiers', generics.GetAsSelect(gv_tier('ZPORTAL.TIERS').instance));
  templates.bind(v_template, 'services', generics.GetAsSelect(gv_tier('ZPORTAL.SERVICES').instance));
  templates.bind(v_template, 'limitvalues', generics.GetAsSelect(gv_tier('ZPORTAL.LIMITVALUES').instance));
  templates.bind(v_template, 'boxbilling', generics.GetAsSelect(gv_tier('ZPORTAL.BOXBILLING').instance));
  -- shit bind
  templates.bind(v_template, gv_shitreplacements);
--  templates.bind(v_template, 'brandtaxes', generics.GetAsSelect(gv_tier('ZPORTAL.BRANDTAXES').instance));
  RETURN v_template;
END GetP1Main;

FUNCTION GetP1Rback RETURN CLOB
IS
  v_template CLOB := templates.GetTemplate(p_id => 'RCTIERS.GETP1RBACK');
BEGIN
  templates.bind(v_template, 'newtierid', gv_newtierid);
  templates.bind(v_template, 'brandid', gv_brandid);
  templates.bind(v_template, 'v_pdid', GetCurId('pricedescriptors')-1);
  templates.bind(v_template, 'v_bpid', GetCurId('billingplans')-3);
  templates.bind(v_template, 'v_fid', GetCurId('features')-1);
  RETURN v_template;
END GetP1Rback;

FUNCTION GetP3Main RETURN CLOB
IS
  v_template CLOB := templates.GetTemplate(p_id => 'RCTIERS.GETP3MAIN');
BEGIN
  templates.bind(v_template, 'tiertransitions', generics.GetAsSelect(gv_tier('ZPORTAL.TIERTRANSITIONS').instance));
  RETURN v_template;
END GetP3Main;

FUNCTION GetP3Rback RETURN CLOB
IS
  v_template CLOB := templates.GetTemplate(p_id => 'RCTIERS.GETP3RBACK');
BEGIN
  templates.bind(v_template, 'newtierid', gv_newtierid);
  RETURN v_template;
END GetP3Rback;

FUNCTION GetCDBMain RETURN CLOB
IS
  v_template CLOB := templates.GetTemplate(p_id => 'RCTIERS.GETCDBMAIN');
BEGIN
  templates.bind(v_template, 'tiers_management_info', generics.GetAsSelect(gv_tier('SPORTAL.TIERS_MANAGEMENT_INFO').instance));
  RETURN v_template;
END GetCDBMain;

FUNCTION GetCDBRback RETURN CLOB
IS
  v_template CLOB := templates.GetTemplate(p_id => 'RCTIERS.GETCDBRBACK');
BEGIN
  templates.bind(v_template, 'newtierid', gv_newtierid);
  RETURN v_template;
END GetCDBRback;

PROCEDURE DebugPrintAll
IS
  v_tableidx VARCHAR2(61);
  v_rulefieldidx VARCHAR2(30);
  PROCEDURE p (p_str VARCHAR2, p_pad NUMBER DEFAULT 0) IS BEGIN dbms_output.put_line(rpad(' ', p_pad, ' ') || p_str); END;
BEGIN
  v_tableidx := gv_tier.first;
  WHILE (v_tableidx IS NOT NULL) LOOP
    p(v_tableidx);
    p('WHERE:',2);
    p(gv_tier(v_tableidx).billet.xwhere, 4);
    p('RULES:',2);
    v_rulefieldidx := gv_tier(v_tableidx).billet.xrules.first;
    WHILE (v_rulefieldidx IS NOT NULL) LOOP
      p(rpad(v_rulefieldidx, 30) || gv_tier(v_tableidx).billet.xrules(v_rulefieldidx), 4);
      v_rulefieldidx := gv_tier(v_tableidx).billet.xrules.next(v_rulefieldidx);
    END LOOP;
    p('DATA:', 2);
    p('ROWS:' || gv_tier(v_tableidx).instance.data.count, 4);
    v_tableidx := gv_tier.next(v_tableidx);
    IF v_tableidx IS NOT NULL THEN
      dbms_output.put_line('');
    END IF;
  END LOOP;
END DebugPrintAll;

PROCEDURE chgServices
  (p_parameter NUMBER
  ,p_value NVARCHAR2)
IS
BEGIN
  i_appendToBillet('ZPORTAL.SERVICES'
                  , 'VALUE', ' WHEN <[PARAMETER]> = '||p_parameter
                             ||' THEN n''' || asciistr(p_value) || ''''
                  , ' OR (PARAMETER = '||p_parameter||' AND SERVICELEVEL = ' || gv_sourcetierid||')');
END chgServices;

FUNCTION c$BillingPlans
  (p_monthlyPrice NUMBER
  ,p_annualPrice NUMBER
  ) RETURN CLOB
IS
  v_planname VARCHAR2(32);
  v_planprice NUMBER;
  v_plandur NUMBER;
  v_bpid NUMBER; v_pdid NUMBER; v_fid NUMBER;
  v_result CLOB;
BEGIN
  IF p_monthlyPrice IS NULL OR p_annualPrice IS NULL THEN
    temp$_exception_handler('c$BillingPlans: All params should be specified!');
  END IF;
  IF NOT ( gv_counters.exists('billingplans') AND gv_counters.exists('features') AND gv_counters.exists('pricedescriptors') ) THEN
    temp$_exception_handler('c$BillingPlans: Counters for BillingPlans are not defined!');
  END IF;
--
  FOR x IN (SELECT DISTINCT bp1.*
            FROM zportal.tiertransitions tt
              JOIN zportal.billingplans bp1 ON bp1.planid = tt.sourceplan
            WHERE (gv_sourcetierid) IN (tt.sourcetier, tt.targettier)
              AND bp1.billingprice != 0
            UNION
            SELECT DISTINCT bp1.*
            FROM zportal.tiertransitions tt
              JOIN zportal.billingplans bp1 ON bp1.planid = tt.targetplan
            WHERE (gv_sourcetierid) IN (tt.sourcetier, tt.targettier)
              AND bp1.billingprice != 0)
  LOOP
    v_pdid := GetNextId('pricedescriptors'); v_bpid := GetNextId('billingplans'); v_fid := GetNextId('features');
    CASE
      WHEN x.planname LIKE 'Annual%' THEN
        v_planname := SUBSTR(x.planname, 1, INSTR(x.planname, '-')) || p_annualPrice || SUBSTR(x.planname, INSTR(x.planname, '-', 1, 2));
        v_planprice := p_annualPrice;
        v_plandur := 12;
      ELSE
        v_planname := SUBSTR(x.planname, 1, INSTR(x.planname, '-')) || p_monthlyPrice || SUBSTR(x.planname, INSTR(x.planname, '-', 1, 2));
        v_planprice := p_monthlyPrice;
        v_plandur := 1;
    END CASE;
    v_result := v_result || 'INSERT INTO billingplans VALUES ('||v_bpid||','''||v_planname||''','||v_planprice||','
                ||x.mduration||','||x.dduration||','||x.deleted||','||x.restricted||','||x.id_currency||');' || chr(10);
    i_appendToBillet('ZPORTAL.TIERTRANSITIONS', 'SOURCEPLAN', 'WHEN '||generics.q('val')||'='||x.planid||' THEN '||v_bpid);
    i_appendToBillet('ZPORTAL.TIERTRANSITIONS', 'TARGETPLAN', 'WHEN '||generics.q('val')||'='||x.planid||' THEN '||v_bpid);
    i_appendToBillet('ZPORTAL.LIMITVALUES', 'PLANID', 'WHEN '||generics.q('val')||'='||x.planid||' THEN '||v_bpid);
    IF v_planname LIKE 'Monthly%' OR v_planname LIKE 'Annual%' THEN
      IF v_planname LIKE 'Monthly%' THEN
        gv_shitreplacements('oldmonthlyplan') := x.planid;
        gv_shitreplacements('newmonthlyplan') := v_bpid;
      END IF;
      IF v_planname LIKE 'Annual%' THEN
        gv_shitreplacements('oldannualplan') := x.planid;
        gv_shitreplacements('newannualplan') := v_bpid;
      END IF;
      v_result := v_result || 'INSERT INTO features VALUES ('||v_fid||','||v_bpid||',''Subscription Fee'',28);' || chr(10);
      v_result := v_result || 'INSERT INTO pricedescriptors VALUES ('||v_fid||','||v_pdid
                  ||',NULL, NULL, ''Subscription Fee'', 1, 0, 39);' || chr(10);
      i_appendToBillet('ZPORTAL.BOXBILLING', 'PRICEDESCRIPTORID', 'WHEN (SELECT COUNT(*) FROM zportal.pricedescriptors pd JOIN zportal.features f ON f.featureid = pd.featureid JOIN zportal.billingplans bp ON bp.planid = f.referenceid WHERE pd.pricedescriptorid = <[PRICEDESCRIPTORID]> AND bp.mduration = '||v_plandur||' AND <[DATETO]> IS NULL AND <[FEATURETYPE]> = 28)=1 THEN ' || v_pdid);
      i_appendToBillet('ZPORTAL.BOXBILLING', 'PRICE', 'WHEN (SELECT COUNT(*) FROM zportal.pricedescriptors pd JOIN zportal.features f ON f.featureid = pd.featureid JOIN zportal.billingplans bp ON bp.planid = f.referenceid WHERE pd.pricedescriptorid = <[PRICEDESCRIPTORID]> AND bp.mduration = '||v_plandur||' AND <[DATETO]> IS NULL AND <[FEATURETYPE]> = 28)=1 THEN ' || v_planprice);
--      i_appendToBillet('ZPORTAL.BRANDTAXES', 'TAXABLEITEMID', 'WHEN <[TAXABLEITEMTYPEID]> = 1 AND <[TAXABLEITEMID]> = '||x.planid||' THEN '||v_bpid);
      
    END IF;
    
  END LOOP;
  RETURN v_result;
END c$BillingPlans;

PROCEDURE c$Names
  (p_tiername VARCHAR2
  ,p_44param VARCHAR2
  ,p_431param VARCHAR2
  ,p_tmi_servicename VARCHAR2
  ,p_tmi_uwname VARCHAR2)
IS
BEGIN
  IF p_tiername IS NOT NULL THEN
    i_appendToBillet('ZPORTAL.TIERS', 'TIERNAME', 'WHEN 1=1 THEN ''' || p_tiername || '''');
  END IF;
  IF p_44param IS NOT NULL THEN
    chgServices(44, p_44param);
  END IF;
  IF p_431param IS NOT NULL THEN
    chgServices(431, p_431param);
  END IF;
  IF p_tmi_servicename IS NOT NULL THEN
    i_appendToBillet('SPORTAL.TIERS_MANAGEMENT_INFO', 'SERVICE_NAME', 'WHEN 1=1 THEN ''' || p_tmi_servicename || '''');
  END IF;
  IF p_tmi_uwname IS NOT NULL THEN
    i_appendToBillet('SPORTAL.TIERS_MANAGEMENT_INFO', 'UPGRADE_WIZARD_NAME', 'WHEN 1=1 THEN ''' || p_tmi_uwname || '''');
  END IF;
END c$Names;

PROCEDURE c$UWStatus
  (p_status NUMBER)
IS
BEGIN
  i_appendToBillet('SPORTAL.TIERS_MANAGEMENT_INFO', 'UPGRADE_WIZARD_STATUS', 'WHEN 1=1 THEN ' || p_status);
END c$UWStatus;

PROCEDURE c$UnlimDLPrices
  (p_monthlyPrice NUMBER
  ,p_annualPrice NUMBER)
IS
BEGIN
  IF p_annualPrice IS NOT NULL THEN
    i_appendToBillet('ZPORTAL.BOXBILLING', 'PRICE', 'WHEN <[FEATURETYPE]> = 17 AND (SELECT COUNT(*) FROM zportal.DESCRIPTORCONTENTS DC WHERE dc.pricedescriptorid = <[PRICEDESCRIPTORID]> and dc.contentdescriptorid = 12) > 0 THEN ' ||p_annualPrice||'WHEN <[FEATURETYPE]> = 17 AND (SELECT COUNT(*) FROM zportal.DESCRIPTORCONTENTS DC WHERE dc.pricedescriptorid = <[PRICEDESCRIPTORID]> and dc.contentdescriptorid = 12) = 0 THEN '||p_monthlyprice);
  END IF;
END c$UnlimDLPrices;

END rctiers;
/