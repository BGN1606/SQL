/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT 
	   itms.iidtext
	  ,itms.iName
      ,prts.[exid]
	  ,prts.Name
      ,prcs.[Price]
      ,prcs.[StartDate]
      ,prcs.[EndDate]
      ,prcs.[Activeflag]
  FROM [Mobile_Schwarzkopf_KZ_HO].[dbo].[DS_Party_Prices] prcs
  JOIN [Mobile_Schwarzkopf_KZ_HO].[dbo].[DS_Parts] prts on prcs.PartId = prts.PartID and prts.ActiveFlag = 1
  JOIN [Mobile_Schwarzkopf_KZ_HO].[dbo].[DS_ITEMS] itms on itms.iid = prts.IID and itms.activeFlag = 1

  WHERE prcs.Activeflag = 1
