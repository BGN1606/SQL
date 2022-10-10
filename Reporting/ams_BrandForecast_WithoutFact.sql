use hbcams_mscrm

select
  division.[Value]                                                                                                      as [region],
  case mut.[cdc_Type] when 754460012  then 'Promo' else 'Baseline' end                                                  as [line_type],
  accnt.[ParentAccountIdName]                                                                                           as [distributor],
  accnt.[Name]                                                                                                          as [client],
  year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)                 as [year],
  month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end)                as [month],
  prod.[cdc_CaterogyName]                                                                                               as [catigory],
  prod.[cdc_BrandName]                                                                                                  as [brandname],
  case mut.[cdc_Type] when 754460012 then promo.[cdc_name] else null end                                                as [promoname],
  case
    when cdc_clientconfirmed = 1 then 'Confirmed'
    when cdc_lst_approval_probability = 754460003 then 'Alternative'
  else 'Unconfirmed'
  end                                                                                                                   as [Status],
  case promo.[cdc_is_gap_closing]  when 1 then 'Extra measure' else 'Base' end                                          as [extra_measures],
  sum(mut.[cdc_Con])   as [Con],
  sum(mut.[cdc_GES])   as [GES],
  sum(mut.[cdc_PLD])   as [PLD],
  sum(mut.[cdc_PPD])   as [PPD],
  sum(mut.[cdc_oncch])   as [oncch],
  sum(mut.[cdc_oncdb])   as [oncdb],
  sum(mut.[cdc_CPV])   as [CPV],
  sum(mut.[cdc_RP])   as [RP],
  sum(mut.[cdc_OFFcch])   as [OFFcch],
  sum(mut.[cdc_OFFc_promo_abs])   as [OFFc_promo_abs],
  sum(mut.[cdc_offc_promo_perc])   as [OFFc_promo_perc],
  sum(mut.[cdc_OFFcdb])   as [OFFcdb],
  sum((isnull(mut.[cdc_OFFextra],0) + isnull(mut.[cdc_offextra_abs],0)))   as [OFFextra],
  sum(mut.[cdc_NES])   as [NES],
  sum(mut.[cdc_Comm])   as [COMM],
  sum(mut.[cdc_MatCost])   as [MatCost],
  sum(mut.[cdc_TrWh])   as [TrWh],
  sum(mut.[cdc_GP1])   as [GP1],
  sum(mut.[cdc_L17])   as [L17],
  sum(mut.[cdc_GP2])   as [GP2]

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

where mut.[statecode] = 0
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

group by
  division.[Value],
  case mut.[cdc_Type] when 754460012  then 'Promo' else 'Baseline' end,
  accnt.[ParentAccountIdName],
  accnt.[Name],
  year(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end),
  month(case when mut.[cdc_datum_document] is null then mut.cdc_datum else mut.[cdc_datum_document] end),
  prod.[cdc_CaterogyName],
  prod.[cdc_BrandName],
  case mut.[cdc_Type] when 754460012 then promo.[cdc_name] else null end,
  case
    when cdc_clientconfirmed = 1 then 'Confirmed'
    when cdc_lst_approval_probability = 754460003 then 'Alternative'
  else 'Unconfirmed'
  end,
  case promo.[cdc_is_gap_closing]  when 1 then 'Extra measure' else 'Base' end

option (recompile)


-- Filters

-- Ep
select distinct Name from FilteredAccount

-- Region
SELECT division.[Value]
FROM [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)

WHERE division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'