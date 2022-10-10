USE [hbcams_integrationdb]

DECLARE
    @sdate DATE,
    @edate DATE,
    @rdate DATE,
    @sql VARCHAR(MAX)
--@distributor varchar(100)= 'Ulan-UdeBaris'

SET @sdate = '20190101'
SET @rdate = dateadd(DAY, 1 - day(getdate()), getdate())
SET @edate = eomonth(@rdate)

/*Интеграция ppd_sellin*/
IF object_id('tempdb..#factpromo') IS NOT NULL DROP TABLE [#factpromo]
CREATE TABLE [#factpromo] (
    [date]      DATE         NOT NULL,
    [distribid] VARCHAR(250) NOT NULL,
    [ean]       VARCHAR(13)  NOT NULL,
    [ppd]       REAL         NOT NULL
                          )
SET @sql = concat('
                   select
                     convert(date,convert(varchar,concat([date],''01''))) as [date],
                     [AMSid]                                            as [distributorid],
                     [EAN]                                              as [ean],
                     sum([SellinPPD])                                   as [ppd]
                   from [Mobile_Schwarzkopf_HO_Plus].[dbo].[AMS2_Stock_Final]
                   where convert(date,convert(varchar,concat([date],''01''))) between', '''', @sdate, '''',
                  'and dateadd(day, -1,', '''', @rdate, '''', ')
                   group by
                     convert(date,convert(varchar,concat([date],''01''))),
                     [AMSid],
                     [EAN]
                   having sum([SellinPPD]) <> 0
                  ')

INSERT INTO [#factpromo]
    EXEC (@sql) AT [ftphbcho.cdc.ru]

IF object_id('tempdb..#sellin_ppd') IS NOT NULL DROP TABLE [#sellin_ppd]
SELECT [date]             AS [date]
     , [distribid]        AS [distribid]
     , [brand].[cdc_name] AS [brand]
     , sum([ppd])         AS [ppd]
INTO [#sellin_ppd]
FROM [#factpromo] [fp]
JOIN [hbcams_mscrm].[dbo].[productbase] [prod] ON [fp].[ean] = [prod].[name] COLLATE [cyrillic_general_ci_as]
JOIN [hbcams_mscrm].[dbo].[cdc_brandbase] [brand] ON [prod].[cdc_brand] = [brand].[cdc_brandid]
GROUP BY [date]
       , [distribid]
       , [brand].[cdc_name]

/*Отфильтровываем данные из таблицы Прогноз-Факт в зависимости от прав доступа пользователя, периода и типу данных (ФАКТ ПРОМО)*/
IF object_id('tempdb..#promobase') IS NOT NULL DROP TABLE [#promobase]
CREATE TABLE [#promobase] (
    [date]             DATE         NOT NULL,
    [data_type]        VARCHAR(10)  NOT NULL,
    [promo/regular]    VARCHAR(10)  NOT NULL,
    [division]         VARCHAR(50)  NOT NULL,
    [distribid]        VARCHAR(50)  NOT NULL,
    [distributor]      VARCHAR(250) NOT NULL,
    [cdc_ep]           VARCHAR(50)  NOT NULL,
    [cdc_promo]        VARCHAR(50)  NULL,
    [brand]            VARCHAR(50)  NOT NULL,
    [cdc_ean]          VARCHAR(50)  NOT NULL,
    [ean]              VARCHAR(13)  NOT NULL,
    [cdc_ges]          REAL         NULL,
    [cdc_ppd]          REAL         NULL,
    [cdc_oncch]        REAL         NULL,
    [ppd_discount]     REAL         NULL,
    [ppd_joint_actual] REAL         NULL
                          )

INSERT INTO [#promobase]
SELECT DISTINCT
       dateadd(DAY, 1 - day([mut].[cdc_datum]), [mut].[cdc_datum])    AS [date]
     , CASE [mut].[cdc_type]
           WHEN 754460012 THEN 'Прогноз'
                          ELSE 'Факт'
       END                                                            AS [data_type]
     , CASE
           WHEN [mut].[cdc_type] IN (754460012, 754460022) THEN 'Промо'
                                                           ELSE 'Регуляр'
       END                                                            AS [promo/regular]
     , CASE [apo].[apo partner]
           WHEN 'Belorussia' THEN 'North-West'
                             ELSE [apo].[apo partner]
       END                                                            AS [division]
     , [acc].[parentaccountid]                                        AS [distribid]
     , [acc].[parentaccountidname]                                    AS [distributor]
     , [acc].[accountid]                                              AS [cdc_ep]
     , [mut].[cdc_promo]                                              AS [cdc_promo]
     , [brand].[cdc_name]                                             AS [brand]
     , [mut].[cdc_ean]                                                AS [cdc_ean]
     , [prod].[name]                                                  AS [ean]
     , (isnull(sum([mut].[cdc_ges]), 0) * ([apo].[rate] / 100))       AS [cdc_ges]
     , (isnull(sum([mut].[cdc_ppd]), 0) * ([apo].[rate] / 100))       AS [cdc_ppd]
     , (isnull(sum([mut].[cdc_oncch]), 0) * ([apo].[rate] / 100))     AS [cdc_oncch]
     , (isnull(sum([pitems].[cdc_ppdpxd]), 0) * ([apo].[rate] / 100)) AS [ppd_discount]
     , (isnull(sum([mut].[cdc_ppd]), 0) * ([apo].[rate] / 100))       AS [ppd_joint_actual]

FROM [hbcams_mscrm].[dbo].[cdc_forcastmutbase] [mut]

JOIN [hbcams_mscrm].[dbo].[account] [acc] ON [mut].[cdc_ep] = [acc].[accountid]
    AND [acc].[parentaccountid] IS NOT NULL
    AND [acc].[statecode] = 0

JOIN [hbcams_integrationdb].[dbo].[apopartner] [apo]
     ON [acc].[accountid] = [apo].[accountid] COLLATE [cyrillic_general_ci_as]
         AND [apo].[business type] = 'DB'

JOIN [hbcams_mscrm].[dbo].[productbase] [prod] ON [mut].[cdc_ean] = [prod].[productid]

JOIN [hbcams_mscrm].[dbo].[cdc_brandbase] [brand] ON [prod].[cdc_brand] = [brand].[cdc_brandid]

LEFT JOIN [hbcams_mscrm].[dbo].[cdc_promobase] [promo] ON [mut].[cdc_ep] = [promo].[cdc_ep]
    AND [mut].[cdc_promo] = [promo].[cdc_promoid]
    AND [promo].[statecode] = 0

LEFT JOIN [hbcams_mscrm].[dbo].[cdc_promoitemsbase] [pitems] ON [promo].[cdc_promoid] = [pitems].[cdc_promo]
    AND [mut].[cdc_ean] = [pitems].[cdc_sku]
    AND [pitems].[statecode] = 0

WHERE [mut].[statecode] = 0 --|Активные записи
  AND [mut].[cdc_datum] BETWEEN @sdate AND eomonth(@rdate)
  AND [mut].[cdc_type] IN (
                           754460012, --|Promo
                           754460020, --|Fact Reg
                           754460022, --|Fact Promo
                           754460024 --|Fact AP
    )
  AND (CASE [apo].[apo partner] WHEN 'Belorussia' THEN 'North-West' ELSE [apo].[apo partner] END) IN (@division)
  AND [acc].[parentaccountidname] IN (@distributor)

GROUP BY dateadd(DAY, 1 - day([mut].[cdc_datum]), [mut].[cdc_datum])
       , CASE [mut].[cdc_type]
             WHEN 754460012 THEN 'Прогноз'
                            ELSE 'Факт'
         END
       , CASE
             WHEN [mut].[cdc_type] IN (754460012, 754460022) THEN 'Промо'
                                                             ELSE 'Регуляр'
         END
       , CASE [apo].[apo partner]
             WHEN 'Belorussia' THEN 'North-West'
                               ELSE [apo].[apo partner]
         END
       , [acc].[parentaccountid]
       , [acc].[parentaccountidname]
       , [acc].[accountid]
       , [mut].[cdc_promo]
       , [brand].[cdc_name]
       , [mut].[cdc_ean]
       , [prod].[name]
       , [apo].[rate]

UPDATE [#promobase]
SET [cdc_ges] = NULL
WHERE [cdc_ges] = 0
--update #promobase set [cdc_ppd] = null where [cdc_ppd] = 0
--update #promobase set [cdc_oncch] = null where [cdc_oncch] = 0
--update #promobase set [PPD_discount] = null where [PPD_discount] = 0
--update #promobase set [ppd_joint_actual] = null where [ppd_joint_actual] = 0

IF object_id('tempdb..#factpromo2') IS NOT NULL DROP TABLE [#factpromo2]
SELECT [pb].[date]          AS [date]
     , [pb].[data_type]     AS [data_type]
     , [pb].[promo/regular] AS [promo/regular]
     , [pb].[division]      AS [division]
     , [pb].[distribid]     AS [distribid]
     , [pb].[distributor]   AS [distributor]
     , [pb].[brand]         AS [brand]
     , sum(
            (isnull([pb].[cdc_ges], 0) * (1 - (isnull([pb].[cdc_oncch], 0) / isnull([pb].[cdc_ges], 1))))
            *
            (isnull([pb].[ppd_discount], 0) / 100)
    )                       AS [henkel ppd sell-through, руб]
     , sum(isnull([pb].[cdc_ppd], 0)
    -
           (
                   (isnull([pb].[cdc_ges], 0) * (1 - (isnull([pb].[cdc_oncch], 0) / isnull([pb].[cdc_ges], 1))))
                   *
                   (isnull([pb].[ppd_discount], 0) / 100)
               )
    )                       AS [distributor ppd sell-through, руб]
INTO [#factpromo2]
FROM [#promobase] [pb]

WHERE [pb].[data_type] = 'Факт'
  AND [pb].[promo/regular] = 'Промо'
  AND [pb].[date] BETWEEN @sdate AND dateadd(DAY, -1, @rdate)

GROUP BY [pb].[date]
       , [pb].[data_type]
       , [pb].[promo/regular]
       , [pb].[division]
       , [pb].[distribid]
       , [pb].[distributor]
       , [pb].[brand]

IF object_id('tempdb..#apo') IS NOT NULL DROP TABLE [#apo]
SELECT DISTINCT
       [acc].[parentaccountid]     AS [distribid]
     , [acc].[parentaccountidname] AS [distribname]
     , CASE [apo].[apo partner]
           WHEN 'Belorussia' THEN 'North-West'
                             ELSE [apo].[apo partner]
       END                         AS [division]
     , [apo].[rate]                AS [rate]
INTO [#apo]
FROM [hbcams_mscrm].[dbo].[account] [acc]
JOIN [hbcams_integrationdb].[dbo].[apopartner] [apo] ON [acc].[accountid] = [apo].[accountid]
    AND [apo].[business type] = 'DB'
WHERE [acc].[parentaccountid] IS NOT NULL
  AND [acc].[statecode] = 0
  AND (CASE [apo].[apo partner] WHEN 'Belorussia' THEN 'North-West' ELSE [apo].[apo partner] END) IN (@division)
  AND [acc].[parentaccountidname] IN (@distributor)

SELECT year([fp].[date])                                   AS [year]
     , month([fp].[date])                                  AS [month]
     , [fp].[data_type]                                    AS [data_type]
     , [fp].[promo/regular]                                AS [promo/regular]
     , [fp].[division]                                     AS [division]
     , [fp].[distributor]                                  AS [distributor]
     , [fp].[brand]                                        AS [brand]
     , sum(isnull([sipd].[ppd], 0) * ([apo].[rate] / 100)) AS [ppd sell-in, руб]
     , isnull([fp].[henkel ppd sell-through, руб], 0)      AS [henkel ppd sell-through, руб]
     , isnull([fp].[distributor ppd sell-through, руб], 0) AS [distributor ppd sell-through, руб]
FROM [#factpromo2] [fp]
JOIN [#apo] [apo] ON [fp].[distribid] = [apo].[distribid]

LEFT JOIN [#sellin_ppd] [sipd] ON [fp].[date] = [sipd].[date]
    AND [fp].[distribid] = [sipd].[distribid] COLLATE [cyrillic_general_ci_as]
    AND [fp].[brand] = [sipd].[brand] COLLATE [cyrillic_general_ci_as]
GROUP BY year([fp].[date])
       , month([fp].[date])
       , [fp].[data_type]
       , [fp].[promo/regular]
       , [fp].[division]
       , [fp].[distributor]
       , [fp].[brand]
       , [apo].[rate]
       , isnull([fp].[henkel ppd sell-through, руб], 0)
       , isnull([fp].[distributor ppd sell-through, руб], 0)

UNION ALL

SELECT year([sipd].[date])                                  AS [year]
     , month([sipd].[date])                                 AS [month]
     , 'Факт'                                               AS [data_type]
     , 'Промо'                                              AS [promo/regular]
     , [apo].[division] COLLATE [cyrillic_general_ci_as]    AS [division]
     , [apo].[distribname] COLLATE [cyrillic_general_ci_as] AS [distributor]
     , [sipd].[brand] COLLATE [cyrillic_general_ci_as]      AS [brand]
     , sum(isnull([sipd].[ppd], 0) * ([apo].[rate] / 100))  AS [ppd sell-in, руб]
     , isnull([fp].[henkel ppd sell-through, руб], 0)       AS [henkel ppd sell-through, руб]
     , isnull([fp].[distributor ppd sell-through, руб], 0)  AS [distributor ppd sell-through, руб]
FROM [#sellin_ppd] [sipd]

JOIN [#apo] [apo] ON [sipd].[distribid] = [apo].[distribid]

LEFT JOIN [#factpromo2] [fp] ON [sipd].[date] = [fp].[date]
    AND [sipd].[distribid] = [fp].[distribid] COLLATE [cyrillic_general_ci_as]
    AND [sipd].[brand] = [fp].[brand] COLLATE [cyrillic_general_ci_as]
WHERE [fp].[brand] IS NULL
GROUP BY year([sipd].[date])
       , month([sipd].[date])
       , [apo].[division]
       , [apo].[distribname]
       , [sipd].[brand]
       , [apo].[rate]
       , isnull([fp].[henkel ppd sell-through, руб], 0)
       , isnull([fp].[distributor ppd sell-through, руб], 0)

UNION ALL

/*Факт регуляр*/
SELECT year([pb].[date])              AS [year]
     , month([pb].[date])             AS [month]
     , [pb].[data_type]               AS [data_type]
     , [pb].[promo/regular]           AS [promo/regular]
     , [pb].[division]                AS [division]
     , [pb].[distributor]             AS [distributor]
     , [pb].[brand]                   AS [brand]
     , convert(REAL, 0)               AS [ppd sell-in, руб]
     , convert(REAL, 0)               AS [henkel ppd sell-through, руб]
     , sum(isnull([pb].[cdc_ppd], 0)) AS [distributor ppd sell-through, руб]

FROM [#promobase] [pb]

WHERE [pb].[data_type] = 'Факт'
  AND [pb].[promo/regular] = 'Регуляр'
  AND [pb].[date] BETWEEN @sdate AND dateadd(DAY, -1, @rdate)

GROUP BY year([pb].[date])
       , month([pb].[date])
       , [pb].[data_type]
       , [pb].[promo/regular]
       , [pb].[division]
       , [pb].[distributor]
       , [pb].[brand]

UNION ALL

/*Прогноз промо*/
SELECT year([pb].[date])              AS [year]
     , month([pb].[date])             AS [month]
     , [pb].[data_type]               AS [data_type]
     , [pb].[promo/regular]           AS [promo/regular]
     , [pb].[division]                AS [division]
     , [pb].[distributor]             AS [distributor]
     , [pb].[brand]                   AS [brand]
     , convert(REAL, 0)               AS [ppd sell-in, руб]
     , sum(isnull([pb].[cdc_ppd], 0)) AS [henkel ppd sell-through, руб]
     , convert(REAL, 0)               AS [distributor ppd sell-through, руб]
FROM [#promobase] [pb]

WHERE [pb].[data_type] = 'Прогноз'
  AND [pb].[promo/regular] = 'Промо'
  AND [pb].[date] BETWEEN @rdate AND @edate

GROUP BY year([pb].[date])
       , month([pb].[date])
       , [pb].[data_type]
       , [pb].[promo/regular]
       , [pb].[division]
       , [pb].[distributor]
       , [pb].[brand]

OPTION (RECOMPILE)