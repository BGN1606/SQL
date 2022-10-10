SELECT
  YEAR(mut.[delivery_date])																								AS [year],
  MONTH(mut.[delivery_date])																							AS [month],
  acc.[division_name]																									AS [region],
  mut.[data_type_lvl2]																									AS [line_type],
  acc.[distributor_name]																								AS [distributor],
  acc.[account_name]																									AS [client],
  acc.[channel]																											AS [channel],
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[promo_name] ELSE NULL END							AS [promoname],
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[henkel_promo_status] ELSE NULL END					AS [status],
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN  promo.[mechanics] ELSE NULL END							AS [mechanics],
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[mechanics_1] ELSE NULL END							AS [mechanics_1],
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[mechanics_2] ELSE NULL END							AS [mechanics_2],
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[delivery_from] ELSE NULL END						AS [deliveryfrom],
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[delivery_to] ELSE NULL END							AS [deliveryto],
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[onshelf_from] ELSE NULL END						AS [onshelfform],
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[onshelf_to] ELSE NULL END							AS [onshelfto],
  CASE
	WHEN promo.[is_client_confirmed] = 1 THEN 'Confirmed'
	WHEN [lst_approval_probability_id] = 754460003 THEN [lst_approval_probability]
	ELSE 'Unconfirmed' END																								AS [ststus2],
  prod.[category_name]																									AS [catigory],
  prod.[brand_name]																										AS [brandname],

  AVG(promoitems.[shelf_disc])																							AS [shelf_disc],
  SUM(mut.[Con])																										AS [con],
  SUM(mut.[GES])																										AS [ges],
  SUM(mut.[PLD])																										AS [pld],
  SUM(mut.[PPD])																										AS [ppd],
  SUM(mut.[oncch])																										AS [oncch],
  SUM(mut.[oncdb])																										AS [oncdb],
  SUM(mut.[CPV])																										AS [cpv],
  SUM(mut.[RP])																											AS [rp],
  SUM(mut.[OFFcch])																										AS [offcch],
  SUM(mut.[OFFc_promo_abs])																								AS [offc_promo_abs],
  SUM(mut.[offc_promo_perc])																							AS [offc_promo_perc],
  SUM(mut.[OFFcdb])																										AS [offcdb],
  SUM(mut.[OFFextra] + mut.[offextra_abs])																				AS [offextra],
  SUM(mut.[NES])																										AS [nes],
  SUM(mut.[Comm])																										AS [comm],
  SUM(mut.[MatCost])																									AS [matcost],
  SUM(mut.[TrWh])																										AS [trwh],
  SUM(mut.[GP1])																										AS [gp1],
  SUM(mut.[L17])																										AS [l17],
  SUM(mut.[GP2])																										AS [gp2],
  AVG(promoitems.[roi_mkz])																								AS [roi]

FROM [HBCAMS_IntegrationDB].[bi].[ForecastMut] mut

JOIN [HBCAMS_IntegrationDB].[bi].[Account] acc
  ON mut.[account_id] = acc.[account_id]

LEFT JOIN [HBCAMS_IntegrationDB].[bi].[Product] prod
  ON mut.[product_id] = prod.[product_id]

LEFT JOIN [HBCAMS_IntegrationDB].[bi].[Promo] promo
  ON mut.[promo_id] = promo.[promo_id]
 AND promo.[henkel_promo_status_id] IN (754460001 /*Открыто*/, 754460002 /*Утверждено*/, 754460003  /*Завершено*/)

LEFT JOIN [HBCAMS_IntegrationDB].[bi].[PromoItems] promoitems
  ON promo.[promo_id] = promoitems.[promo_id]
 AND mut.[product_id] = promoitems.[product_id]

where ((mut.[delivery_date] >= (dateadd(m, datediff(m, 0, getdate()), 0)) AND mut.[data_type_lvl0] = 'Forecast')
   OR  (mut.[delivery_date] < (dateadd(m, datediff(m, 0, getdate()), 0)) AND mut.[data_type_lvl0] = 'Fact'))

/*фильтры для интерфейса*/
  AND acc.[account_name] IN (@EP)
  AND YEAR(mut.[delivery_date]) IN (@Year)
  AND MONTH(mut.[delivery_date]) IN (@Month)
  AND acc.[division_name] IN (@Region)
  AND prod.[brand_name] IN (@Brand)
  AND acc.[channel] IN (@Channel)
GROUP BY
  YEAR(mut.[delivery_date]),
  MONTH(mut.[delivery_date]),
  acc.[division_name],
  mut.[data_type_lvl2],
  acc.[distributor_name],
  acc.[account_name],
  acc.[channel],
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[promo_name] ELSE NULL END,
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[henkel_promo_status] ELSE NULL END,
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN  promo.[mechanics] ELSE NULL END,
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[mechanics_1] ELSE NULL END,
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[mechanics_2] ELSE NULL END,
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[delivery_from] ELSE NULL END,
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[delivery_to] ELSE NULL END,
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[onshelf_from] ELSE NULL END,
  CASE WHEN mut.[data_type_id] IN (754460012, 754460022) THEN promo.[onshelf_to] ELSE NULL END,
  CASE
	WHEN promo.[is_client_confirmed] = 1 THEN 'Confirmed'
	WHEN [lst_approval_probability_id] = 754460003 THEN [lst_approval_probability]
	ELSE 'Unconfirmed' END,
  prod.[category_name],
  prod.[brand_name]


--
-- -- Filters
--
-- -- EP
-- select distinct
-- case when accnt.[cdc_rating] = 754460001 then accnt.[Name] else 'Other' end Name
-- from [HBCAMS_MSCRM].[dbo].[FilteredAccount] accnt
-- order by Name
--
-- -- Region
-- SELECT division.[Value]
-- FROM [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)
--
-- WHERE division.[LangId] = 1049
--  AND division.[FilteredViewName] = 'FilteredAccount'
--  AND division.[AttributeName] = 'new_division_EP'
--
-- -- Brand
-- select distinct
-- prod.cdc_brandname
-- from Product prod
-- order by 1
--
-- -- Channel
-- SELECT DISTINCT
-- 	channel.[Value]
-- FROM [HBCAMS_MSCRM].[dbo].[FilteredStringMap] channel WITH (NOLOCK)
-- WHERE channel.[LangId] = 1049
--  AND channel.[FilteredViewName] = 'FilteredAccount'
--  AND channel.[AttributeName] = 'cdc_channel'
--
-- UNION ALL
--
-- SELECT 'Unknown'