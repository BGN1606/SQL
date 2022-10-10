USE [HBCAMS_IntegrationDB]
GO

DECLARE
	 @startdate	DATE = '20190101'
	,@cutdate	DATE = '20200101'
	,@enddate	DATE = '20211231'

----'Создание временной таблицы'
IF OBJECT_ID('tempdb..#data') IS NOT NULL DROP TABLE #data
CREATE TABLE #data (
	 [account_id]			VARCHAR(50)		NOT NULL
	,[promo_id]				VARCHAR(50)		NOT NULL
	,[product_id]			VARCHAR(50)		NOT NULL
	,[year]					INT				NOT NULL
	,[month]				INT				NOT NULL
	,[status]				VARCHAR(50)		NOT NULL
	,[scenario]				VARCHAR(50)		NOT NULL
	,[activity_type]		VARCHAR(50)		NOT NULL
	,[data_type]			VARCHAR(50)		NOT NULL
	,[con]					DECIMAL(19,9)	NOT NULL
	,[ges]					DECIMAL(19,9)	NOT NULL
	,[pld]					DECIMAL(19,9)	NOT NULL
	,[ppd]					DECIMAL(19,9)	NOT NULL
	,[ONcch]				DECIMAL(19,9)	NOT NULL
	,[ONcdb]				DECIMAL(19,9)	NOT NULL
	,[cpv]					DECIMAL(19,9)	NOT NULL
	,[rp]					DECIMAL(19,9)	NOT NULL
	,[OFFcch]				DECIMAL(19,9)	NOT NULL
	,[offc_promo_abs]		DECIMAL(19,9)	NOT NULL
	,[offc_promo_perc]		DECIMAL(19,9)	NOT NULL
	,[OFFcdb]				DECIMAL(19,9)	NOT NULL
	,[OFFextra]				DECIMAL(19,9)	NOT NULL
	,[nes]					DECIMAL(19,9)	NOT NULL
	,[comm]					DECIMAL(19,9)	NOT NULL
	,[matcost]				DECIMAL(19,9)	NOT NULL
	,[trwh]					DECIMAL(19,9)	NOT NULL
	,[gp1]					DECIMAL(19,9)	NOT NULL
	,[l17]					DECIMAL(19,9)	NOT NULL
	,[gp2]					DECIMAL(19,9)	NOT NULL
)

----'Сбор данных для отчета'
INSERT INTO #data
SELECT
	 forecast.[account_id]
	,forecast.[promo_id]
	,forecast.[product_id]
	,YEAR(forecast.[delivery_date])
	,MONTH(forecast.[delivery_date])
	,forecast.[status]
	,forecast.[scenario]
	,forecast.[activity_type]
	,forecast.[data_type_lvl2]
	,SUM(forecast.[CON])
	,SUM(forecast.[GES])
	,SUM(forecast.[PLD])
	,SUM(forecast.[PPD])
	,SUM(forecast.[ONcch])
	,SUM(forecast.[ONcdb])
	,SUM(forecast.[CPV])
	,SUM(forecast.[RP])
	,SUM(forecast.[OFFcch])
	,SUM(forecast.[offc_promo_abs])
	,SUM(forecast.[offc_promo_perc])
	,SUM(forecast.[OFFcdb])
	,SUM(forecast.[OFFextra])
	,SUM(forecast.[NES])
	,SUM(forecast.[comm])
	,SUM(forecast.[MatCost])
	,SUM(forecast.[trwh])
	,SUM(forecast.[gp1])
	,SUM(forecast.[l17])
	,SUM(forecast.[gp2])

FROM [HBCAMS_IntegrationDB].[bi].[ForecastMut] forecast WITH (NOLOCK)

WHERE forecast.[promo_id] IS NOT NULL AND
	((forecast.[delivery_date] BETWEEN @startdate and @cutdate AND forecast.[data_type_lvl0] = 'Fact') OR
	 (forecast.[delivery_date] BETWEEN @cutdate and @enddate AND forecast.[data_type_lvl0] = 'Baseline'))

GROUP BY
	 forecast.[account_id]
	,forecast.[promo_id]
	,forecast.[product_id]
	,YEAR(forecast.[delivery_date])
	,MONTH(forecast.[delivery_date])
	,forecast.[status]
	,forecast.[scenario]
	,forecast.[activity_type]
	,forecast.[data_type_lvl2]

----'Построение отчета'
SELECT
	 acc.[sales_channel]
	,acc.[division_name]
	,acc.[distributor_name]
	,acc.[account_name]
	,acc.[sales_channel]
	,acc.[nrm]
	,acc.[rating]
	,acc.[channel]
	,acc.[hq]
	,acc.[is_covered_by_nielsen]
	,forecast.[year]
	,forecast.[month]
	,product.[category_name]
	,product.[brand_name]
	,product.[line_name]
	,product.[lst_status]
	,promo.[promo_name]
	,forecast.[status]
	,forecast.[scenario]
	,forecast.[activity_type]
	,forecast.[data_type]
	,SUM(forecast.[CON])				AS [con]
	,SUM(forecast.[GES])				AS [ges]
	,SUM(forecast.[PLD])				AS [pld]
	,SUM(forecast.[PPD])				AS [ppd]
	,SUM(forecast.[ONcch])				AS [ONcch]
	,SUM(forecast.[ONcdb])				AS [ONcdb]
	,SUM(forecast.[CPV])				AS [cpv]
	,SUM(forecast.[RP])					AS [rp]
	,SUM(forecast.[OFFcch])				AS [OFFcch]
	,SUM(forecast.[offc_promo_abs])		AS [offc_promo_abs]
	,SUM(forecast.[offc_promo_perc])	AS [offc_promo_perc]
	,SUM(forecast.[OFFcdb])				AS [OFFcdb]
	,SUM(forecast.[OFFextra])			AS [OFFextra]
	,SUM(forecast.[NES])				AS [nes]
	,SUM(forecast.[comm])				AS [comm]
	,SUM(forecast.[MatCost])			AS [matcost]
	,SUM(forecast.[trwh])				AS [trwh]
	,SUM(forecast.[gp1])				AS [gp1]
	,SUM(forecast.[l17])				AS [l17]
	,SUM(forecast.[gp2])				AS [gp2]

FROM #data forecast WITH (NOLOCK)

JOIN [HBCAMS_IntegrationDB].[bi].[Account] acc WITH (NOLOCK)
  ON acc.[account_id] = forecast.[account_id]

JOIN [HBCAMS_IntegrationDB].[bi].[Promo] promo WITH (NOLOCK)
  ON forecast.[promo_id] = promo.[promo_id]
 AND promo.[henkel_promo_status] in ('Открыто', 'Утверждено', 'Завершено')

JOIN [HBCAMS_IntegrationDB].[bi].[Product] product WITH (NOLOCK)
  ON forecast.[product_id] = product.[product_id]

GROUP BY
	 acc.[sales_channel]
	,acc.[division_name]
	,acc.[distributor_name]
	,acc.[account_name]
	,acc.[sales_channel]
	,acc.[nrm]
	,acc.[rating]
	,acc.[channel]
	,acc.[hq]
	,acc.[is_covered_by_nielsen]
	,forecast.[year]
	,forecast.[month]
	,product.[category_name]
	,product.[brand_name]
	,product.[line_name]
	,product.[lst_status]
	,promo.[promo_name]
	,forecast.[status]
	,forecast.[scenario]
	,forecast.[activity_type]
	,forecast.[data_type]

OPTION (RECOMPILE)