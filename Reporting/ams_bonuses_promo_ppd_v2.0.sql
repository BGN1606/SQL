use [HBCAMS_MSCRM]

--declare @date date = '20200301'

declare
  @sDate date,
  @eDate date

set @sDate = @date
set @eDate = eomonth(@date)

/*Табличная переменная для merge*/
declare @merge_target as table
(
    [year]                  int not null,
    [month]                 int not null,
    [region]                varchar (50),
    [distributor]           varchar (300),
    [client]                varchar (300),
    [responsibles]          varchar (300),
    [promoname]             varchar (300),
    [promo_number]          varchar (100),
    [bmc_autosplit]         bit,
    [mechanics]             varchar (300),
    [leaflet]               bit,
    [pallette]              bit,
    [shelf_start]           date,
    [shelf_end]             date,
    [shipment_start]        date,
    [shipment_end]          date,

    [con_fc]                decimal(19,9),
    [con_act]               decimal(19,9),
    [ges_fc]                decimal(19,9),
    [ges_act]               decimal(19,9),
    [rp_fc]                 decimal(19,9),
    [rp_act]                decimal(19,9),

    [nes_fc]                decimal(19,9),
    [nes_act]               decimal(19,9),
    [ts_fc]                 decimal(19,9),
    [ts_act]                decimal(19,9),

    [off_extra_abs_fc]      decimal(19,9),
    [off_extra_abs_act]     decimal(19,9),
    [off_extra_dsc_fc]      decimal(19,9),
    [off_extra_dsc_act]     decimal(19,9),
    [off_extra_total_fc]    decimal(19,9),
    [Off_extra_total_act]   decimal(19,9),
    [off_extra_kam_perc]    decimal(19,9),
    [off_extra_kam_comment] varchar (300),

    [bmc_abs_fc]            decimal(19,9),
    [bmc_abs_act]           decimal(19,9),
    [bmc_dsc_fc]            decimal(19,9),
    [bmc_dsc_act]           decimal(19,9),
    [bmc_total_fc]          decimal(19,9),
    [bmc_total_act]         decimal(19,9),
    [bmc_kam_perc]          decimal(19,9),
    [bmc_kam_comment]       varchar (300),

    [l17_fс]                decimal(19,9),
    [l17_act]               decimal(19,9),
    [l17_kam_perc]          decimal(19,9),
    [l17_kam_comment]       varchar (300),

    [distr_dsc_fc]          decimal(19,9),
    [distr_dsc_act]         decimal(19,9),

    [ppd_henkel_fc]         decimal(19,9),
    [ppd_henkel_act]        decimal(19,9)
);

insert into @merge_target   ([year],[month],[region],[distributor],[client],[responsibles],[promoname],[promo_number],[bmc_autosplit],[mechanics],[leaflet],[pallette],[shelf_start],[shelf_end],[shipment_start],
                             [shipment_end],[con_fc],[ges_fc],[rp_fc],[nes_fc],[ts_fc],[off_extra_abs_fc],[off_extra_dsc_fc],[off_extra_total_fc],[off_extra_kam_perc],[off_extra_kam_comment],
                             [bmc_abs_fc],[bmc_dsc_fc],[bmc_total_fc],[bmc_kam_perc],[bmc_kam_comment],[l17_fс],[l17_kam_perc],[l17_kam_comment],[distr_dsc_fc],[ppd_henkel_fc])

/*Формируем данные по прогнозам промо*/
select
  year(mut.[cdc_Datum])                                                                 as [year],
  month(mut.[cdc_Datum])                                                                as [month],
  division.[Value]																		as [region],
  accnt.[ParentAccountIdName]                                                           as [distributor],
  accnt.[Name]                                                                          as [client],
  accnt.[OwnerIdName]                                                                   as [responsibles],
  promo.[cdc_name]                                                                      as [promoname],
  promo.[cdc_number]                                                                    as [promo_number],
  promo.[cdc_offpercentqty]                                                             as [bmc_autosplit],
  mech.[MechanicsName]                                                                  as [mechanics],
  promo.[cdc_is_leaflet]                                                                as [leaflet],
  promo.[cdc_is_pallet]                                                                 as [pallette],
  promo.[cdc_onshelfform]                                                               as [shelf_start],
  promo.[cdc_onshelfto]                                                                 as [shelf_end],
  promo.[cdc_deliveryfrom]                                                              as [shipment_start],
  promo.[cdc_deliveryto]                                                                as [shipment_end],

  sum(mut.[cdc_CON])                                                                    as [con_fc],
  sum(mut.[cdc_GES])                                                                    as [ges_fc],
  sum(mut.[cdc_RP])                                                                     as [rp_fc],

  sum(mut.[cdc_NES])                                                                    as [nes_fc],
  isnull((isnull(sum(mut.[cdc_GES]),0.0) - isnull(sum(mut.[cdc_NES]),0.0)) / nullif(sum(mut.[cdc_GES]),0.0),0.0) as [ts_fc],

  sum(mut.[cdc_offextra_abs])                                                           as [off_extra_abs_fc],
  sum(mut.[cdc_OFFextra])                                                               as [off_extra_dsc_fc],
  sum(isnull(mut.[cdc_offextra_abs],0) + isnull(mut.[cdc_OFFextra],0))                  as [off_extra_total_fc],
  promo.[cdc_extraKAM]                                                                  as [off_extra_kam_perc],
  promo.[cdc_Extracomment]                                                              as [off_extra_kam_comment],

  sum(mut.[cdc_OFFc_promo_abs])                                                         as [bmc_abs_fc],
  sum(mut.[cdc_offc_promo_perc])                                                        as [bmc_dsc_fc],
  sum(isnull(mut.[cdc_OFFc_promo_abs],0) + isnull(mut.[cdc_offc_promo_perc],0))         as [bmc_total_fc],
  promo.[cdc_OFFKAM]                                                                    as [bmc_kam_perc],
  promo.[cdc_OFFcomment]                                                                as [bmc_kam_comment],

  promo.[cdc_l17abs]                                                                    as [l17_fс],
  promo.[cdc_L17KAM]                                                                    as [l17_kam_perc],
  promo.[cdc_L17comment]                                                                as [l17_kam_comment],


  sum(mut.[cdc_ppd_distr])                                                              as [distr_dsc_fc],
  sum(mut.[cdc_PPD])                                                                    as [ppd_henkel_fc]

from [HBCAMS_MSCRM].[dbo].[cdc_ForcastMutBase] mut with (nolock)

join [HBCAMS_MSCRM].[dbo].[cdc_PromoBase] promo with (nolock)
  on mut.cdc_promo=promo.cdc_promoid
 and promo.statecode=0
 and promo.cdc_type in (754460000,754460001,754460002)

join [HBCAMS_MSCRM].[dbo].[Account] accnt with (nolock)
  on mut.cdc_EP=accnt.AccountId
 and accnt.cdc_Type=754460000

LEFT JOIN [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)
  ON accnt.[new_division_EP] = division.[AttributeValue]
 AND division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'

left join [HBCAMS_IntegrationDB].[dbo].[Mechanics] mech with (nolock)
  on promo.[cdc_mechanics] = mech.[MechanicsId]

where mut.[statecode] = 0
  and division.[AttributeValue] <> 100000006
  and mut.[cdc_Datum] between @sDate and @eDate
  and mut.[cdc_Type] = 754460012 --|Forcast Promo

  --/*Фильтры для интерфейса*/
  and accnt.[Name] in (@ep)
  and (accnt.[ParentAccountIdName] in (@distributor) or accnt.[ParentAccountIdName] is null)
  and division.[Value] in (@region)

group by
  year(mut.[cdc_Datum]),
  month(mut.[cdc_Datum]),
  division.[Value],
  accnt.[ParentAccountIdName],
  accnt.[Name],
  promo.[cdc_number],
  accnt.[OwnerIdName],
  promo.[cdc_name],
  promo.[cdc_offpercentqty],
  mech.[MechanicsName],
  promo.[cdc_is_leaflet],
  promo.[cdc_is_pallet],
  promo.[cdc_onshelfform],
  promo.[cdc_onshelfto],
  promo.[cdc_deliveryfrom],
  promo.[cdc_deliveryto],
  promo.[cdc_extraKAM],
  promo.[cdc_Extracomment],
  promo.[cdc_OFFKAM],
  promo.[cdc_OFFcomment],
  promo.[cdc_l17abs],
  promo.[cdc_L17KAM],
  promo.[cdc_L17comment]


merge @merge_target as target

using
    (
     /*Формируем данные по фактам промо*/
     select
       year(mut.[cdc_Datum])                                                                 as [year],
       month(mut.[cdc_Datum])                                                                as [month],
       division.[Value]																		as [region],
       accnt.[ParentAccountIdName]                                                           as [distributor],
       accnt.[Name]                                                                          as [client],
       accnt.[OwnerIdName]                                                                   as [responsibles],
       promo.[cdc_name]                                                                      as [promoname],
       promo.[cdc_number]                                                                    as [promo_number],
       promo.[cdc_offpercentqty]                                                             as [bmc_autosplit],
       mech.[MechanicsName]                                                                  as [mechanics],
       promo.[cdc_is_leaflet]                                                                as [leaflet],
       promo.[cdc_is_pallet]                                                                 as [pallette],
       promo.[cdc_onshelfform]                                                               as [shelf_start],
       promo.[cdc_onshelfto]                                                                 as [shelf_end],
       promo.[cdc_deliveryfrom]                                                              as [shipment_start],
       promo.[cdc_deliveryto]                                                                as [shipment_end],

       sum(mut.[cdc_CON])                                                                    as [con_act],
       sum(mut.[cdc_GES])                                                                    as [ges_act],
       sum(mut.[cdc_RP])                                                                     as [rp_act],

       sum(mut.[cdc_NES])                                                                    as [nes_act],
       isnull((isnull(sum(mut.[cdc_GES]),0.0) - isnull(sum(mut.[cdc_NES]),0.0)) / nullif(sum(mut.[cdc_GES]),0.0),0.0) as [ts_act],

       sum(mut.[cdc_offextra_abs])                                                           as [off_extra_abs_act],
       sum(mut.[cdc_OFFextra])                                                               as [off_extra_dsc_act],
       sum(isnull(mut.[cdc_offextra_abs],0) + isnull(mut.[cdc_OFFextra],0))                  as [off_extra_total_act],
       promo.[cdc_extraKAM]                                                                  as [off_extra_kam_perc],
       promo.[cdc_Extracomment]                                                              as [off_extra_kam_comment],

       sum(mut.[cdc_OFFc_promo_abs])                                                         as [bmc_abs_act],
       sum(mut.[cdc_offc_promo_perc])                                                        as [bmc_dsc_act],
       sum(isnull(mut.[cdc_OFFc_promo_abs],0) + isnull(mut.[cdc_offc_promo_perc],0))         as [bmc_total_act],
       promo.[cdc_OFFKAM]                                                                    as [bmc_kam_perc],
       promo.[cdc_OFFcomment]                                                                as [bmc_kam_comment],

       promo.[cdc_l17abs]                                                                    as [l17_act],
       promo.[cdc_L17KAM]                                                                    as [l17_kam_perc],
       promo.[cdc_L17comment]                                                                as [l17_kam_comment],

       sum(mut.[cdc_ppd_distr])                                                              as [distr_dsc_act],
       sum(mut.[cdc_PPD])                                                                    as [ppd_henkel_act]

     from [HBCAMS_MSCRM].[dbo].[cdc_ForcastMutBase] mut with (nolock)

     join [HBCAMS_MSCRM].[dbo].[cdc_PromoBase] promo with (nolock)
       on mut.cdc_promo=promo.cdc_promoid
      and promo.statecode=0
      and promo.cdc_type in (754460000,754460001,754460002)

     join [HBCAMS_MSCRM].[dbo].[Account] accnt with (nolock)
       on mut.cdc_EP=accnt.AccountId
      and accnt.cdc_Type=754460000

	 LEFT JOIN [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)
  ON accnt.[new_division_EP] = division.[AttributeValue]
 AND division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'

     left join [HBCAMS_IntegrationDB].[dbo].[Mechanics] mech with (nolock)
       on promo.[cdc_mechanics] = mech.[MechanicsId]

     where mut.[statecode] = 0
       and division.[AttributeValue] <> 100000006
       and cast(mut.[cdc_Datum] as date) between @sDate and @eDate
       and mut.[cdc_Type] = 754460022 --|Fact Promo

       --/*Фильтры для интерфейса*/
       and accnt.[Name] in (@ep)
       and (accnt.[ParentAccountIdName] in (@distributor) or accnt.[ParentAccountIdName] is null)
       and division.[Value] in (@region)

     group by
       year(mut.[cdc_Datum]),
       month(mut.[cdc_Datum]),
       division.[Value],
       accnt.[ParentAccountIdName],
       accnt.[Name],
       accnt.[OwnerIdName],
       promo.[cdc_offpercentqty],
       promo.[cdc_name],
       promo.[cdc_number],
       mech.[MechanicsName],
       promo.[cdc_is_leaflet],
       promo.[cdc_is_pallet],
       promo.[cdc_onshelfform],
       promo.[cdc_onshelfto],
       promo.[cdc_deliveryfrom],
       promo.[cdc_deliveryto],
       promo.[cdc_extraKAM],
       promo.[cdc_Extracomment],
       promo.[cdc_OFFKAM],
       promo.[cdc_OFFcomment],
       promo.[cdc_l17abs],
       promo.[cdc_L17KAM],
       promo.[cdc_L17comment]
    ) as source
    on target.[year]                                = source.[year]
   and target.[month]                               = source.[month]
   and isnull(target.[region],'unknown')            = isnull(source.[region],'unknown')
   and isnull(target.[distributor],'unknown')       = isnull(source.[distributor],'unknown')
   and isnull(target.[client],'unknown')            = isnull(source.[client],'unknown')
   and isnull(target.[responsibles],'unknown')      = isnull(source.[responsibles],'unknown')
   and isnull(target.[promoname],'unknown')         = isnull(source.[promoname],'unknown')
   and isnull(target.[promo_number],000000)      = isnull(source.[promo_number],000000)
   and isnull(target.[bmc_autosplit],0)             = isnull(source.[bmc_autosplit],0)
   and isnull(target.[mechanics],'unknown')         = isnull(source.[mechanics],'unknown')
   and isnull(target.[leaflet],0)                   = isnull(source.[leaflet],0)
   and isnull(target.[pallette],0)                  = isnull(source.[pallette],0)
   and isnull(target.[shelf_start],'19000101')      = isnull(source.[shelf_start],'19000101')
   and isnull(target.[shelf_end],'19000101')        = isnull(source.[shelf_end],'19000101')
   and isnull(target.[shipment_start],'19000101')   = isnull(source.[shipment_start],'19000101')
   and isnull(target.[shipment_end],'19000101')     = isnull(source.[shipment_end],'19000101')

when matched then
    update set target.[con_act]              = source.[con_act]
              ,target.[ges_act]              = source.[ges_act]
              ,target.[rp_act]               = source.[rp_act]
              ,target.[nes_act]              = source.[nes_act]
              ,target.[ts_act]               = source.[ts_act]
              ,target.[off_extra_abs_act]    = source.[off_extra_abs_act]
              ,target.[off_extra_dsc_act]    = source.[off_extra_dsc_act]
              ,target.[off_extra_total_act]  = source.[off_extra_total_act]
              ,target.[bmc_abs_act]          = source.[bmc_abs_act]
              ,target.[bmc_dsc_act]          = source.[bmc_dsc_act]
              ,target.[bmc_total_act]        = source.[bmc_total_act]
              ,target.[distr_dsc_act]        = source.[distr_dsc_act]
              ,target.[ppd_henkel_act]       = source.[ppd_henkel_act]
              ,target.[l17_act]              = source.[l17_act]

when not matched then
    insert ([year],[month],[region],[distributor],[client],[responsibles],[promoname],[promo_number],[bmc_autosplit],[mechanics],[leaflet],[pallette],[shelf_start],[shelf_end],[shipment_start],[shipment_end],
            [con_act],[ges_act],[rp_act],[nes_act],[ts_act],[off_extra_abs_act],[off_extra_dsc_act],[off_extra_total_act],[off_extra_kam_perc],[off_extra_kam_comment],
            [bmc_abs_act],[bmc_dsc_act],[bmc_total_act],[bmc_kam_perc],[bmc_kam_comment],[l17_fс],[l17_kam_perc],[l17_kam_comment],[distr_dsc_act],[ppd_henkel_act])

    values ([year],[month],[region],[distributor],[client],[responsibles],[promoname],[promo_number],[bmc_autosplit],[mechanics],[leaflet],[pallette],[shelf_start],[shelf_end],[shipment_start],[shipment_end],
            [con_act],[ges_act],[rp_act],[nes_act],[ts_act],[off_extra_abs_act],[off_extra_dsc_act],[off_extra_total_act],[off_extra_kam_perc],[off_extra_kam_comment],
            [bmc_abs_act],[bmc_dsc_act],[bmc_total_act],[bmc_kam_perc],[bmc_kam_comment],[l17_act],[l17_kam_perc],[l17_kam_comment],[distr_dsc_act],[ppd_henkel_act]);


select * from @merge_target

option (recompile)


-- Filters
-- EP
SELECT DISTINCT name
FROM            FilteredAccount

-- Distributor
select distinct
  ParentAccountIdName as [distributor]
from [HBCAMS_MSCRM].[dbo].[FilteredAccount]
where statecode = 0

-- Region
SELECT	division.[Value] as region
FROM [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)

WHERE division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'
 AND division.[AttributeValue] <> 100000006

-- ReportDate
exec [HBCAMS_MSCRM].[dbo].[ams_date_generator]
