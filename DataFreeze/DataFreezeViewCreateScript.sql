USE [HBCAMS_IntegrationDB]
GO

ALTER VIEW [dbo].[DataFreezeView]
AS

SELECT
    NULL                                                                    AS [datafreeze_type]
  , [acc].[bussiness_name]                                                  AS [business_name]
  , [acc].[division_id]
  , [acc].[division_name]
  , [acc].[distributor_id]
  , [acc].[distributor_name]
  , [acc].[account_id]
  , [acc].[account_name]
  , [acc].[approve_cluster_name]
  , [acc].[channel]
  , [acc].[delivery_lag]
  , [acc].[sales_channel]
  , [acc].[nrm]
  , [acc].[rating]
  , [acc].[hq]
  , [acc].[is_covered_by_nielsen]
  , [acc].[apopartner_code]
  , [acc].[apopartner_name]

  , [promo].[promo_id]
  , [promo].[promo_key]
  , [promo].[promo_name]
  , [promo].[promo_short_name]
  , [promo].[order_from]
  , [promo].[order_to]
  , [promo].[delivery_from]
  , [promo].[delivery_to]
  , [promo].[onshelf_from]
  , [promo].[onshelf_to]
  , [promo].[mechanics]
  , [promo].[mechanics_individual]
  , [promo].[mechanics_1]
  , [promo].[mechanics_2]
  , [promo].[type]
  , [promo].[is_scenario_included_working]
  , [promo].[henkel_promo_status]
  , [promo].[class]
  , [promo].[pc_guideline]
  , [promo].[ppd_guideline]
  , [promo].[roi_guideline]
  
  , [prod].[line_name]
  , [prod].[category_name]
  , [prod].[brand_name]
  , [prod].[product_id]
  , [prod].[product_name]
  , [prod].[ean]
  , [prod].[lst_status]
  , [prod].[volume]
  
  , [mut].[shipment_date]
  , [mut].[delivery_date]
  , [mut].[status]
  , [mut].[scenario]
  , [mut].[activity_type]
  , [mut].[data_type]
  , [mut].[data_type_lvl0]
  , [mut].[data_type_lvl1]
  , [mut].[data_type_lvl2]
  , SUM([mut].[con])                                                        AS [con]
  , SUM([mut].[cpv])                                                        AS [cpv]
  , SUM([mut].[rp])                                                         AS [rp]
  , SUM([mut].[ges])                                                        AS [ges]
  , SUM([mut].[nes])                                                        AS [nes]
  , SUM([mut].[pld])                                                        AS [pld]
  , SUM([mut].[pxd])                                                        AS [pxd]
  , SUM([mut].[ppd])                                                        AS [ppd]
  , SUM([mut].[ppd_distr])                                                  AS [ppd_distr]
  , SUM([mut].[oncch])                                                      AS [oncch]
  , SUM([mut].[oncdb])                                                      AS [oncdb]
  , SUM([mut].[offcch])                                                     AS [offcch]
  , SUM([mut].[offcdb])                                                     AS [offcdb]
  , SUM([mut].[offextra])                                                   AS [offextra]
  , SUM([mut].[offextra_abs])                                               AS [offextra_abs]
  , SUM([mut].[comm])                                                       AS [comm]
  , SUM([mut].[trwh])                                                       AS [trwh]
  , SUM([mut].[matcost])                                                    AS [matcost]
  , SUM([mut].[l17])                                                        AS [l17]
  , SUM([mut].[gp1])                                                        AS [gp1]
  , SUM([mut].[gp2])                                                        AS [gp2]
  , SUM([mut].[offc_promo_abs])                                             AS [offc_promo_abs]
  , SUM([mut].[offc_promo_perc])                                            AS [offc_promo_perc]
  , SUM([mut].[bs_con_fc])                                                  AS [bs_con_fc]
  
  , [pitems].[shelf_disc]
  
  , [price].[pld]                                                           AS [price_pld]
  , [price].[ges]                                                           AS [price_ges]
  
  , SUM(iif([tradecond].[subtype_name] = 'ON', [tradecond].[percent], 0))   AS [trdcond_On_cdb]
  , SUM(iif([tradecond].[subtype_name] <> 'ON', [tradecond].[percent], 0))  AS [trdcond_Off_cdb]

FROM [hbcams_integrationdb].[bi].[account] AS [acc] WITH (NOLOCK)

JOIN [hbcams_integrationdb].[bi].[forecastmut] AS [mut] WITH (NOLOCK)
  ON [acc].[account_id] = [mut].[account_id]

JOIN [hbcams_integrationdb].[bi].[product] AS [prod] WITH (NOLOCK)
  ON [mut].[product_id] = [prod].[product_id]

LEFT JOIN [hbcams_integrationdb].[bi].[promo] AS [promo] WITH (NOLOCK)
  ON [mut].[promo_id] = [promo].[promo_id]

LEFT JOIN [hbcams_integrationdb].[bi].[promoitems] AS [pitems] WITH (NOLOCK)
  ON [promo].[promo_id] = [pitems].[promo_id]
 AND [prod].[product_id] = [pitems].[product_id]

LEFT JOIN [hbcams_integrationdb].[bi].[priceperdate] AS [price] WITH (NOLOCK)
  ON [acc].[country_id] = [price].[country_id]
 AND [prod].[product_id] = [price].[product_id]
 AND [mut].[delivery_date] = [price].[date]

LEFT JOIN [hbcams_integrationdb].[bi].[tradecondition_plan] AS [tradecond] WITH (NOLOCK)
  ON [acc].[account_id] = [tradecond].[account_id]
 AND ([tradecond].[subtype_name] = 'ON' OR 
     ([tradecond].[type_name] NOT IN ('CA', 'BMC') AND [tradecond].[subtype_name] = 'OFF'))
 AND [tradecond].[date_from] = (
                                SELECT MAX([date_from])
                                FROM [hbcams_integrationdb].[bi].[tradecondition_plan]
                                WHERE [date_from] <= [mut].[delivery_date]
                                 AND [account_id] = [acc].[account_id]
                                )
 
GROUP BY
    [acc].[bussiness_name]
  , [acc].[division_id]
  , [acc].[division_name]
  , [acc].[distributor_id]
  , [acc].[distributor_name]
  , [acc].[account_id]
  , [acc].[account_name]
  , [acc].[approve_cluster_name]
  , [acc].[channel]
  , [acc].[delivery_lag]
  , [acc].[sales_channel]
  , [acc].[nrm]
  , [acc].[rating]
  , [acc].[hq]
  , [acc].[is_covered_by_nielsen]
  , [acc].[apopartner_code]
  , [acc].[apopartner_name]

  , [promo].[promo_id]
  , [promo].[promo_key]
  , [promo].[promo_name]
  , [promo].[promo_short_name]
  , [promo].[order_from]
  , [promo].[order_to]
  , [promo].[delivery_from]
  , [promo].[delivery_to]
  , [promo].[onshelf_from]
  , [promo].[onshelf_to]
  , [promo].[mechanics]
  , [promo].[mechanics_individual]
  , [promo].[mechanics_1]
  , [promo].[mechanics_2]
  , [promo].[type]
  , [promo].[is_scenario_included_working]
  , [promo].[henkel_promo_status]
  , [promo].[class]
  , [promo].[pc_guideline]
  , [promo].[ppd_guideline]
  , [promo].[roi_guideline]
  
  , [prod].[line_name]
  , [prod].[category_name]
  , [prod].[brand_name]
  , [prod].[product_id]
  , [prod].[product_name]
  , [prod].[ean]
  , [prod].[lst_status]
  , [prod].[volume]
  
  , [mut].[shipment_date]
  , [mut].[delivery_date]
  , [mut].[status]
  , [mut].[scenario]
  , [mut].[activity_type]
  , [mut].[data_type]
  , [mut].[data_type_lvl0]
  , [mut].[data_type_lvl1]
  , [mut].[data_type_lvl2]

  , [pitems].[shelf_disc]

  , [price].[pld]
  , [price].[ges]
