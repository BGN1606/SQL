/****** Script for SelectTopNRows command from SSMS  ******/
SELECT AttrID
      ,AttrValueID
	  ,exid
      ,AttrValueName
      ,AttrValueShortName
  FROM Mobile_Schwarzkopf_HO.dbo.DS_AttributesValues
  WHERE AttrID in (128,623,600,30,687,2053,2054,627,1658,3016,3017,3018,611) and ActiveFlag = 1
