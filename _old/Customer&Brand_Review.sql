USE [HBCAMS_IntegrationDB]
GO

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
	,YEAR(forecast.[delivery_date])		AS [year]
	,MONTH(forecast.[delivery_date])	AS [month]
	,product.[category_name]
	,product.[brand_name]
	,product.[line_name]
	,product.[lst_status]
	,promo.[promo_name]
	,forecast.[status]
	,forecast.[scenario]
	,forecast.[activity_type]
	,forecast.[data_type_lvl2]
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

FROM [HBCAMS_IntegrationDB].[bi].[ForecastMut] forecast WITH (NOLOCK)

JOIN [HBCAMS_IntegrationDB].[bi].[Account] acc WITH (NOLOCK)
  ON acc.[account_id] = forecast.[account_id]

JOIN [HBCAMS_IntegrationDB].[bi].[Promo] promo WITH (NOLOCK)
  ON forecast.[promo_id] = promo.[promo_id]
 AND promo.[henkel_promo_status] in ('Открыто', 'Утверждено', 'Завершено')

JOIN [HBCAMS_IntegrationDB].[bi].[Product] product WITH (NOLOCK)
  ON forecast.[product_id] = product.[product_id]

WHERE forecast.[delivery_date] between '20190101' and '20211231'


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
	,YEAR(forecast.[delivery_date])
	,MONTH(forecast.[delivery_date])
	,product.[category_name]
	,product.[brand_name]
	,product.[line_name]
	,product.[lst_status]
	,promo.[promo_name]
	,forecast.[status]
	,forecast.[scenario]
	,forecast.[activity_type]
	,forecast.[data_type_lvl2]

OPTION (RECOMPILE)
