--set language 'russian'
set arithabort off
set arithignore on
set ansi_warnings off

use HBCAMS_MSCRM

declare
    @year int
   ,@month int

set @year = year(@date)
set @month = month(@date)

if object_id('tempdb..#preRes') is not null drop table #preRes;

with Filteredpromo as (
                      select
                        year(cdc_deliveryto)                    as [Year],
                        month(cdc_deliveryto)                   as [Month],
                        promo.cdc_EP                            as [AccountId],
                        promo.cdc_PromoId                       as [PromoId],
                        promo.cdc_name                          as [PromoName],
                        cast(promo.cdc_deliveryfrom as date)    as [Shipment_start],
                        cast(promo.cdc_deliveryto as date)      as [Shipment_end],
                        cast(promo.cdc_onshelfform as date)     as [Shelf_start],
                        cast(promo.cdc_onshelfto as date)       as [Shelf_end],
                        promo.cdc_offpercentqty                 as [BMC_autosplit],
                        mech.MechanicsName                      as [Mechanics],
                        promo.cdc_is_pallet                     as [Pallette],
                        promo.cdc_is_leaflet                    as [Leaflet],
                        promo.cdc_extraabs                      as [Off_extra_absolute_forecasted],
                        promo.cdc_extraabs                      as [Off_extra_absolute_actual],
                        promo.cdc_offpercentabs                 as [BMC_absolute_forecasted],
                        promo.cdc_offpercentabs                 as [BMC_absolute_actual],
                        promo.cdc_l17abs                        as [L17_forecasted],
                        promo.cdc_l17abs                        as [L17_actual],
                        promo.cdc_lst_off_percent_choice        as [cdc_lst_off_percent_choice],
                        promo.cdc_OFFKAM                        as [Off_BMC_LKAM/RKAM],
                        promo.cdc_OFFcomment                    as [Off_BMC_Comment_LKAM/RKAM],
                        promo.cdc_extraKAM                      as [Off_Extra_LKAM/RKAM],
                        promo.cdc_Extracomment                  as [Off_Extra_Comment_LKAM/RKAM],
                        promo.cdc_L17KAM                        as [L17_LKAM/RKAM],
                        promo.cdc_L17comment                    as [L17_Comment_LKAM/RKAM]
                      from cdc_Promo promo
                      left join [HBCAMS_IntegrationDB].[dbo].[Mechanics] mech
                        on promo.cdc_mechanics = mech.MechanicsId
                      where [cdc_type] <> 754460003
                       and [cdc_status] in (754460001,754460002,754460003)
                       and year(cdc_deliveryto) in (@year)
                       and month(cdc_deliveryto) in (@month)
                      ),
            region as (
						SELECT DISTINCT
							 acc.[account_id]
							,acc.[division_id]
							,acc.[division_name]
						FROM [HBCAMS_IntegrationDB].[bi].[Account] acc
                      ),
            mut_fc as (
                      select
                        mut_fc.[cdc_Promo],
                        mut_fc.[cdc_EAN],
                        sum(isnull(mut_fc.[cdc_ONcch],0)) as [ONcch_fc],
                        sum(isnull(mut_fc.[cdc_GES],0))   as [GES_fc],
                        sum(isnull(mut_fc.[cdc_PLD],0))   as [PLD_fc],
                        sum(isnull(mut_fc.[cdc_PPD],0))   as [PPD_fc]
                      from [HBCAMS_MSCRM].[dbo].[cdc_ForcastMut] as mut_fc
                      where mut_fc.[cdc_Type] = 754460012
                       and mut_fc.[statecode] = 0
                      group by
                        mut_fc.[cdc_Promo],
                        mut_fc.[cdc_EAN]
                      ),
           mut_act as (
                      select
                        mut_fc.[cdc_Promo],
                        mut_fc.[cdc_EAN],
                        sum(isnull(mut_fc.[cdc_GES],0))   as [GES_act]
                      from [HBCAMS_MSCRM].[dbo].[cdc_ForcastMut] as mut_fc
                      where mut_fc.[cdc_Type] = 754460022
                       and mut_fc.[statecode] = 0
                      group by
                        mut_fc.[cdc_Promo],
                        mut_fc.[cdc_EAN]
                      )
         ,discount as (
                      select
                        promo.[PromoId],
                        promo.[cdc_lst_off_percent_choice] as [discount_budget_type],

                        case
                          when promo.[cdc_lst_off_percent_choice] in (754460000,754460002) and reg.[division_id] = 100000006
                            then sum(([GES_act] * (1 - ([ONcch_fc] / (case when ([GES_fc] - [PLD_fc] - [PPD_fc]) = 0 then 1 else ([GES_fc] - [PLD_fc] - [PPD_fc]) end) )))
                                 *
                                 (pit.[cdc_off] / 100))

                          when promo.[cdc_lst_off_percent_choice] in (754460000,754460002) and reg.[division_id] <> 100000006
                            then sum(([GES_act] * (1 - ([ONcch_fc] / (case when GES_fc = 0 then 1 else GES_fc end) )))
                                 *
                                 (pit.[cdc_off] / 100))
                          else 0
                        end as  [discount_actual]

                      from Filteredpromo as promo

                      join cdc_promoitems as pit
                        on promo.[PromoId] = pit.[cdc_promo]

                      join region as reg
                        on promo.[AccountId] = reg.[account_id]

                      left join mut_fc
                        on promo.[PromoId] = mut_fc.[cdc_Promo]
                       and pit.[cdc_SKU] = mut_fc.[cdc_EAN]

                      left join mut_act
                        on promo.[PromoId] = mut_act.[cdc_Promo]
                       and pit.[cdc_SKU] = mut_act.[cdc_EAN]
                      group by
                        reg.[division_id],
                        promo.[PromoId],
                        promo.[cdc_lst_off_percent_choice]
                      ),
           mut_fc2 as (
                      select
                        cdc_EP,
                        cdc_Promo,
                        sum([cdc_CON])                                                          as [cdc_con],
                        sum([cdc_GES])                                                          as [cdc_ges],
                        sum([cdc_NES])                                                          as [cdc_nes],
                        sum([cdc_PPD])                                                          as [cdc_ppd],
                        sum(isnull([cdc_offextra],0) + isnull([cdc_offextra_abs],0))            as [cdc_OFFextra],
                        sum(isnull([cdc_offc_promo_perc],0) + isnull([cdc_OFFc_promo_abs],0))   as [cdc_offc_promo_perc]
                      from [HBCAMS_MSCRM].[dbo].[cdc_ForcastMut]
                      where [cdc_Type] = 754460012
                        and [statecode] = 0
                      group by
                        cdc_EP,
                        cdc_Promo
                      ),
          mut_act2 as (
                      select
                        cdc_EP,
                        cdc_Promo,
                        sum([cdc_CON])                                                          as [cdc_con],
                        sum([cdc_GES])                                                          as [cdc_ges],
                        sum([cdc_NES])                                                          as [cdc_nes],
                        sum([cdc_PPD])                                                          as [cdc_ppd],
                        sum(isnull([cdc_offextra],0) + isnull([cdc_offextra_abs],0))            as [cdc_OFFextra],
                        sum(isnull([cdc_offc_promo_perc],0) + isnull([cdc_OFFc_promo_abs],0))   as [cdc_offc_promo_perc]
                      from [HBCAMS_MSCRM].[dbo].[cdc_ForcastMut]
                      where [cdc_Type] = 754460022
                       and [statecode] = 0
                      group by
                        cdc_EP,
                        cdc_Promo
                      )

select
  promo.[Year]                                        as [Year],
  promo.[Month]                                       as [Month],
  reg.[division_name]								  as [Region],
  ParentAccountIdName                                 as [Distributor],
  [Name]                                              as [Client],
  acc.OwnerIdName                                     as [Responsibles],
  promo.PromoName                                     as [PromoName],
  promo.BMC_autosplit                                 as [BMC_autosplit],
  promo.Mechanics                                     as [Mechanics],
  promo.Pallette                                      as [Pallette],
  promo.Leaflet                                       as [Leaflet],
  promo.Shelf_start                                   as [Shelf_start],
  promo.Shelf_end                                     as [Shelf_end],
  promo.Shipment_start                                as [Shipment_start],
  promo.Shipment_end                                  as [Shipment_end],
  sum(mut_fc.[cdc_CON])                               as [CON_forecasted],
  sum(mut_act.[cdc_CON])                              as [CON_actual],
  sum(mut_fc.[cdc_ges])                               as [GES_forecasted],
  sum(mut_act.[cdc_ges])                              as [GES_actual],
  sum(mut_fc.[cdc_nes])                               as [NES_forecasted],
  sum(mut_act.[cdc_nes])                              as [NES_actual],
  sum(mut_fc.[cdc_PPD])                               as [PPD_forecasted],
  sum(mut_act.[cdc_PPD])                              as [PPD_actual],
  convert(real,null)                                  as [TS_forecasted],
  convert(real,null)                                  as [TS_actual],
  sum(promo.Off_extra_absolute_forecasted)            as [Off_extra_absolute_forecasted],
  sum(promo.Off_extra_absolute_actual)                as [Off_extra_absolute_actual],
  sum(mut_fc.[cdc_OFFextra]) -
  isnull(sum(promo.Off_extra_absolute_forecasted),0)  as [Off_extra_discount_forecasted],
  case
    when [discount_budget_type] = 754460002
      then sum(discount.discount_actual)
  else 0 end                                          as [Off_extra_discount_actual],
  sum(mut_fc.[cdc_OFFextra])                          as [Off_extra_Total_forecasted],
  convert(real,null)                                  as [Off_extra_Total_actual],
  [Off_Extra_LKAM/RKAM]                               as [Off_Extra_LKAM/RKAM],
  [Off_Extra_Comment_LKAM/RKAM]                       as [Off_Extra_Comment_LKAM/RKAM],
  sum(promo.BMC_absolute_forecasted)                  as [BMC_absolute_forecasted],
  sum(promo.BMC_absolute_actual)                      as [BMC_absolute_actual],
  sum(mut_fc.[cdc_offc_promo_perc]) -
  isnull(sum(promo.BMC_absolute_forecasted),0)        as [BMC_discount_forecasted],
  case
    when [discount_budget_type] = 754460000
      then sum(discount.discount_actual)
  else 0 end                                          as [BMC_discount_actual],
  convert(real,null)                                  as [BMC_Total_forecasted],
  convert(real,null)                                  as [BMC_Total_actual],
  [Off_BMC_LKAM/RKAM]                                 as [Off_BMC_LKAM/RKAM],
  [Off_BMC_Comment_LKAM/RKAM]                         as [Off_BMC_Comment_LKAM/RKAM],
  sum(promo.L17_forecasted)                           as [L17_forecasted],
  sum(promo.L17_actual)                               as [L17_actual],
  [L17_LKAM/RKAM],
  [L17_Comment_LKAM/RKAM]

into #preRes
from Account acc

join filteredpromo promo
  on acc.AccountId = promo.AccountId

join region as reg
  on acc.AccountId = reg.[account_id]

left join mut_fc2 as mut_fc
  on promo.AccountId = mut_fc.cdc_EP
 and promo.PromoId = mut_fc.cdc_Promo

left join mut_act2 as mut_act
  on promo.AccountId = mut_act.cdc_EP
 and promo.PromoId = mut_act.cdc_Promo

left join discount
  on promo.PromoId = discount.PromoId

where acc.StateCode = 0
  and reg.[division_id] <> 100000006

group by
  promo.[Year],
  promo.[Month],
  reg.[division_name],
  acc.AccountId,
  promo.PromoId,
  ParentAccountIdName,
  [Name],
  acc.OwnerIdName,
  promo.PromoName,
  promo.BMC_autosplit,
  promo.Mechanics,
  promo.Pallette,
  promo.Leaflet,
  promo.Shelf_start,
  promo.Shelf_end,
  promo.Shipment_start,
  promo.Shipment_end,
  promo.[Off_BMC_LKAM/RKAM],
  promo.[Off_BMC_Comment_LKAM/RKAM],
  promo.[Off_Extra_LKAM/RKAM],
  promo.[Off_Extra_Comment_LKAM/RKAM],
  promo.[L17_LKAM/RKAM],
  promo.[L17_Comment_LKAM/RKAM],
  [discount_budget_type]



update #preRes
set  [BMC_Total_actual]           = isnull([BMC_absolute_actual],0.0)           + isnull([BMC_discount_actual],0.0),
     [Off_extra_Total_actual]     = isnull([Off_extra_absolute_actual],0.0)     + isnull([Off_extra_discount_actual],0.0),
     [BMC_Total_forecasted]       = isnull([BMC_absolute_forecasted],0.0)       + isnull([BMC_discount_forecasted],0.0),
     [Off_extra_Total_forecasted] = isnull([Off_extra_absolute_forecasted],0.0) + isnull([Off_extra_discount_forecasted],0.0),
     [TS_forecasted]              = isnull((isnull(GES_forecasted,0.0) - isnull(NES_forecasted,0.0))/ isnull(GES_forecasted,0.0),0.0),
     [TS_actual]                  = isnull((isnull(GES_actual,0.0) - isnull(NES_actual,0.0))/ isnull(GES_actual,0.0),0.0)

update #preRes
set [Off_extra_absolute_actual] = 0.0, [BMC_absolute_actual] = 0.0
where [CON_actual] is null or [CON_actual] = 0

select * from #preRes
where client in (@EP)

-- Filters
-- Ep
SELECT DISTINCT name
FROM            FilteredAccount

-- ReportDate
exec [HBCAMS_MSCRM].[dbo].[ams_date_generator]
