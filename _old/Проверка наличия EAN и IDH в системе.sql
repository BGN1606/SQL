/****** Проверка на наличие EAN и IDH в системе  ******/
SELECT	EAN as SQVI_EAN
		,iidtext as DMS_EAN
		,IDH as SQVI_IDH
		,Exid as DMS_IDH
		,Name as SQVI_Name
FROM (
	SELECT DISTINCT [EAN], itms.iidText,[IDH], prts.Exid,sqvi.Name
	FROM [Mobile_Schwarzkopf_HO_Plus].[dbo].[DS_SQVI] sqvi
	left join [Mobile_Schwarzkopf_HO].[dbo].[DS_ITEMS] itms on sqvi.EAN = itms.iidText
	left join [Mobile_Schwarzkopf_HO].[dbo].[DS_Parts] prts on sqvi.IDH = prts.Exid
	WHERE GRM in (912,913,914,915) and EAN <> ''
     ) as sqvi
WHERE iidText is null or exid is null 
