
DECLARE
  TYPE temp_tier_t IS RECORD(sourcetierid NUMBER, newtierid NUMBER, tiername VARCHAR2(100), sp44 VARCHAR2(100), sp431 VARCHAR2(100), servicename VARCHAR2(100)
                            ,uwname VARCHAR2(100), dlMprice NUMBER, dlAprice NUMBER, incdl NUMBER, maxdl NUMBER);
  TYPE tiers_t IS TABLE OF temp_tier_t INDEX BY PLS_INTEGER;
  v_file utl_file.file_type;
--  v_bbid NUMBER := 86601; v_ttid NUMBER := 46125; v_tiersbeer types.text_t; v_bbbeer types.text_t; v_ttbeer types.text_t;
  v_tiers tiers_t;
  v_t temp_tier_t;
  v_fuck CLOB; v_fuck2 CLOB;
  v_p1main types.text_t; v_p1rback types.text_t; v_p3main types.text_t; v_p3rback types.text_t; v_cdbmain types.text_t; v_cdbrback types.text_t;
  PROCEDURE ini_tier_elem (sourcetierid NUMBER, newtierid NUMBER, tiername VARCHAR2, sp44 VARCHAR2, sp431 VARCHAR2, servicename VARCHAR2
                          ,uwname VARCHAR2, dlMprice NUMBER, dlAprice NUMBER, incdl NUMBER, maxdl NUMBER) IS
  BEGIN
    v_tiers(nvl(v_tiers.last+1,1)).sourcetierid := sourcetierid; v_tiers(nvl(v_tiers.last,1)).newtierid := newtierid;
    v_tiers(nvl(v_tiers.last,1)).tiername := tiername; v_tiers(nvl(v_tiers.last,1)).sp44 := sp44; v_tiers(nvl(v_tiers.last,1)).sp431 := sp431;
    v_tiers(nvl(v_tiers.last,1)).servicename := servicename; v_tiers(nvl(v_tiers.last,1)).uwname := uwname; v_tiers(nvl(v_tiers.last,1)).dlMprice := dlMprice;
    v_tiers(nvl(v_tiers.last,1)).dlAprice := dlAprice; v_tiers(nvl(v_tiers.last,1)).incdl := incdl;
    v_tiers(nvl(v_tiers.last,1)).maxdl := maxdl;
  END;
BEGIN
  ini_tier_elem(4466, 4634, 'US_RCO_2_UNL', 'Office 2 line', 'RC Office 2 line UNL', 'RC US Office Unlimited', 'RC US - Office Unlimited 2 Line', 54.99, 539.88
, 2, 19);
  ini_tier_elem(4467, 4635, 'US_RCO_20_UNL', 'Office 20 line', 'RC Office 20 line UNL', 'RC US Office Unlimited', 'RC US - Office Unlimited 20 Line', 49.99, 479.88
, 20, 99);
  ini_tier_elem(4468, 4636, 'US_RCO_100_UNL', 'Office 100 line', 'RC Office 100 line UNL', 'RC US Office Unlimited', 'RC US - Office Unlimited 100 Line', 39.99, 359.88
, 100, 999);
  ini_tier_elem(4476, 4637, 'CAN_RCO_2_UNL', 'Office 2 line', 'RC Office 2 line UNL', 'RC CAN Office Unlimited', 'RC CAN - Office Unlimited 2 Line', 54.99, 539.88, 2, 19);
  ini_tier_elem(4477, 4638, 'CAN_RCO_20_UNL', 'Office 20 line', 'RC Office 20 line UNL', 'RC CAN Office Unlimited', 'RC CAN - Office Unlimited 20 Line', 49.99, 479.88, 20, 99);
  ini_tier_elem(4478, 4639, 'CAN_RCO_100_UNL', 'Office 100 line', 'RC Office 100 line UNL', 'RC CAN Office Unlimited', 'RC CAN - Office Unlimited 100 Line', 39.99, 359.88, 100, 999);
--
  rctiers.setStartId('boxbilling', 89172);
  rctiers.setStartId('tiertransitions', 46125);
  rctiers.setStartId('billingplans', 8902);
  rctiers.setStartId('features', 574);
  rctiers.setStartId('pricedescriptors', 2974);
--
  FOR x IN v_tiers.first..v_tiers.last LOOP
    v_t := v_tiers(x);
--    dbms_output.put_line(v_tiers(x).sourcetierid);
    rctiers.Initialize(v_t.sourcetierid, v_t.newtierid);
    rctiers.c$Names(v_t.tiername, v_t.sp44, v_t.sp431, v_t.servicename, v_t.uwname);
    rctiers.c$UnlimDLPrices(v_t.dlMprice, v_t.dlAprice);
    rctiers.chgServices(313, v_t.incdl);
    rctiers.chgServices(375, v_t.maxdl);
    v_fuck2 := rctiers.c$BillingPlans(v_t.dlMprice*v_t.incdl, v_t.dlAprice*v_t.incdl);
    rctiers.ExecAndFill;
--    out.append(v_tiersbeer, generics.GetAsInsert(v_tier('TIERS')));    
--    out.append(v_bbbeer, generics.GetAsInsert(v_tier('BOXBILLING')));
--    out.append(v_ttbeer, generics.GetAsInsert(v_tier('TIERTRANSITIONS')));
  --  rctiers.PrintSel;
    v_fuck := rctiers.GetP1Main;
    out.print(types.totext(v_fuck2));
    templates.bind(v_fuck, 'billingplansdata', v_fuck2);
    types.append(v_p1main, types.totext(v_fuck));
     types.append(v_p1rback, types.totext(rctiers.GetP1Rback));
    types.append(v_p3main, types.totext(rctiers.GetP3Main)); types.append(v_p3rback, types.totext(rctiers.GetP3Rback));
    types.append(v_cdbmain, types.totext(rctiers.GetCDBMain)); types.append(v_cdbrback, types.totext(rctiers.GetCDBRback));
  END LOOP;
--  out.print(v_p1main);
--  out.print(v_tiersbeer);
--  out.print(v_bbbeer);
--  out.print(v_ttbeer);
--  dbms_output.put_line(v_p1main.count);
  out.write('DATA_PUMP_DIR', 'SWT-4434_new_unl_tiers_p1.sql', v_p1main);
  out.write('DATA_PUMP_DIR', 'SWT-4434_new_unl_tiers_p3.sql', v_p3main);
  out.write('DATA_PUMP_DIR', 'SWT-4436_new_unl_tiers_cdb.sql', v_cdbmain);
  out.write('DATA_PUMP_DIR', 'SWT-4436_new_unl_tiers_cdb_rback.sql', v_cdbrback);
  out.write('DATA_PUMP_DIR', 'SWT-4434_new_unl_tiers_p3_rback.sql', v_p3rback);
  out.write('DATA_PUMP_DIR', 'SWT-4434_new_unl_tiers_p1_rback.sql', v_p1rback);
END;
/
