USE [HBCAMS_MSCRM]

declare @ams_analyse_baseline as table
                                 (
                                     [Year]                                     int          not null,
                                     [Month]                                    int          not null,
                                     [Client]                                   varchar(150) not null,
                                     [Brand]                                    varchar(150) not null,
                                     [EAN]                                      varchar(50)  not null,
                                     [Assortment]                               varchar(150) not null,
                                     [Baseeline_per_day_con]                    real         null,
                                     [Participation_in_promo_days]              real         null,
                                     [Participation_in_promo_perc_of_a_month]   real         null,
                                     [Number_of_Stores]                         real         null,
                                     [KAM's_baseline_correction_con_in_a_month] real         null
                                 )

insert into @ams_analyse_baseline
    exec [rep_ams_analyse_baseline] @reportdat
select
    [Year]
  , [Month]
  , [Client]
  , [Brand]
  , [EAN]
  , [Assortment]
  , [Baseeline_per_day_con]
  , [Participation_in_promo_days]
  , [Participation_in_promo_perc_of_a_month]
  , [Number_of_Stores]
  , [KAM's_baseline_correction_con_in_a_month]
from @ams_analyse_baseline
where [Client] in (@ep)
  and [Brand] in (@brand)


-- Фильтры
-- ЕП
SELECT DISTINCT
    name
FROM FilteredAccount

-- ReportDate
exec [HBCAMS_IntegrationDB].[dbo].[date_generator]

-- Brand
SELECT [cdc_name] AS [brand]
FROM [HBCAMS_MSCRM].[dbo].[cdc_brandBase]