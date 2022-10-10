DECLARE @sdate DATE = '20200101', @edate DATE = '20201231', @cutdate DATE = '20200601'


SELECT
  YEAR(ISNULL(mut.[cdc_datum_document], mut.[cdc_datum]))							AS [year],
  MONTH(ISNULL(mut.[cdc_datum_document], mut.[cdc_datum]))							AS [month],
  [reg].[cdc_regionname]															AS [region],
  acc.[new_division_ep]																AS [division],
  acc.[new_sales_channel]															AS [sales_channel],
  CASE mut.[cdc_type] WHEN 754460012 THEN 'Promo' ELSE 'Baseline' END				AS [line_type],
  CASE
    WHEN acc.[accountid] IN (
      '1BE02D54-5FB3-E711-80E5-0050560186BB', --|Zimus_KemerovoTsimus
      '2DE02D54-5FB3-E711-80E5-0050560186BB', --|Auss_Khabarovsk
      '2FE02D54-5FB3-E711-80E5-0050560186BB', --|Desyatochka_Komsomolsk-na-Amure
      'B9C84F27-3460-E911-810A-0050560186BB'  --|Monetka_Direct
      ) THEN acc.[name]
    ELSE acc.[parentaccountidname]
  END																				AS [distributor],
  acc.[name]																		AS [client],
  prod.[cdc_caterogyname]															AS [catigory],
  prod.[cdc_brandname]																AS [brandname],
  SUM(mut.[cdc_con])																AS [con],
  SUM(mut.[cdc_ges])																AS [ges],
  SUM(mut.[cdc_pld])																AS [pld],
  SUM(mut.[cdc_ppd])																AS [ppd],
  SUM(mut.[cdc_oncch])																AS [oncch],
  SUM(mut.[cdc_oncdb])																AS [oncdb],
  SUM(mut.[cdc_cpv])																AS [cpv],
  SUM(mut.[cdc_rp])																	AS [rp],
  SUM(mut.[cdc_offcch])																AS [offcch],
  SUM(mut.[cdc_offc_promo_abs])														AS [offc_promo_abs],
  SUM(mut.[cdc_offc_promo_perc])													AS [offc_promo_perc],
  SUM(mut.[cdc_offcdb])																AS [offcdb],
  SUM(mut.[cdc_offextra])															AS [offextra],
  SUM(mut.[cdc_offextra_abs])														AS [offextra_abs],
  SUM(mut.[cdc_nes])																AS [nes],
  SUM(mut.[cdc_comm])																AS [comm],
  SUM(mut.[cdc_matcost])															AS [matcost],
  SUM(mut.[cdc_trwh])																AS [trwh],
  SUM(mut.[cdc_gp1])																AS [gp1],
  SUM(mut.[cdc_gp2])																AS [gp2],
  SUM(mut.[cdc_l17])																AS [l17],
  acc.[new_NRM]																		AS [nrm],
  acc.[cdc_rating]																	AS [top chains],
  acc.[cdc_Channel]																	AS [chanel],
  acc.[new_hq_ep]																	AS [HQ],
  acc.[new_NielsenCoverage]															AS [Nielsen Coverage]

FROM [hbcams_mscrm].[dbo].[cdc_forcastmutbase] mut

JOIN [hbcams_mscrm].[dbo].[account] acc
  ON mut.[cdc_ep] = acc.[accountid]
 AND acc.[cdc_type] = 754460000

JOIN [hbcams_mscrm].[dbo].[product] prod
  ON mut.[cdc_ean] = prod.[productid]

LEFT JOIN [hbcams_mscrm].[dbo].[cdc_regionlink] [reg]
  ON mut.[cdc_ep] = [reg].[cdc_ep]

WHERE ISNULL(mut.[cdc_datum_document], mut.[cdc_datum]) BETWEEN @cutdate AND @edate
 AND mut.[statecode] = 0
 AND mut.[cdc_type] IN (
   754460010, --|baseline
   754460011, --|baseline canibal
   754460012, --|Promo
   754460013  --|baseline promo correction
   )

GROUP BY
  YEAR(ISNULL(mut.[cdc_datum_document], mut.[cdc_datum])),
  MONTH(ISNULL(mut.[cdc_datum_document], mut.[cdc_datum])),
  [reg].[cdc_regionname],
  acc.[new_division_ep],
  acc.[new_sales_channel],
  CASE mut.[cdc_type] WHEN 754460012 THEN 'Promo' ELSE 'Baseline' END,
  CASE
    WHEN acc.[accountid] IN (
      '1BE02D54-5FB3-E711-80E5-0050560186BB', --|Zimus_KemerovoTsimus
      '2DE02D54-5FB3-E711-80E5-0050560186BB', --|Auss_Khabarovsk
      '2FE02D54-5FB3-E711-80E5-0050560186BB', --|Desyatochka_Komsomolsk-na-Amure
      'B9C84F27-3460-E911-810A-0050560186BB'  --|Monetka_Direct
      ) THEN acc.[name]
    ELSE acc.[parentaccountidname]
  END,
  acc.[name],
  prod.[cdc_caterogyname],
  prod.[cdc_brandname],
  acc.[new_NRM],
  acc.[cdc_rating],
  acc.[cdc_Channel],
  acc.[new_hq_ep],
  acc.[new_NielsenCoverage]

--UNION ALL

--SELECT

--    year(CASE
--             WHEN mut.[cdc_datum_document] IS NULL THEN mut.[cdc_datum]
--             ELSE mut.[cdc_datum_document] END)                                  AS [year],
--    month(CASE
--              WHEN mut.[cdc_datum_document] IS NULL THEN mut.[cdc_datum]
--              ELSE mut.[cdc_datum_document] END)                                 AS [month],
--    [reg].[cdc_regionname]                                                         AS [region],
--    CASE mut.[cdc_type] WHEN 754460022 THEN 'Fact Promo' ELSE 'Fact regular' END AS [line_type],
--    CASE
--        WHEN acc.[accountid] IN
--             (
--              '1BE02D54-5FB3-E711-80E5-0050560186BB', --|Zimus_KemerovoTsimus
--              '2DE02D54-5FB3-E711-80E5-0050560186BB', --|Auss_Khabarovsk
--              '2FE02D54-5FB3-E711-80E5-0050560186BB', --|Desyatochka_Komsomolsk-na-Amure
--              'B9C84F27-3460-E911-810A-0050560186BB' --|Monetka_Direct
--                 ) THEN acc.[name]
--        ELSE acc.[parentaccountidname]
--        END																			AS [distributor],
--    acc.[name]																		AS [client],
--    prod.[cdc_caterogyname]															AS [catigory],
--    prod.[cdc_brandname]															AS [brandname],

--    SUM(mut.[cdc_con])															AS [con],
--    SUM(mut.[cdc_ges])															AS [ges],
--    SUM(mut.[cdc_pld])															AS [pld],
--    SUM(mut.[cdc_ppd])															AS [ppd],
--    SUM(mut.[cdc_oncch])															AS [oncch],
--    SUM(mut.[cdc_oncdb])															AS [oncdb],
--    SUM(mut.[cdc_cpv])															AS [cpv],
--    SUM(mut.[cdc_rp])																AS [rp],
--    SUM(mut.[cdc_offcch])															AS [offcch],
--    SUM(mut.[cdc_offc_promo_abs])													AS [offc_promo_abs],
--    SUM(mut.[cdc_offc_promo_perc])												AS [offc_promo_perc],
--    SUM(mut.[cdc_offcdb])															AS [offcdb],
--    SUM(mut.[cdc_offextra])														AS [offextra],
--    SUM(mut.[cdc_offextra_abs])													AS [offextra_abs],
--    SUM(mut.[cdc_nes])															AS [nes],
--    SUM(mut.[cdc_comm])															AS [comm],
--    SUM(mut.[cdc_matcost])														AS [matcost],
--    SUM(mut.[cdc_trwh])															AS [trwh],
--    SUM(mut.[cdc_gp1])															AS [gp1],
--    SUM(mut.[cdc_gp2])															AS [gp2],
--    SUM(mut.[cdc_l17])															AS [l17],
--	acc.[new_NRM]																AS [nrm],
--	acc.[cdc_rating]															AS [top chains],
--	acc.[cdc_Channel]															AS [chanel],
--	acc.[new_hq_ep]																AS [HQ],
--	acc.[new_NielsenCoverage]													AS [Nielsen Coverage]

--FROM [hbcams_mscrm].[dbo].[cdc_forcastmutbase] mut

--JOIN [hbcams_mscrm].[dbo].[account] acc
--  ON mut.[cdc_ep] = acc.[accountid]
-- AND acc.[cdc_type] = 754460000

--JOIN [hbcams_mscrm].[dbo].[product] prod
--     ON mut.[cdc_ean] = prod.[productid]

--LEFT JOIN [hbcams_mscrm].[dbo].[cdc_regionlink] [reg]
--          ON mut.[cdc_ep] = [reg].[cdc_ep]


--WHERE (CASE
--           WHEN mut.[cdc_datum_document] IS NULL THEN mut.[cdc_datum]
--           ELSE mut.[cdc_datum_document] END) BETWEEN @sdate AND dateadd(DAY, -1, @cutdate)
--  AND mut.[statecode] = 0
--  AND mut.[cdc_type] IN (
--                           754460020, --|Fact Reg
--                           754460022, --|Fact Promo
--                           754460024 --|Fact AP
--    )

--GROUP BY
--  YEAR(ISNULL(mut.[cdc_datum_document], mut.[cdc_datum])),
--  MONTH(ISNULL(mut.[cdc_datum_document], mut.[cdc_datum])),
--  [reg].[cdc_regionname],
--  acc.[new_division_ep],
--  acc.[new_sales_channel],
--  CASE mut.[cdc_type] WHEN 754460012 THEN 'Promo' ELSE 'Baseline' END,
--  CASE
--    WHEN acc.[accountid] IN (
--      '1BE02D54-5FB3-E711-80E5-0050560186BB', --|Zimus_KemerovoTsimus
--      '2DE02D54-5FB3-E711-80E5-0050560186BB', --|Auss_Khabarovsk
--      '2FE02D54-5FB3-E711-80E5-0050560186BB', --|Desyatochka_Komsomolsk-na-Amure
--      'B9C84F27-3460-E911-810A-0050560186BB' --|Monetka_Direct
--      ) THEN acc.[name]
--    ELSE acc.[parentaccountidname]
--  END,
--  acc.[name],
--  prod.[cdc_caterogyname],
--  prod.[cdc_brandname]
