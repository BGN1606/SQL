/****** Список пользователей BAT  ******/
IF OBJECT_ID('tempdb..#tmp1') is not null DROP TABLE #tmp1
SELECT 
REPLACE(RIGHT(logUserInfo,LEN(logUserInfo)-CHARINDEX('Email',logUserInfo)-6),'" />','') as 'logmail',
MAX(logDateOccured) 'MaxDate'
INTO #tmp1
FROM [BAT_Schwarzkopf].[dbo].[tblLog]
WHERE logUserInfo <> '' 
	AND REPLACE(RIGHT(logUserInfo,LEN(logUserInfo)-CHARINDEX('Email',logUserInfo)-6),'" />','')<>''
GROUP BY 
REPLACE(RIGHT(logUserInfo,LEN(logUserInfo)-CHARINDEX('Email',logUserInfo)-6),'" />','')

SELECT 
	usrNameFirst 'Имя (BAT)',
	usrNameLast 'Фамилия(BAT)',
	Name 'ФИО (WARM)',
	fcs.ObjId 'Код сотрудника (WARM)',
	AttrValueName 'Роль (WARM)',
	usrEmail 'Почта (BAT)',
	EMail 'Почта (WARM)',
	usrStatus 'Активность (BAT)',
	fcs.ActiveFlag 'Активность (WARM)',
	l.MaxDate 'Дата посл. актив. (BAT)'
FROM BAT_Schwarzkopf.dbo.tblUsers U (nolock)
LEFT JOIN [Mobile_Schwarzkopf_HO].[dbo].[Ds_Users] fcs (nolock)
	ON u.usrEmail = fcs.Email
LEFT JOIN [Mobile_Schwarzkopf_HO].[dbo].[DS_Forest] frs (nolock)
	ON fcs.ObjId=frs.Id
	AND	frs.TreeID=64 
	AND frs.ActiveFlag=1
	AND frs.DictID=2
LEFT JOIN [Mobile_Schwarzkopf_HO].[dbo].[DS_Forest] frs1 (nolock)
	ON frs.Father = frs1.GUID
	AND frs1.ActiveFlag=1
	AND	frs1.TreeID=64
LEFT JOIN [Mobile_Schwarzkopf_HO].[dbo].[DS_AttributesValues] Atr (nolock)
	ON frs1.Id = Atr.AttrValueID
	AND atr.ActiveFlag =1
LEFT JOIN #tmp1 as l ON l.logmail = u.usrEmail
--WHERE u.usrEmail = 'albina177@mail.ru'