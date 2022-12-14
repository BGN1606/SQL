/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT distinct top 300000
-- [DictId]
--,[Id]
--,AttrValueId
--FROM [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes]
--where DictId in (1) and Activeflag =1 and AttrId=627


TRUNCATE TABLE [Mobile_Schwarzkopf_HO_Plus].[dbo].[DMT_Set_ObjectsAttributes_History_Batch]
INSERT INTO [Mobile_Schwarzkopf_HO_Plus].[dbo].[DMT_Set_ObjectsAttributes_History_Batch]

SELECT DISTINCT 
--TOP 80000
  1              ownerdistid,
  null           ownerdistexid,
  [DictId]       dictid,
  Id             id,
  null           exid,
  627            attrid,
  null           attrexid,
  null    attrvalueid,
  null           attrvalueexid,
  null           attrtext,
  null           startdate,
  '20180831'     enddate,
  1              activeflag,
  1              sort,
  null           options
FROM [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes]
WHERE DictId in (1)
  and Activeflag=1
  and AttrId=627

--1 116 523
--AttrValueId