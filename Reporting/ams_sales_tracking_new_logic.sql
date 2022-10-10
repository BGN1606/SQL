select
  year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)                             as [year],
  concat('Q',datepart(quarter,(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)))   as [Quarter],
  month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)                            as [month],
  apo.[Division]                                                                                                                    as [Division],
  'Plan'                                                                                                                            as [Promo_Share],
  'Base'                                                                                                                            as [Scenario],
  apo.[Chain Details_2]                                                                                                             as [Customer],
  prod.[cdc_CaterogyName]                                                                                                           as [Category],
  prod.[cdc_BrandName]                                                                                                              as [Brand],

  'Confirmed'                                                                                                                       as [Status],

  sum(mut.[cdc_Con])																												as [con],
  sum(mut.[cdc_GES])																												as [ges],
  sum(mut.[cdc_PLD])																												as [pld],
  sum(isnull(mut.[cdc_PPD],0) + isnull(mut.[cdc_PXD],0))																			as [ppd],
  sum(mut.[cdc_oncch])																												as [oncch],
  sum(mut.[cdc_oncdb])																												as [oncdb],
  sum(mut.[cdc_CPV])																												as [cpv],
  sum(mut.[cdc_RP])																													as [rp],
  sum(mut.[cdc_OFFcch])																												as [offcch],
  sum(mut.cdc_offc_promo_abs) + sum(mut.cdc_offc_promo_perc)																		as [OFFc promo],
  sum(mut.[cdc_OFFcdb])																												as [offcdb],
  sum(isnull(mut.[cdc_OFFextra],0) + isnull(mut.[cdc_offextra_abs],0))																as [OFFextra],
  sum(mut.[cdc_NES])																												as [nes],
  sum(mut.cdc_trwh)																													as [Transport],
  sum(mut.cdc_comm)																													as [Commission],
  sum(mut.cdc_matcost)																												as [MatCost],
  sum(mut.cdc_gp1)																													as [GP1],
  sum(mut.cdc_gp2)																													as [GP2],
  null                                                                                                                              as [PromoName],
  null                                                                                                                              as [promo_class]

from [HBCAMS_MSCRM].[dbo].[cdc_ForcastMutBase] mut

join [HBCAMS_IntegrationDB].[dbo].[ApoPartner] apo with (nolock)
  on mut.cdc_ep = apo.AccountId
 and [Business Type] = 'Key Retail'

join [HBCAMS_MSCRM].[dbo].[Product] prod
  on mut.[cdc_EAN] = prod.[ProductId]

where mut.cdc_type = 754460100 --|Plan
  and mut.statecode = 0

  /*Фильтры для интерфейса*/
  and year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) in (@Year)
  and month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) in (@Month)
  and apo.[Chain Details_2] in (@Customer)

group by
  year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end),
  concat('Q',datepart(quarter,(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end))),
  month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end),
  apo.[Division],
  apo.[Chain Details_2],
  prod.[cdc_CaterogyName],
  prod.[cdc_BrandName]

---------------------------------
union all
---------------------------------

select
  year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)                             as [year],
  concat('Q',datepart(quarter,(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)))   as [Quarter],
  month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)                            as [month],
  apo.[Division]                                                                                                                    as [Division],
  case mut.cdc_type when 754460022 then 'Promo' else 'Baseline' end                                                                 as [Promo_Share],
  'Actual'                                                                                                                          as [Scenario],
  apo.[Chain Details_2]                                                                                                             as [Customer],
  prod.[cdc_CaterogyName]                                                                                                           as [Category],
  prod.[cdc_BrandName]                                                                                                              as [Brand],
  'Actual'                                                                                                                          as [status],
  sum(mut.[cdc_Con])																												as [con],
  sum(mut.[cdc_GES])																												as [ges],
  sum(mut.[cdc_PLD])																												as [pld],
  sum(isnull(mut.[cdc_PPD],0) + isnull(mut.[cdc_PXD],0))																			as [ppd],
  sum(mut.[cdc_oncch])																												as [oncch],
  sum(mut.[cdc_oncdb])																												as [oncdb],
  sum(mut.[cdc_CPV])																												as [cpv],
  sum(mut.[cdc_RP])																													as [rp],
  sum(mut.[cdc_OFFcch])																												as [offcch],
  sum(mut.cdc_offc_promo_abs) + sum(mut.cdc_offc_promo_perc)																		as [OFFc promo],
  sum(mut.[cdc_OFFcdb])																												as [offcdb],
  sum(isnull(mut.[cdc_OFFextra],0) + isnull(mut.[cdc_offextra_abs],0))																as [OFFextra],
  sum(mut.[cdc_NES])																												as [nes],
  sum(mut.cdc_trwh)																													as [Transport],
  sum(mut.cdc_comm)																													as [Commission],
  sum(mut.cdc_matcost)																												as [MatCost],
  sum(mut.cdc_gp1)																													as [GP1],
  sum(mut.cdc_gp2)																													as [GP2],
  promo.[cdc_name]                                                                                                                  as [PromoName],
  promo_class.[Value]                                                                                                               as [promo_class]

from [HBCAMS_MSCRM].[dbo].[cdc_ForcastMutBase] mut

join [HBCAMS_IntegrationDB].[dbo].[ApoPartner] apo
  on mut.cdc_ep = apo.AccountId
 and [Business Type] = 'Key Retail'

left join [HBCAMS_MSCRM].[dbo].[cdc_PromoBase] promo
  on mut.[cdc_Promo] = promo.[cdc_PromoId]
 and promo.statecode = 0

join [HBCAMS_MSCRM].[dbo].[Product] prod
  on mut.[cdc_EAN] = prod.[ProductId]

left join [HBCAMS_MSCRM].[dbo].[FilteredStringMap] promo_class with (nolock)
  on promo.[cdc_lst_promo_class] = promo_class.[AttributeValue]
 and promo_class.[LangId] = 1049
 and promo_class.[FilteredViewName] = 'Filteredcdc_Promo'
 and promo_class.[AttributeName] = 'cdc_lst_promo_class'

where mut.cdc_type in (754460020, --|Fact Reg
                       754460022, --|Fact Promo
                       754460024) --|Fact AP
  and mut.statecode = 0
  and (case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) < (dateadd(m, datediff(m, 0, getdate()), 0))

  /*Фильтры для интерфейса*/
  and year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)  in (@Year)
  and month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) in (@Month)
  and apo.[Chain Details_2]     in (@Customer)

group by
  year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end),
  concat('Q',datepart(quarter,(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end))),
  month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end),
  apo.[Division],
  case mut.cdc_type when 754460022 then 'Promo' else 'Baseline' end,
  apo.[Chain Details_2],
  prod.[cdc_CaterogyName],
  prod.[cdc_BrandName],
  promo.[cdc_name],
  promo_class.[Value]

---------------------------------
union all
---------------------------------

select
  year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)                             as [year],
  concat('Q',datepart(quarter,(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)))   as [Quarter],
  month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)                            as [month],
  apo.[Division]                                                                                                                    as [Division],
  case mut.[cdc_Type] when 754460012  then 'Promo' else 'Baseline' end                                                              as [Promo_Share],
  case
    when promo.[cdc_is_scenario_included_worst] = 1 then 'Base'
    when promo.[cdc_is_scenario_included_working] = 1 then 'Other measures'
    when promo.[cdc_is_scenario_included_best] = 1 then 'Hard risks'
    when promo.[cdc_lst_approval_probability] = 754460003 then 'Alternatives'
    else 'Base'
  end                                                                                                                               as [Scenario],
  apo.[Chain Details_2]                                                                                                             as [Customer],
  prod.[cdc_CaterogyName]                                                                                                           as [Category],
  prod.[cdc_BrandName]                                                                                                              as [Brand],
  case
    when promo.[cdc_type] = 754460000 and promo.[cdc_clientconfirmed] = 1 then 'Confirmed'
    when promo.[cdc_lst_approval_probability] = 754460003 then 'Alternative'
    when promo.[cdc_lst_ground] = 754460001 then 'Confirmed'
    when promo.[cdc_type] = 754460003 and promo.[cdc_lst_approval_probability] = 754460002 then 'Confirmed'
    when promo.[cdc_type] = 754460002 or mut.[cdc_Type] = 754460010 then 'Confirmed'
  else 'Unconfirmed'
  end                                                                                                                               as [status],
  sum(mut.[cdc_Con])																												as [con],
  sum(mut.[cdc_GES])																												as [ges],
  sum(mut.[cdc_PLD])																												as [pld],
  sum(isnull(mut.[cdc_PPD],0) + isnull(mut.[cdc_PXD],0))																			as [ppd],
  sum(mut.[cdc_oncch])																												as [oncch],
  sum(mut.[cdc_oncdb])																												as [oncdb],
  sum(mut.[cdc_CPV])																												as [cpv],
  sum(mut.[cdc_RP])																													as [rp],
  sum(mut.[cdc_OFFcch])																												as [offcch],
  sum(mut.cdc_offc_promo_abs) + sum(mut.cdc_offc_promo_perc)																		as [OFFc promo],
  sum(mut.[cdc_OFFcdb])																												as [offcdb],
  sum(isnull(mut.[cdc_OFFextra],0) + isnull(mut.[cdc_offextra_abs],0))																as [OFFextra],
  sum(mut.[cdc_NES])																												as [nes],
  sum(mut.cdc_trwh)																													as [Transport],
  sum(mut.cdc_comm)																													as [Commission],
  sum(mut.cdc_matcost)																												as [MatCost],
  sum(mut.cdc_gp1)																													as [GP1],
  sum(mut.cdc_gp2)																													as [GP2],
  promo.[cdc_name]                                                                                                                  as [PromoName],
  promo_class.[Value]                                                                                                               as [promo_class]

from [HBCAMS_MSCRM].[dbo].[cdc_ForcastMutBase] mut

join [HBCAMS_IntegrationDB].[dbo].[ApoPartner] apo
  on mut.cdc_ep = apo.AccountId
 and [Business Type] = 'Key Retail'

left join [HBCAMS_MSCRM].[dbo].[cdc_PromoBase] promo
  on mut.[cdc_Promo] = promo.[cdc_PromoId]
 and promo.statecode = 0

join [HBCAMS_MSCRM].[dbo].[Product] prod
  on mut.[cdc_EAN] = prod.[ProductId]

left join [HBCAMS_MSCRM].[dbo].[FilteredStringMap] promo_class with (nolock)
  on promo.[cdc_lst_promo_class] = promo_class.[AttributeValue]
 and promo_class.[LangId] = 1049
 and promo_class.[FilteredViewName] = 'Filteredcdc_Promo'
 and promo_class.[AttributeName] = 'cdc_lst_promo_class'

where mut.cdc_type in (754460010, --|Baseline
                       754460011, --|BaselineCaniball
                       754460012, --|Promo
                       754460013) --|BaselinePromoCorrect
  and mut.statecode = 0
  and (case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) >= (dateadd(m, datediff(m, 0, getdate()), 0))

  /*Фильтры для интерфейса*/
  and year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)  in (@Year)
  and month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) in (@Month)
  and apo.[Chain Details_2]     in (@Customer)

group by
  year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end),
  concat('Q',datepart(quarter,(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end))),
  month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end),
  apo.[Division],
  case mut.[cdc_Type] when 754460012  then 'Promo' else 'Baseline' end,
  case
    when promo.[cdc_is_scenario_included_worst] = 1 then 'Base'
    when promo.[cdc_is_scenario_included_working] = 1 then 'Other measures'
    when promo.[cdc_is_scenario_included_best] = 1 then 'Hard risks'
    when promo.[cdc_lst_approval_probability] = 754460003 then 'Alternatives'
    else 'Base'
  end,
  apo.[Chain Details_2],
  prod.[cdc_CaterogyName],
  prod.[cdc_BrandName],
  case
    when promo.[cdc_type] = 754460000 and promo.[cdc_clientconfirmed] = 1 then 'Confirmed'
    when promo.[cdc_lst_approval_probability] = 754460003 then 'Alternative'
    when promo.[cdc_lst_ground] = 754460001 then 'Confirmed'
    when promo.[cdc_type] = 754460003 and promo.[cdc_lst_approval_probability] = 754460002 then 'Confirmed'
    when promo.[cdc_type] = 754460002 or mut.[cdc_Type] = 754460010 then 'Confirmed'
  else 'Unconfirmed'
  end,
  promo.[cdc_name],
  promo_class.[Value]

option (recompile)


-- Filters
-- EP
select distinct

apo.[Chain Details_2] as [Customer]

from [HBCAMS_IntegrationDB].[dbo].ApoPartner apo

join [HBCAMS_MSCRM].[dbo].[FilteredAccount] facc
  on apo.[AccountId] = facc.[accountid]
where apo.[Business Type] = 'Key Retail'

order by 1