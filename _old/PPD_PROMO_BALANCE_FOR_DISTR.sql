USE [HBCAMS_IntegrationDB]
GO


ALTER PROCEDURE [bi].[ppd_promo_balance_for_distr_proc]
AS

BEGIN

	DECLARE @sdate date = DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) -1, 0)
		   ,@edate date = DATEADD(mm, +2, EOMONTH(GETDATE()));

	DECLARE @Forecast AS TABLE (
		 [shipment_date]		DATE			NOT NULL
		,[shipment_month]		DATE			NOT NULL
		,[division]				VARCHAR(50)		NOT NULL
		,[distributor]			VARCHAR(50)		NOT NULL
		,[account_id]			VARCHAR(50)		NOT NULL
		,[account_name]			VARCHAR(150)	NOT NULL
		,[promo_id]				VARCHAR(50)		NOT NULL
		,[product_id]			VARCHAR(50)		NOT NULL
		,[ges_per_sku_abs]		DECIMAL (19,9)	NOT NULL
		,[pld_per_sku_abs]		DECIMAL (19,9)	NOT NULL
		,[con_abs]				DECIMAL (19,9)	NOT NULL
		,[ges_abs]				DECIMAL (19,9)	NOT NULL
		,[cpv_abs]				DECIMAL (19,9)	NOT NULL
		,[bmc_abs]				DECIMAL (19,9)	NOT NULL
		,[offextra_abs]			DECIMAL (19,9)	NOT NULL
	)

	INSERT INTO @Forecast
	SELECT
		 forecast.[shipment_date]
		,price.[date_firstday]
		,account.[division_name]
		,account.[distributor_name]
		,account.[account_id]
		,account.[account_name]
		,forecast.[promo_id]
		,forecast.[product_id]
		,price.[ges]
		,price.[pld]
		,SUM(forecast.[con])
		,SUM(forecast.[ges])
		,SUM(forecast.[cpv])
		,SUM(forecast.[offc_promo_abs] + forecast.[offc_promo_perc])
		,SUM(forecast.[offextra] + forecast.[offextra_abs])

	FROM [HBCAMS_IntegrationDB].[bi].[ForecastMut] forecast

	JOIN [HBCAMS_IntegrationDB].[bi].[Account] account
		ON forecast.[account_id] = account.[account_id]
		AND account.[division_name] <> 'Key Retail'

	JOIN [HBCAMS_IntegrationDB].[bi].[PricePerDate] price
		ON forecast.[shipment_date] = price.[date]
		AND forecast.[product_id] = price.[product_id]
		AND account.[country_id] = price.[country_id]

	WHERE forecast.[promo_id] IS NOT NULL
		AND forecast.[shipment_date] BETWEEN @sdate
										AND @edate
	GROUP BY
		 forecast.[shipment_date]
		,price.[date_firstday]
		,account.[division_name]
		,account.[distributor_name]
		,account.[account_id]
		,account.[account_name]
		,forecast.[promo_id]
		,forecast.[product_id]
		,price.[ges]
		,price.[pld]
	;

	DECLARE @Promo AS TABLE (
		 [account_id]				VARCHAR(50)		NOT NULL
		,[promo_id]					VARCHAR(50)		NOT NULL
		,[promo_name]				VARCHAR(150)	NOT NULL
		,[modified_date]			DATETIME			NULL
		,[shipment_from]			DATETIME			NULL
		,[shipment_to]				DATETIME			NULL
		,[brand]					VARCHAR(150)	NOT NULL
		,[product_id]				VARCHAR(50)		NOT NULL
		,[ean]						VARCHAR(50)		NOT NULL
		,[product]					VARCHAR(250)	NOT NULL
		,[ppd_henkel_per_sku_perc]	DECIMAL(19,9)	NOT NULL
	)

	INSERT INTO @Promo
	SELECT
		 promo.[account_id]
		,promo.[promo_id]
		,promo.[promo_name]
		,promo.[modified_date]
		,promo.[delivery_from]
		,promo.[delivery_to]
		,product.[brand_name]
		,product.[product_id]
		,product.[ean]
		,product.[product_name]
		,promoitems.[ppdpxd]

	FROM [HBCAMS_IntegrationDB].[bi].[Promo] promo

	JOIN [HBCAMS_IntegrationDB].[bi].[PromoItems] promoitems
		ON promo.[promo_id] = promoitems.[promo_id]

	JOIN [HBCAMS_IntegrationDB].[bi].[Product] product
		ON promoitems.[product_id] = product.[product_id]
	;

	TRUNCATE TABLE [bi].[ppd_promo_balance_for_distr];
	--CREATE TABLE [bi].[ppd_promo_balance_for_distr] (
	--	 [shipment_month]			DATE			NOT NULL
	--	,[division]					VARCHAR(50)		NOT NULL
	--	,[distributor]				VARCHAR(50)		NOT NULL
	--	,[chain]					VARCHAR(150)	NOT NULL
	--	,[promo_name]				VARCHAR(250)	NOT NULL
	--	,[modified_date]			DATE			NOT NULL
	--	,[shipment_from]			DATE			NOT NULL
	--	,[shipment_to]				DATE			NOT NULL
	--	,[brand]					VARCHAR(150)	NOT NULL
	--	,[ean]						VARCHAR(50)		NOT NULL
	--	,[product]					VARCHAR(250)	NOT NULL
	--	,[ges_per_sku_abs]			DECIMAL(19,9)	NOT NULL
	--	,[pld_per_sku_abs]			DECIMAL(19,9)	NOT NULL
	--	,[oncch_per_sku_perc]		DECIMAL(19,9)	NOT NULL
	--	,[ppd_henkel_per_sku_perc]	DECIMAL(19,9)	NOT NULL
	--	,[con_abs]					DECIMAL(19,9)	NOT NULL
	--	,[ges_abs]					DECIMAL(19,9)	NOT NULL
	--	,[cpv_abs]					DECIMAL(19,9)	NOT NULL
	--	,[bmc_abs]					DECIMAL(19,9)	NOT NULL
	--	,[offextra_abs]				DECIMAL(19,9)	NOT NULL
	--)

	WITH tradecond_maxdate AS (
		SELECT DISTINCT
			 forecast.shipment_date
			,forecast.[account_id]
			,(SELECT MAX(tradecond.[date_from])
			  FROM [HBCAMS_IntegrationDB].[bi].[TradeCondition_Plan] AS tradecond
			  WHERE forecast.[account_id] = tradecond.[account_id]
				AND forecast.[shipment_date] >= tradecond.[date_from]
				AND tradecond.[type_name] = 'On Contract' ) AS tradecond_maxdate

		FROM @Forecast forecast
	)

	INSERT INTO [bi].[ppd_promo_balance_for_distr]
	SELECT
		 Forecast.[shipment_month]
		,Forecast.[division]
		,Forecast.[distributor]
		,Forecast.[account_name]
	
		,Promo.[promo_name]
		,Promo.[modified_date]
		,Promo.[shipment_from]
		,Promo.[shipment_to]
		,Promo.[brand]
		,Promo.[ean]
		,Promo.[product]
		
		,Forecast.[ges_per_sku_abs]
		,forecast.[pld_per_sku_abs]
		,ISNULL(tradecond.[percent], 0)		AS [oncch_per_sku_perc]
		,Promo.[ppd_henkel_per_sku_perc]
		,SUM(forecast.[con_abs])			AS [con_abs]
		,SUM(forecast.[ges_abs])			AS [ges_abs]
		,SUM(forecast.[cpv_abs])			AS [cpv_abs]
		,SUM(forecast.[bmc_abs])			AS [bmc_abs]
		,SUM(forecast.[offextra_abs])		AS [offextra_abs]

	FROM @Forecast forecast

	JOIN @Promo promo
	  ON Promo.[account_id] = forecast.[account_id] 
	 AND Promo.[promo_id] = forecast.[promo_id]
	 AND Promo.[product_id] = forecast.[product_id]

	JOIN tradecond_maxdate
	  ON forecast.[account_id] = tradecond_maxdate.[account_id] 
	 AND forecast.[shipment_date] = tradecond_maxdate.[shipment_date]

	LEFT JOIN [HBCAMS_IntegrationDB].[bi].[TradeCondition_Plan] tradecond
	  ON tradecond_maxdate.[account_id] = tradecond.[account_id]
	 AND tradecond_maxdate.[tradecond_maxdate] = tradecond.[date_from]
	 AND tradecond.[type_name] = 'On Contract'

	GROUP BY
		 Forecast.[shipment_month]
		,Forecast.[division]
		,Forecast.[distributor]
		,Forecast.[account_name]
	
		,Promo.[promo_name]
		,Promo.[modified_date]
		,Promo.[shipment_from]
		,Promo.[shipment_to]
		,Promo.[brand]
		,Promo.[ean]
		,Promo.[product]

		,Forecast.[ges_per_sku_abs]
		,forecast.[pld_per_sku_abs]
		,ISNULL(tradecond.[percent], 0)
		,Promo.[ppd_henkel_per_sku_perc]

OPTION (RECOMPILE)
END