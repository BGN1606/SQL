--set language 'russian'
set arithabort off
set arithignore on
set ansi_warnings off
use hbcams_mscrm



declare @period int = @per

select

case isnull(division.[AttributeValue],0000)
  when 100000006 then year(mut.cdc_datum)
  else year(dateadd(day,-14,mut.cdc_datum))
end                                               as [Год],

case isnull(division.[AttributeValue],0000)
  when 100000006 then month(mut.cdc_datum)
  else month(dateadd(day,-14,mut.cdc_datum))
end                                               as [Месяц],

case isnull(division.[AttributeValue],0000)
  when 100000006 then cast(mut.cdc_datum as date)
  else cast(dateadd(day,-14,mut.cdc_datum) as date)
end                                               as [Дата],


isnull(division.[Value],'UNALLOCATED')           as [Дивизион],

case
 when mut.cdc_type in (754460010,754460011,754460013)  then 'Baseline'
 when mut.cdc_type in (754460012)  then 'Promo'
end                                                   as [Тип строки],
apo.[Apo Partner]                                     as [APO Partner],
apo.[Chain Details]                                   as [Chain details],
prod.cdc_brandname                                    as [Бренд],
case
 when mut.cdc_type in (754460010,754460011,754460013)  then null
 else mut.cdc_promoname
end                                                   as [Type],
prod.ProductNumber                                    as [EAN],
prod.cdc_description                                  as [Product name],
case
  when cdc_national_delisting_date is null then
    case
	  when cast(cdc_national_start_date as date) >= dateadd(month,-4,cast(getdate() as date)) then 'Novelty'
	  else 'Core'
    end
  else 'Core'
end                                                   as [Product Status],

  case
    when cdc_clientconfirmed = 1 then 'Confirmed'
    when cdc_lst_approval_probability = 754460003 then 'Alternative'
  else 'Unconfirmed'
  end                                                   as [Status],

sum(mut.cdc_con)    as [CON],
sum(mut.cdc_ges)    as [GES],
sum(mut.cdc_ppd)    as [PPD],
sum(mut.cdc_pld)    as [PLD],
sum(mut.cdc_oncch)  as [ONcch],
sum(mut.cdc_oncdb)  as [ONcdb],

case
 when isnull(division.[AttributeValue],0000) = 100000006
  then sum(mut.cdc_oncch)
      /(
	    sum(mut.cdc_ges)
       -sum(mut.cdc_ppd)
	   -sum(mut.cdc_pld)
	   )
else sum(mut.cdc_oncdb)
    /(
	  sum(mut.cdc_ges)
   -sum(mut.cdc_ppd)
	 -sum(mut.cdc_pld)
	 )
end                                                     as [OnContract],
sum(mut.cdc_cpv)      as [CPV],
sum(mut.cdc_rp)       as [RP],
sum(mut.cdc_offcch)   as [OFFcch],
sum(mut.cdc_offc_promo_abs)+sum(mut.cdc_offc_promo_perc) as [OFFc promo],
sum(mut.cdc_offcdb)   as [OFFcdb],
sum((isnull(mut.[cdc_OFFextra],0) + isnull(mut.[cdc_offextra_abs],0)))   as [offextra],
sum(mut.cdc_nes)      as [NES],
sum(mut.cdc_trwh)     as [Transport],
sum(mut.cdc_comm)     as [Commission],
sum(mut.cdc_matcost)  as [MatCost],
sum(mut.cdc_gp1)      as [GP1],
sum(mut.cdc_gp2)      as [GP2]

from cdc_forcastmut mut with (nolock)

left join product prod with (nolock)
  on mut.cdc_ean=prod.productid

left join cdc_promo promo with (nolock)
  on mut.cdc_promo=promo.cdc_promoid
 and promo.statecode=0

left join account accnt with (nolock)
  on mut.cdc_ep=accnt.accountid
 and accnt.statecode=0
 and accnt.cdc_type=754460000

LEFT JOIN [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)
  ON accnt.[new_division_EP] = division.[AttributeValue]
 AND division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'

left join [HBCAMS_IntegrationDB].[dbo].[ApoPartner] as apo
  on accnt.AccountId = apo.AccountId

where mut.cdc_type in (754460010,754460011,754460013,754460012)
  and mut.statecode=0
  and dateadd(mm, datediff(mm, 0, mut.cdc_datum), 0) between dateadd(mm, datediff(mm, 0, getdate()), 0)
													   and eomonth(dateadd(mm, @period, getdate()))
group by

case isnull(division.[AttributeValue],0000)
  when 100000006 then year(mut.cdc_datum)
  else year(dateadd(day,-14,mut.cdc_datum))
end,

case isnull(division.[AttributeValue],0000)
  when 100000006 then month(mut.cdc_datum)
  else month(dateadd(day,-14,mut.cdc_datum))
end,

case isnull(division.[AttributeValue],0000)
  when 100000006 then cast(mut.cdc_datum as date)
  else cast(dateadd(day,-14,mut.cdc_datum) as date)
end,
isnull(division.[Value],'UNALLOCATED'),
case
 when mut.cdc_type in (754460010,754460011,754460013)  then 'Baseline'
 when mut.cdc_type in (754460012)  then 'Promo'
end,
apo.[Apo Partner],
apo.[Chain Details],
prod.cdc_brandname,
case
 when mut.cdc_type in (754460010,754460011,754460013)  then null
 else mut.cdc_promoname
end,
prod.ProductNumber,
prod.cdc_description,
case
  when cdc_national_delisting_date is null then
    case
	  when cast(cdc_national_start_date as date) >= dateadd(month,-4,cast(getdate() as date)) then 'Novelty'
	  else 'Core'
    end
  else 'Core'
end,

  case
    when cdc_clientconfirmed = 1 then 'Confirmed'
    when cdc_lst_approval_probability = 754460003 then 'Alternative'
  else 'Unconfirmed'
  end,
  isnull(division.[AttributeValue],0000)


 /*фильтры для интерфейса*/
having apo.[Apo Partner] in (@apo_partner)
----   and mut.cdc_epname in (@ep)
----   and month(cdc_datum) in (@month)
----   and rgnlnk.cdc_regionname in (@region)
   and case
         when mut.cdc_type in (754460010,754460011,754460013)  then 'Baseline'
         when mut.cdc_type in (754460012)  then 'Promo'
       end in (@strtype)


-- Фильтры
-- Apo Partner
select distinct [Apo Partner]
from HBCAMS_IntegrationDB.dbo.ApoPartner as apo
join HBCAMS_MSCRM.dbo.FilteredAccount as acc
  on apo.[AccountId] = acc.[accountid]