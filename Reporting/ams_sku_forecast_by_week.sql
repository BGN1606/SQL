use HBCAMS_MSCRM

select
  division.[Value]                                                                                               as [region],
  case mut.[cdc_Type] when 754460012  then 'Promo' else 'Baseline' end                                                  as [line_type],
  accnt.[ParentAccountIdName]                                                                                           as [distributor],
  accnt.[Name]                                                                                                          as [client],
  case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end                       as [date],
  prod.[cdc_CaterogyName]                                                                                               as [catigory],
  prod.[cdc_BrandName]                                                                                                  as [brandname],
  prod.[ProductNumber]                                                                                                  as [ean],
  prod.[cdc_description]                                                                                                as [productname],
  case mut.[cdc_Type] when 754460012 then promo.[cdc_name] else null end                                                as [promoname],
  case
    when cdc_clientconfirmed = 1 then 'Confirmed'
    when cdc_lst_approval_probability = 754460003 then 'Alternative'
  else 'Unconfirmed'
  end                                                                                                                   as [status],
  case promo.[cdc_is_gap_closing] when 1 then 'Extra Measure' else 'Base' end                                           as [Scenario],
  sum(mut.[cdc_Con] )   as [con],
  sum(mut.[cdc_GES] )   as [ges],
  sum(mut.[cdc_PLD] )   as [pld],
  sum(mut.[cdc_PPD] )   as [ppd],
  sum(mut.[cdc_oncch] )   as [oncch],
  sum(mut.[cdc_oncdb] )   as [oncdb],
  sum(mut.[cdc_CPV] )   as [cpv],
  sum(mut.[cdc_RP] )   as [rp],
  sum(mut.[cdc_OFFcch] )   as [offcch],
  sum(mut.[cdc_OFFc_promo_abs] )   as [offc_promo_abs],
  sum(mut.[cdc_offc_promo_perc] )   as [offc_promo_perc],
  sum(mut.[cdc_OFFcdb] )   as [offcdb],
  sum((isnull(mut.[cdc_OFFextra],0) + isnull(mut.[cdc_offextra_abs],0)) )   as [offextra],
  sum(mut.[cdc_NES] )   as [nes],
  sum(mut.[cdc_Comm] )   as [comm],
  sum(mut.[cdc_MatCost] )   as [matcost],
  sum(mut.[cdc_TrWh] )   as [trwh],
  sum(mut.[cdc_GP1] )   as [gp1],
  sum(mut.[cdc_L17] )   as [l17],
  sum(mut.[cdc_GP2] )   as [gp2]

from [HBCAMS_MSCRM].[dbo].[cdc_ForcastMutBase] mut

left join [HBCAMS_MSCRM].[dbo].[Product] prod
  on mut.[cdc_EAN] = prod.[ProductId]

left join [HBCAMS_MSCRM].[dbo].[cdc_PromoBase] promo
  on mut.cdc_promo=promo.cdc_promoid
 and promo.statecode=0

left join [HBCAMS_MSCRM].[dbo].[Account] accnt
  on mut.cdc_EP=accnt.AccountId
 and accnt.StateCode=0
 and accnt.cdc_Type=754460000

LEFT JOIN [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)
  ON accnt.[new_division_EP] = division.[AttributeValue]
 AND division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'

where (case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) >= (dateadd(m, datediff(m, 0, getdate()), 0))
  and mut.[statecode] = 0
  and mut.[cdc_Type] in (
                         754460010, --|baseline
                         754460011, --|baseline canibal
                         754460012, --|Promo
                         754460013  --|baseline promo correction
                        )

  /*фильтры для интерфейса*/
  and accnt.[Name] in (@EP)
  and month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) in (@Month)
  and year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) in (@Year)
  and division.[Value] in (@Region)
  and prod.cdc_brandname in (@Brand)
  and (case mut.[cdc_Type] when 754460012  then 'Promo' else 'Baseline' end)  in (@line_type)

group by
  division.[Value],
  case mut.[cdc_Type] when 754460012  then 'Promo' else 'Baseline' end,
  accnt.[ParentAccountIdName],
  accnt.[Name],
  case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end,
  prod.[cdc_CaterogyName],
  prod.[cdc_BrandName],
  prod.[ProductNumber],
  prod.[cdc_description],
  case mut.[cdc_Type] when 754460012 then promo.[cdc_name] else null end,
  case
    when cdc_clientconfirmed = 1 then 'Confirmed'
    when cdc_lst_approval_probability = 754460003 then 'Alternative'
  else 'Unconfirmed'
  end,
  case promo.[cdc_is_gap_closing] when 1 then 'Extra Measure' else 'Base' end

union all


select
  division.[Value]                                                                                               as [region],
  case mut.[cdc_Type] when 754460022  then 'Fact Promo' else 'Fact Regular' end                                         as [line_type],
  accnt.[ParentAccountIdName]                                                                                           as [distributor],
  accnt.[Name]                                                                                                          as [client],
  case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end                       as [date],
  prod.[cdc_CaterogyName]                                                                                               as [catigory],
  prod.[cdc_BrandName]                                                                                                  as [brandname],
  prod.[ProductNumber]                                                                                                  as [ean],
  prod.[cdc_description]                                                                                                as [productname],
  case mut.[cdc_Type] when 754460022 then promo.[cdc_name] else null end                                                as [promoname],
  case
    when cdc_clientconfirmed = 1 then 'Confirmed'
    when cdc_lst_approval_probability = 754460003 then 'Alternative'
  else 'Unconfirmed'
  end                                                                                                                   as [status],
  case promo.[cdc_is_gap_closing] when 1 then 'Extra Measure' else 'Base' end                                           as [Scenario],
  sum(mut.[cdc_Con] )   as [con],
  sum(mut.[cdc_GES] )   as [ges],
  sum(mut.[cdc_PLD] )   as [pld],
  sum(mut.[cdc_PPD] )   as [ppd],
  sum(mut.[cdc_oncch] )   as [oncch],
  sum(mut.[cdc_oncdb] )   as [oncdb],
  sum(mut.[cdc_CPV] )   as [cpv],
  sum(mut.[cdc_RP] )   as [rp],
  sum(mut.[cdc_OFFcch] )   as [offcch],
  sum(mut.[cdc_OFFc_promo_abs] )   as [offc_promo_abs],
  sum(mut.[cdc_offc_promo_perc] )   as [offc_promo_perc],
  sum(mut.[cdc_OFFcdb] )   as [offcdb],
  sum((isnull(mut.[cdc_OFFextra],0) + isnull(mut.[cdc_offextra_abs],0)) )   as [offextra],
  sum(mut.[cdc_NES] )   as [nes],
  sum(mut.[cdc_Comm] )   as [comm],
  sum(mut.[cdc_MatCost] )   as [matcost],
  sum(mut.[cdc_TrWh] )   as [trwh],
  sum(mut.[cdc_GP1] )   as [gp1],
  sum(mut.[cdc_L17] )   as [l17],
  sum(mut.[cdc_GP2] )   as [gp2]


from [HBCAMS_MSCRM].[dbo].[cdc_ForcastMutBase] mut

left join [HBCAMS_MSCRM].[dbo].[Product] prod
  on mut.[cdc_EAN] = prod.[ProductId]

left join [HBCAMS_MSCRM].[dbo].[cdc_PromoBase] promo
  on mut.cdc_promo=promo.cdc_promoid
 and promo.statecode=0

left join [HBCAMS_MSCRM].[dbo].[Account] accnt
  on mut.cdc_EP=accnt.AccountId
 and accnt.StateCode=0
 and accnt.cdc_Type=754460000

LEFT JOIN [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)
  ON accnt.[new_division_EP] = division.[AttributeValue]
 AND division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'

where (case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) < (dateadd(m, datediff(m, 0, getdate()), 0))
  and mut.[statecode] = 0
  and mut.[cdc_Type] in (
                         754460020, --|Fact Reg
                         754460022, --|Fact Promo
                         754460024  --|Fact AP
                        )

/*фильтры для интерфейса*/
  and accnt.[Name] in (@EP)
  and month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) in (@Month)
  and year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end) in (@Year)
  and division.[Value] in (@Region)
  and prod.[cdc_BrandName] in (@Brand)
  and (case mut.[cdc_Type] when 754460022  then 'Fact Promo' else 'Fact Regular' end)  in (@line_type)

group by
  division.[Value],
  case mut.[cdc_Type] when 754460022  then 'Fact Promo' else 'Fact Regular' end,
  accnt.[ParentAccountIdName],
  accnt.[Name],
  case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end,
  prod.[cdc_CaterogyName],
  prod.[cdc_BrandName],
  prod.[ProductNumber],
  prod.[cdc_description],
  case mut.[cdc_Type] when 754460022 then promo.[cdc_name] else null end,
  case
    when cdc_clientconfirmed = 1 then 'Confirmed'
    when cdc_lst_approval_probability = 754460003 then 'Alternative'
  else 'Unconfirmed'
  end,
  case promo.[cdc_is_gap_closing] when 1 then 'Extra Measure' else 'Base' end


-- Filters
-- EP
select distinct Name from FilteredAccount

-- Region
SELECT division.[Value]

FROM [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)

WHERE division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'

-- Brand
USE HBCAMS_MSCRM
SELECT DISTINCT
prod.cdc_brandname
FROM Product prod
order by 1