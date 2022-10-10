USE [HBCAMS_MSCRM]
GO

SELECT
	 division.[FilteredViewName]
	,division.[AttributeName]
	,division.[AttributeValue]
	,division.[Value]
	,division.[DisplayOrder]
	,division.[LangId]
FROM [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)

WHERE division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'


/*
LEFT JOIN [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)
  ON acc.[new_division_EP] = division.[AttributeValue]
 AND division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'
*/



/*
USE [HBCAMS_IntegrationDB]
GO

SELECT DISTINCT
	 acc.[account_id]
	,acc.[account_name]
	,acc.[division_id]
	,acc.[division_name]
FROM [HBCAMS_IntegrationDB].[bi].[Account] acc
*/




/*
SELECT DISTINCT
  [name]
FROM [HBCAMS_MSCRM].[dbo].[FilteredAccount]
WHERE [cdc_Type] = 754460000
*/


/*
SELECT DISTINCT [data_type_lvl0]    
FROM [HBCAMS_IntegrationDB].[bi].[ForecastMut]
*/