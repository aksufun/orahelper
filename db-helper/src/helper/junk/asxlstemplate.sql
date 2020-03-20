WITH boxbil AS
(
SELECT * FROM zportal.boxbilling bb WHERE (bb.dateto IS NULL OR bb.dateto > SYSDATE) AND nvl(bb.visible, 1) = 1
)
, head AS
(
 SELECT NULL a, NULL b, NULL c, zportal.gettiername({{servicelevel}}) d ,1 o FROM dual UNION
 SELECT NULL, to_nchar('BrandID'), NULL, (select to_nchar(brandid) FROM zportal.tiers t WHERE t.servicelevel = {{servicelevel}})  , 2 o from dual UNION
 SELECT NULL, to_nchar('TierID'), NULL, to_nchar({{servicelevel}}), 3 o FROM dual
)
, tfb AS
(
SELECT 'Toll-Free Minute bundles' a
       , to_char(tt.description) b
       , CASE WHEN tt.billingcyclelength = 1 THEN to_nchar('Monthly') WHEN tt.billingcyclelength = 12 THEN to_nchar('Annual') END c
       , to_nchar(tt.price) d
       , 6 o
FROM zportal.vtollfreebundles tt
WHERE tt.servicelevel = {{servicelevel}}
)
, dls AS
(
SELECT DISTINCT
       'Common billing' a
     , dl.dl_plan_name b
     , CASE WHEN dl.billingcyclelength = 1 THEN 'Monthly' WHEN dl.billingcyclelength = 12 THEN 'Annual' END c
     , dl.dl_price d
     , 6 o
FROM zportal.vdldevicesex dl
WHERE dl.dl_featuretype IN (18, /*50,*/ 12, 17, 19)
  AND dl.servicelevel = {{servicelevel}}
  AND dl.dl_box_price > 0
)
, blpl AS
(
SELECT 'Common billing' a
     , 'Billing plan' b
     , CASE WHEN bp.mduration = 1 THEN 'Monthly' WHEN bp.mduration = 12 THEN 'Annual' END c
     , bb.price d
     , 7 o
FROM boxbil bb
  JOIN zportal.pricedescriptors pd ON pd.pricedescriptorid = bb.pricedescriptorid
  JOIN zportal.features f ON f.featureid = pd.featureid
  JOIN zportal.billingplans bp ON bp.planid = f.referenceid
WHERE bb.servicelevel = {{servicelevel}}
  AND bb.featuretype = 28

)
, addlextens AS
(
SELECT 'Additional Extensions' a
     , '' b
     , CASE WHEN dc.contentdescriptorid = 12 THEN 'Annual' WHEN dc.contentdescriptorid IS NULL THEN 'Monthly' ELSE '### UNDEFINED! ###' END c
     , bb.price d
     , 8 o
FROM boxbil bb
  JOIN zportal.pricedescriptors pd ON pd.pricedescriptorid = bb.pricedescriptorid
  LEFT JOIN zportal.descriptorcontents dc ON dc.pricedescriptorid = pd.pricedescriptorid
WHERE bb.servicelevel = {{servicelevel}}
  AND bb.featuretype = 1
)
, addltfnumbers AS
(
SELECT 'Additional Toll-Free Number' a
     , '' b
     , CASE WHEN dc.contentdescriptorid = 12 THEN 'Annual' WHEN dc.contentdescriptorid IS NULL THEN 'Monthly' ELSE '### UNDEFINED! ###' END c
     , bb.price d
     , 9 o
FROM boxbil bb
  JOIN zportal.pricedescriptors pd ON pd.pricedescriptorid = bb.pricedescriptorid
  LEFT JOIN zportal.descriptorcontents dc ON dc.pricedescriptorid = pd.pricedescriptorid
WHERE bb.servicelevel = {{servicelevel}}
  AND bb.featuretype = 2
)
, addllocnumbers AS
(
SELECT 'Additional Local Number' a
     , '' b
     , CASE WHEN dc.contentdescriptorid = 12 THEN 'Annual' WHEN dc.contentdescriptorid IS NULL THEN 'Monthly' ELSE '### UNDEFINED! ###' END c
     , bb.price d
     , 10 o
FROM boxbil bb
  JOIN zportal.pricedescriptors pd ON pd.pricedescriptorid = bb.pricedescriptorid
  LEFT JOIN zportal.descriptorcontents dc ON dc.pricedescriptorid = pd.pricedescriptorid
WHERE bb.servicelevel = {{servicelevel}}
  AND bb.featuretype = 3
), true800 AS
(
SELECT 'One time Fees' a
     , 'True 800 Number' b
     , 'One time' c
     , bb.price d
     , 11 o
FROM boxbil bb
  JOIN zportal.pricedescriptors pd ON pd.pricedescriptorid = bb.pricedescriptorid
  LEFT JOIN zportal.descriptorcontents dc ON dc.pricedescriptorid = pd.pricedescriptorid
WHERE bb.servicelevel = {{servicelevel}}
  AND bb.featuretype = 4
),  vanity AS
(
SELECT 'One time Fees' a
     , 'Vanity Number' b
     , 'One time' c
     , bb.price d
     , 12 o
FROM boxbil bb
  JOIN zportal.pricedescriptors pd ON pd.pricedescriptorid = bb.pricedescriptorid
  LEFT JOIN zportal.descriptorcontents dc ON dc.pricedescriptorid = pd.pricedescriptorid
WHERE bb.servicelevel = {{servicelevel}}
  AND bb.featuretype = 4
)
, shipoptions AS
(
SELECT 'Shipping Prices' a
     , vso.Description b
     , vso.MaxQty c
     , vso.price d
     , 15 o
FROM zportal.vshippingoptions vso
WHERE vso.ServiceLevel = {{servicelevel}}
)
, HWD AS
(
SELECT DISTINCT
       CASE WHEN t.featuretype IN (11) THEN 'Hardware (Devices)' WHEN t.featuretype = 39 THEN 'Hardware (Devices - Refurbished)'  WHEN t.featuretype = 34 THEN 'Rental' END a
     ,TRIM(replace(replace(t.device_name, '- Rental', ''), '-Rental')) b
     , CASE WHEN t.featuretype IN (11, 39) AND nvl(t.discountvalue, 0) != 0 THEN 'Discounted Price'
            WHEN t.featuretype IN (11, 39) AND nvl(t.discountvalue, 0) = 0 THEN 'List Price'
            WHEN t.featuretype = 34 AND t.billingcyclelength = 1 THEN 'Monthly'
            WHEN t.featuretype = 34 AND t.billingcyclelength = 12 THEN 'Annual'
       END c
     , CASE WHEN nvl(t.ispercent, 0) = 1 THEN to_nchar(t.device_price - nvl(t.discountvalue,0)*t.device_price) ELSE to_nchar(t.device_price - nvl(t.discountvalue,0)) END d
     , 5 o
FROM zportal.vdldevicesex t
WHERE t.servicelevel = {{servicelevel}}
)
, fn AS
(
SELECT cast(a AS varchar2(1000)) a, cast(b AS varchar2(1000)) b, cast(c AS varchar2(1000)) c, cast(d AS varchar2(1000)) d, o FROM head h
UNION ALL
SELECT cast(a AS varchar2(1000)) a, cast(b AS varchar2(1000)) b, cast(c AS varchar2(1000)) c, cast(d AS varchar2(1000)) d, o FROM hwd
UNION ALL
SELECT cast(a AS varchar2(1000)) a, cast(b AS varchar2(1000)) b, cast(c AS varchar2(1000)) c, cast(d AS varchar2(1000)) d, o FROM tfb
UNION ALL
SELECT cast(a AS varchar2(1000)) a, cast(b AS varchar2(1000)) b, cast(c AS varchar2(1000)) c, cast(d AS varchar2(1000)) d, o FROM dls
UNION ALL
SELECT cast(a AS varchar2(1000)) a, cast(b AS varchar2(1000)) b, cast(c AS varchar2(1000)) c, cast(d AS varchar2(1000)) d, o FROM blpl
UNION ALL
SELECT cast(a AS varchar2(1000)) a, cast(b AS varchar2(1000)) b, cast(c AS varchar2(1000)) c, cast(d AS varchar2(1000)) d, o FROM addlextens
UNION ALL
SELECT cast(a AS varchar2(1000)) a, cast(b AS varchar2(1000)) b, cast(c AS varchar2(1000)) c, cast(d AS varchar2(1000)) d, o FROM addltfnumbers
UNION ALL
SELECT cast(a AS varchar2(1000)) a, cast(b AS varchar2(1000)) b, cast(c AS varchar2(1000)) c, cast(d AS varchar2(1000)) d, o FROM addllocnumbers
UNION ALL
SELECT cast(a AS varchar2(1000)) a, cast(b AS varchar2(1000)) b, cast(c AS varchar2(1000)) c, cast(d AS varchar2(1000)) d, o FROM true800
UNION ALL
SELECT cast(a AS varchar2(1000)) a, cast(b AS varchar2(1000)) b, cast(c AS varchar2(1000)) c, cast(d AS varchar2(1000)) d, o FROM vanity
UNION ALL
SELECT cast(a AS varchar2(1000)) a, cast(b AS varchar2(1000)) b, cast(c AS varchar2(1000)) c, cast(d AS varchar2(1000)) d, o FROM shipoptions
)
select fn.a, fn.b, fn.c, fn.d
FROM fn
ORDER BY fn.o, fn.a, fn.c, fn.b