USE HBCAMS_IntegrationDB
GO

CREATE VIEW [bi].[fam]
AS

SELECT
	 fam.[cdc_EP]				AS [account_id]
	,fam.[cdc_EPName]			AS [account_name]
	,fam.[cdc_FAMId]			AS [fam_id]
	,fam.[cdc_name]				AS [fam_name]
	,fam.[CreatedOn]			AS [created_on]
	,fam.[ModifiedOn]			AS [modified_on]
	--,[cdc_AttrvalueID]		AS []
	,fam.[cdc_channel]			AS [channel_id]
	,channel.[Value]			AS [channel_name]
	,fam.[cdc_is_msl]			AS [is_msl]
	,fam.[cdc_tt_count]			AS [tt_count]
FROM [HBCAMS_MSCRM].[dbo].[cdc_FAM] fam

LEFT JOIN [HBCAMS_MSCRM].[dbo].[FilteredStringMap] channel WITH (NOLOCK)
  ON fam.[cdc_channel] = channel.[AttributeValue]
 AND channel.[LangId] = 1049
 AND channel.[FilteredViewName] = 'Filteredcdc_FAM'
 AND channel.[AttributeName] = 'cdc_channel'

WHERE [statecode] = 0