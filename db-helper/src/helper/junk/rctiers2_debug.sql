DECLARE
BEGIN
  rctiers.Initialize(4467, 9999, 11111, 22222);
  rctiers.chgServices(44, 'Privet Pupsik');
  rctiers.chgServices(431, 'WTF WTF WTF');
  rctiers.chgServices(313, '111');
  rctiers.chgServices(375, '222');
  rctiers.ExecAndFill;
  rctiers.DebugPrintAll;
  out.print(rctiers.getp1main);
--  out.print(generics.GetAsSelect(rctiers2.gv_tier('ZPORTAL.SERVICES').instance));
--  dbms_output.put_line(rctiers2.gv_tier('TIERS').instance.data.count());
END;
