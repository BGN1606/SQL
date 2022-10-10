USE Schwarzkopf
DECLARE @tbl nvarchar(100) = CONCAT('Schwarzkopf.dbo.DMT_Set_ObjectsAttributes_History_Batch_SPID',@@SPID)

--EXEC (
--    'DROP TABLE '+@tbl+'
--     CREATE TABLE '+@tbl+'(
--           [ownerdistid] [int] NOT NULL,
--           [ownerdistexid] [int] NULL,
--           [dictid] [int] NOT NULL,
--           [id] [int] NULL,
--           [exid] [nvarchar](100) NULL,
--           [attrid] [int] NOT NULL,
--           [attrexid] [int] NULL,
--           [attrvalueid] [int] NULL,
--           [attrvalueexid] [nvarchar](100) NULL,
--           [attrtext] [nvarchar](100) NULL,
--           [startdate] [date] NULL,
--           [enddate] [date] NULL,
--           [activeflag] [int] NOT NULL
--                            ) ON [PRIMARY]'
--      )


--if object_id ('Schwarzkopf.dbo.DMT_Set_ObjectsAttributes_History_Batch', 'U') is not null
--truncate table Schwarzkopf.dbo.DMT_Set_ObjectsAttributes_History_Batch
--insert into Schwarzkopf.dbo.DMT_Set_ObjectsAttributes_History_Batch

INSERT INTO @tbl

SELECT DISTINCT
   1       ownerdistid,
   null    ownerdistexid,
   2       dictid,
   f.fid   id,
   null    exid,
   611     attrid,
   null    attrexid,
   611002  attrvalueid,
   null    attrvalueexid,
   null    attrtext,
   cast(dateadd(day,1-day(getdate()),getdate())as date) startdate,
   null    enddate,
   1       activeflag
FROM [ftphbcho.cdc.ru].[Mobile_Schwarzkopf_HO].[dbo].[DS_FACES] f
LEFT JOIN [ftphbcho.cdc.ru].[Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes] oa
  ON f.fID=oa.Id
 AND f.OwnerDistID=oa.OwnerDistID
 AND oa.AttrId=611
 AND oa.DictId=2
 AND oa.Activeflag=1
WHERE f.fType=7
  AND oa.AttrValueId is null












--64|null|128::::|627|null|53826|null|null|0|1|1
--64|null|2053::::|2053|null|63845|null|null|1|1|1
--64|null|611::::|611|null|6110002|null|null|1|1|1
--64|null|624::::|627|null|53826|null|null|0|1|1
--64|1|624::6240001::;627::::;128::1280001::|627|null|59086|null|null|1|1|1
--64|1|624::6240001::;627::::;128::1280002::|627|null|59087|null|null|1|1|1
--64|1|624::6240001::;627::::;128::1280003::|627|null|59088|null|null|1|1|1
--64|1|624::6240001::;627::::;128::1280004::|627|null|59089|null|null|1|1|1
--64|1|624::6240001::;627::::;128::1280005::|627|null|59090|null|null|1|1|1
--64|1|624::6240001::;627::::;128::1280006::|627|null|59091|null|null|1|1|1
--64|1|624::6240001::;627::::;128::300001::|627|null|59097|null|null|1|1|1
--64|1|624::6240001::;627::::;128::50170::|627|null|59092|null|null|1|1|1
--64|1|624::6240001::;627::::;128::50979::|627|null|59093|null|null|1|1|1
--64|1|624::6240001::;627::::;128::51158::|627|null|59094|null|null|1|1|1
--64|1|624::6240001::;627::::;128::51159::|627|null|59095|null|null|1|1|1
--64|1|624::6240001::;627::::;128::51160::|627|null|59096|null|null|1|1|1
--64|1|624::6240001::;627::::;128::51163::|627|null|59098|null|null|1|1|1
--64|1|624::6240001::;627::::;128::51164::|627|null|59099|null|null|1|1|1
--64|1|624::6240001::;627::::;128::51165::|627|null|59100|null|null|1|1|1
--64|1|624::6240001::;627::::;128::51166::|627|null|59101|null|null|1|1|1
--64|1|624::6240002::;627::::;128::1280001::|627|null|59312|null|null|1|1|1
--64|1|624::6240002::;627::::;128::1280002::|627|null|59320|null|null|1|1|1
--64|1|624::6240002::;627::::;128::1280003::|627|null|59321|null|null|1|1|1
--64|1|624::6240002::;627::::;128::1280004::|627|null|59322|null|null|1|1|1
--64|1|624::6240002::;627::::;128::1280005::|627|null|59313|null|null|1|1|1
--64|1|624::6240002::;627::::;128::1280006::|627|null|59317|null|null|1|1|1
--64|1|624::6240002::;627::::;128::300001::|627|null|59324|null|null|1|1|1
--64|1|624::6240002::;627::::;128::50170::|627|null|59318|null|null|1|1|1
--64|1|624::6240002::;627::::;128::50979::|627|null|59319|null|null|1|1|1
--64|1|624::6240002::;627::::;128::51158::|627|null|59316|null|null|1|1|1
--64|1|624::6240002::;627::::;128::51159::|627|null|59310|null|null|1|1|1
--64|1|624::6240002::;627::::;128::51160::|627|null|59311|null|null|1|1|1
--64|1|624::6240002::;627::::;128::51163::|627|null|59323|null|null|1|1|1
--64|1|624::6240002::;627::::;128::51164::|627|null|59315|null|null|1|1|1
--64|1|624::6240002::;627::::;128::51165::|627|null|59314|null|null|1|1|1
--64|1|624::6240002::;627::::;128::51166::|627|null|59309|null|null|1|1|1
--64|null|687::::|687|null|67143|null|null|1|1|1
