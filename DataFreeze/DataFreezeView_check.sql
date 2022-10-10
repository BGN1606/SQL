-- Клиент
SELECT [name], [AccountId]
FROM [HBCAMS_MSCRM].[dbo].[Account] AS [A]
WHERE [Name] LIKE '24 chasa_VladivostokVIP';

-- Типы строк
SELECT [AttributeName], [AttributeValue], [Value]
FROM [HBCAMS_MSCRM].[dbo].[FilteredStringMap]
WHERE [LangId] = 1049 AND [FilteredViewName] = 'Filteredcdc_ForcastMut' AND [AttributeName] = 'cdc_type';


-- Факты по клиенту из AMS
SELECT [f].[cdc_epname], SUM([f].[cdc_CON]) AS [con], SUM([f].[cdc_NES]) AS [nes]
FROM [HBCAMS_MSCRM].[dbo].[cdc_ForcastMut] AS [F]
WHERE [f].[cdc_EP] = '35E02D54-5FB3-E711-80E5-0050560186BB'
  AND ISNULL([f].[cdc_datum_document], [f].[cdc_Datum]) BETWEEN '20200101' AND '20200131'
  AND [f].[cdc_Type] IN (754460020, 754460022, 754460024)
GROUP BY [f].[cdc_epname]


-- Факты из BI - realtime
SELECT [f].[account_name], SUM([f].[con]) AS [con], SUM([f].[nes]) AS [nes]
FROM [HBCAMS_IntegrationDB].[bi].[ForecastMut] AS [F]
WHERE [f].[account_id] = '35E02D54-5FB3-E711-80E5-0050560186BB'
  AND [delivery_date] BETWEEN '20200101' AND '20200131'
  AND [f].[data_type_lvl0] = 'Fact'
GROUP BY [f].[account_name]


-- Факты из Срезов - realtime
SELECT [f].[account_name], SUM([f].[con]) AS [con], SUM([f].[nes]) AS [nes]
FROM [HBCAMS_IntegrationDB].[dbo].[datafreezeview] AS [F]
WHERE [f].[account_id] = '35E02D54-5FB3-E711-80E5-0050560186BB'
  AND [delivery_date] BETWEEN '20200101' AND '20200131'
  AND [f].[data_type_lvl0] = 'Fact'
GROUP BY [f].[account_name];

-- DataFreezeView
WITH
    [df] AS (
        SELECT NULL                               AS [datafreeze_type]
             , [acc].[bussiness_name]             AS [business_name]
             , [acc].[division_id]
             , [acc].[division_name]
             , [acc].[distributor_id]
             , [acc].[distributor_name]
             , [acc].[account_id]
             , [acc].[account_name]
             , [acc].[approve_cluster_name]
             , [acc].[channel]                    AS [account_channel]
             , [acc].[delivery_lag]
             , [acc].[sales_channel]
             , [acc].[nrm]
             , [acc].[rating]
             , [acc].[hq]
             , [acc].[is_it_have_parent]
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
             , [promo].[type]                     AS [promo_type]
             , [promo].[is_scenario_included_working]
             , [promo].[henkel_promo_status]
             , [promo].[class]                    AS [promo_class]
             , [promo].[pc_guideline]
             , [promo].[ppd_guideline]
             , [promo].[roi_guideline]
             , [prod].[line_name]
             , [prod].[category_name]
             , [prod].[brand_id]
             , [prod].[brand_name]
             , [prod].[product_id]
             , [prod].[product_name]
             , [prod].[ean]
             , [prod].[lst_status]
             , [prod].[national_listing_date]
             , [prod].[national_delisting_date]
             , [prod].[volume]                    AS [product_volume]
             , [mut].[shipment_date]
             , [mut].[delivery_date]
             , [mut].[status]                     AS [forecast_status]
             , [mut].[scenario]
             , [mut].[activity_type]
             , [mut].[data_type]
             , [mut].[data_type_lvl0]
             , [mut].[data_type_lvl1]
             , [mut].[data_type_lvl2]
             , SUM([mut].[con])                   AS [con]
             , SUM([mut].[cpv])                   AS [cpv]
             , SUM([mut].[rp])                    AS [rp]
             , SUM([mut].[ges])                   AS [ges]
             , SUM([mut].[nes])                   AS [nes]
             , SUM([mut].[pld])                   AS [pld]
             , SUM([mut].[pxd])                   AS [pxd]
             , SUM([mut].[ppd])                   AS [ppd]
             , SUM([mut].[ppd_distr])             AS [ppd_distr]
             , SUM([mut].[oncch])                 AS [oncch]
             , SUM([mut].[oncdb])                 AS [oncdb]
             , SUM([mut].[offcch])                AS [offcch]
             , SUM([mut].[offcdb])                AS [offcdb]
             , SUM([mut].[offextra])              AS [offextra]
             , SUM([mut].[offextra_abs])          AS [offextra_abs]
             , SUM([mut].[comm])                  AS [comm]
             , SUM([mut].[trwh])                  AS [trwh]
             , SUM([mut].[matcost])               AS [matcost]
             , SUM([mut].[l17])                   AS [l17]
             , SUM([mut].[gp1])                   AS [gp1]
             , SUM([mut].[gp2])                   AS [gp2]
             , SUM([mut].[offc_promo_abs])        AS [offc_promo_abs]
             , SUM([mut].[offc_promo_perc])       AS [offc_promo_perc]
             , SUM([mut].[bs_con_fc])             AS [bs_con_fc]
             , [pitems].[shelf_disc]
             , [price].[pld]                      AS [price_pld]
             , [price].[ges]                      AS [price_ges]
             , ISNULL([trdcond_on].[percent], 0)  AS [trdcond_on_cdb]
             , ISNULL([trdcond_off].[percent], 0) AS [trdcond_off_cdb]

        FROM [hbcams_integrationdb].[bi].[account]             AS [acc] WITH (NOLOCK)
        JOIN        [hbcams_integrationdb].[bi].[forecastmut]  AS [mut] WITH (NOLOCK)
                    ON [acc].[account_id] = [mut].[account_id]

        JOIN        [hbcams_integrationdb].[bi].[product]      AS [prod] WITH (NOLOCK)
                    ON [mut].[product_id] = [prod].[product_id]

        LEFT JOIN   [hbcams_integrationdb].[bi].[promo]        AS [promo] WITH (NOLOCK)
                    ON [mut].[promo_id] = [promo].[promo_id]

        LEFT JOIN   [hbcams_integrationdb].[bi].[promoitems]   AS [pitems] WITH (NOLOCK)
                    ON [promo].[promo_id] = [pitems].[promo_id]
                        AND [prod].[product_id] = [pitems].[product_id]

        LEFT JOIN   [hbcams_integrationdb].[bi].[priceperdate] AS [price] WITH (NOLOCK)
                    ON [acc].[country_id] = [price].[country_id]
                        AND [prod].[product_id] = [price].[product_id]
                        AND [mut].[delivery_date] = [price].[date]

        LEFT JOIN   [hbcams_integrationdb].[bi].[distributor]     [d] WITH (NOLOCK)
                    ON [d].[distributor_id] = [acc].[distributor_id]

        OUTER APPLY (
                        SELECT SUM([percent]) AS [PERCENT]
                        FROM (
                            SELECT [tp].[account_id]
                                 , [tp].[type_name]
                                 , [tp].[subtype_name]
                                 , [tp].[date_from]
                                 , [tp].[percent]
                                 , ROW_NUMBER()
                                    OVER (PARTITION BY [tp].[account_id], [tp].[subtype_name], [tp].[type_name] ORDER BY [tp].[date_from] DESC) AS [row_num]
                            FROM [hbcams_integrationdb].[bi].[tradecondition_plan] [tp]
                            WHERE [subtype_name] = 'ON'
                              AND [account_id] = [d].[distributor_id]
                              AND [date_from] <= [mut].[delivery_date]
                             ) [td]
                        WHERE [td].[row_num] = 1
                    )                                             [trdcond_on]

        OUTER APPLY (
                        SELECT [subtype_name], SUM([percent]) AS [PERCENT]
                        FROM (
                            SELECT [tp].[account_id]
                                 , [tp].[type_name]
                                 , [tp].[subtype_name]
                                 , [tp].[date_from]
                                 , [tp].[percent]
                                 , ROW_NUMBER()
                                    OVER (PARTITION BY [tp].[account_id], [tp].[subtype_name], [tp].[type_name] ORDER BY [tp].[date_from] DESC) AS [row_num]
                            FROM [hbcams_integrationdb].[bi].[tradecondition_plan] [tp]
                            WHERE [type_name] NOT IN ('CA', 'BMC')
                              AND [subtype_name] = 'OFF'
                              AND [account_id] = [d].[distributor_id]
                              AND [date_from] <= [mut].[delivery_date]
                             ) [td]
                        WHERE [td].[row_num] = 1
                        GROUP BY [subtype_name]
                    )                                             [trdcond_off]

        GROUP BY [acc].[bussiness_name]
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
               , [acc].[is_it_have_parent]
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
               , [prod].[brand_id]
               , [prod].[brand_name]
               , [prod].[product_id]
               , [prod].[product_name]
               , [prod].[ean]
               , [prod].[lst_status]
               , [prod].[national_listing_date]
               , [prod].[national_delisting_date]
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
               , [trdcond_on].[percent]
               , [trdcond_off].[percent]
    )
SELECT [f].[distributor_id]
     , [account_name]
     , SUM([f].[con]) AS [con]
     , SUM([f].[nes]) AS [nes]
     , [f].[trdcond_on_cdb]
     , [f].[trdcond_off_cdb]
FROM [df] AS [F]
WHERE [f].[account_id] = '35E02D54-5FB3-E711-80E5-0050560186BB'
  AND [delivery_date] BETWEEN '20200101' AND '20200131'
  AND [f].[data_type_lvl0] = 'Fact'
GROUP BY [distributor_id], [f].[account_name], [f].[trdcond_off_cdb], [f].[trdcond_on_cdb];

-- OUTER APPLY TradeCondition
SELECT [subtype_name], SUM([percent]) AS [PERCENT]
FROM (
    SELECT [tp].[account_id]
         , [tp].[type_name]
         , [tp].[subtype_name]
         , [tp].[date_from]
         , [tp].[percent]
         , ROW_NUMBER()
            OVER (PARTITION BY [tp].[account_id], [tp].[subtype_name], [tp].[type_name] ORDER BY [tp].[date_from] DESC) AS [row_num]
    FROM [hbcams_integrationdb].[bi].[tradecondition_plan] [tp]
    WHERE ([subtype_name] = 'ON' OR
           ([type_name] NOT IN ('CA', 'BMC') AND [subtype_name] = 'OFF'))
      AND [account_id] = '64F61B7E-4BB3-E711-80E5-0050560186BB'
      AND [date_from] <= '20200131'
     ) [td]
WHERE [td].[row_num] = 1
GROUP BY [subtype_name]

