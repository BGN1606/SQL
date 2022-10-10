use HBCAMS_IntegrationDB

select
  division.[Value]                                                       as [Region],
  case when account.[AccountId] in
    (
     '1BE02D54-5FB3-E711-80E5-0050560186BB', --|Zimus_KemerovoTsimus
     '2DE02D54-5FB3-E711-80E5-0050560186BB', --|Auss_Khabarovsk
     '2FE02D54-5FB3-E711-80E5-0050560186BB', --|Desyatochka_Komsomolsk-na-Amure
     'B9C84F27-3460-E911-810A-0050560186BB'  --|Monetka_Direct
    ) then account.[Name] else account.[ParentAccountIdName]
  end                                                                           as [Distributor],
  account.[Name]                                                                as [AccountName],
  promo.[cdc_name]                                                              as [PromoName],
  promo.[cdc_deliveryfrom]                                                      as [DeliveryFrom],
  promo.[cdc_deliveryto]                                                        as [DeliveryTo],
  promo.[cdc_onshelfform]                                                       as [OnShelfFrom],
  promo.[cdc_onshelfto]                                                         as [OnShelfTo],
  case when promo.[cdc_clientconfirmed] = 0 then 'False' else 'True' end        as [ApprovedByClient],
  case when promo.[cdc_is_mm] = 0 then 'False' else 'True' end                  as [SendMM],
  case promo.[cdc_is_gap_closing]  when 1 then 'Extra measure' else 'Base' end  as [extra_measures],
  promo.[cdc_promo_typeidName]                                                  as [IndividualMechanics],
  case promo.cdc_mechanics
    when 754460000 then 'Discount'
    when 754460001 then '3=2'
    when 754460002 then 'X+1'
    when 754460003 then 'Leaflet'
    when 754460004 then 'Catalogue'
    when 754460005 then 'Additional placement'
    when 754460006 then 'Ddecorated stands'
    when 754460007 then 'Gift for purchase'
    when 754460008 then 'Lottery'
    when 754460009 then 'Creative contest'
    when 754460010 then 'Sticker promo'
    when 754460011 then 'POSM'
    when 754460012 then 'OOH'
    when 754460013 then 'Category visualization'
    when 754460014 then 'Virtual shrink'
    else 'unknown'
  end                                                                           as [Mechanics],
  tasks.[cdc_name]                                                              as [TasksName]

from [HBCAMS_MSCRM].[dbo].[cdc_Promo] promo

join [HBCAMS_MSCRM].[dbo].[Account] account
  on account.[AccountId] = promo.[cdc_EP]

left join [HBCAMS_MSCRM].[dbo].[cdc_field_team_task_cdc_promo] tasks_promo
  on promo.[cdc_PromoId] = tasks_promo.[cdc_promoid]

join [HBCAMS_MSCRM].[dbo].[cdc_field_team_task] tasks
  on tasks_promo.[cdc_field_team_taskid] = tasks.[cdc_field_team_taskId]

LEFT JOIN [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)
  ON account.[new_division_EP] = division.[AttributeValue]
 AND division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'

where account.[StateCode] = 0
  and account.[cdc_Type] = 754460000
  and promo.[statecode] = 0
  and promo.cdc_status in (
                           754460001, --|Открыто
                           754460002, --|Утверждено
                           754460003  --|Завершено
                          )
/*Фильтры для интерфейса*/
  and @ReportDate between promo.[cdc_onshelfform] and promo.[cdc_onshelfto]
  and division.[Value] in (@Region)
  and account.[Name] in (@AccountName)


-- Filters

-- ReportDate
select distinct
  (dateadd(m, datediff(m, 0, [cdc_onshelfform]), 0)) as [ReportDate]
from [HBCAMS_MSCRM].[dbo].[cdc_Promo]
where [statecode] = 0
 and year([cdc_onshelfform]) between year(getdate())-1 and year(getdate())+1
order by [ReportDate]

-- Ep
select distinct
[Name] as [AccountName]
from [HBCAMS_MSCRM].[dbo].[Account]
where [StateCode] = 0
  and [cdc_Type] = 754460000
order by [AccountName]


-- Division
SELECT division.[Value]
FROM [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)

WHERE division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'
