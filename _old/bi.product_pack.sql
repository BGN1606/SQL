USE HBCAMS_IntegrationDB
GO

CREATE VIEW [bi].[product_pack]
AS
SELECT
	 [OrganizationId]			AS [organization_id]
	,[cdc_accountid]			AS [account_id]
	,[cdc_productid]			AS [product_id]
	,[cdc_productidName]		AS [product_ean]
	,[cdc_product_packId]		AS [product_pack_id]
	,[cdc_name]					AS [product_pack_ean]
	,[CreatedOn]				AS [created_on]
	,[ModifiedOn]				AS [modified_on]
	,[cdc_items_in_pack_count]	AS [items_in_pack_count]
	
FROM [HBCAMS_MSCRM].[dbo].[cdc_product_pack]

WHERE [statecode] = 0