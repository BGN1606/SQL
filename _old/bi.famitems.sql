USE [HBCAMS_IntegrationDB]
GO

/****** Object:  View [bi].[famitems]    Script Date: 21.09.2020 11:30:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [bi].[famitems]
AS

SELECT
	 [cdc_FAM]											AS [fam_id]
	,[cdc_FAMName]										AS [fam_name]
	,[cdc_FAMItemsId]									AS [famitems_id]
	,[cdc_EAN]											AS [product_id]
	,[cdc_EANName]										AS [ean]
	,[CreatedOn]										AS [created_on]
	,[ModifiedOn]										AS [modified_on]
	,[cdc_TargtDate]									AS [target_date]
	,[cdc_DetargtDate]									AS [detarget_date]
	,[cdc_ListedDate]									AS [listed_date]
	,[cdc_DelistedDate]									AS [delisted_date]
	,[cdc_inOut]										AS [is_inout]
	,[cdc_tt_count]										AS [tt_count]
	,[cdc_default_con]									AS [default_con]
	--,[cdc_is_skuclientconfirmed]
	--,[cdc_is_mm_approved]
	--,[cdc_is_prelaunch]
	--,[cdc_is_dont_add_to_promo_assortment]
	--,[cdc_is_add_to_promo_assortment]
	--,[cdc_lst_benchmark_type]							AS [lst_benchmark_type]
	,[cdc_novelty_blprecalc_date]						AS [blprecalc_date]
	,[cdc_novelty_blprecalc_ttcount]					AS [blprecalc_ttcount]
	,[cdc_novelty_blprecalc_con_type1]					AS [blprecalc_con_type1]
	,[cdc_novelty_blprecalc_con_type2]					AS [blprecalc_con_type2]
	,[cdc_novelty_blprecalc_con_type3]					AS [blprecalc_con_type3]
FROM [HBCAMS_MSCRM].[dbo].[cdc_FAMItems]

WHERE [statecode] = 0
GO


