USE [hbcams_integrationdb]

DECLARE @sdate DATE = '20200101'
DECLARE @rdate DATE = DATEADD(MM, DATEDIFF(MM, 0, GETDATE()), 0)
DECLARE @edate DATE = eomonth(getdate())
DECLARE @sql VARCHAR(1000);

SET @sql = CONCAT('
                   select
                     convert(date,convert(varchar,concat([date],''01''))) as [date],
                     [AMSid]                                            as [distributor_id],
                     [EAN]                                              as [ean],
                     sum([SellinPPD])                                   as [ppd],
                     sum([SellinPXD])                                   as [pxd]
                   from [Mobile_Schwarzkopf_HO_Plus].[dbo].[AMS2_Stock_Final]
                   where convert(date,convert(varchar,concat([date],''01''))) between', '''', @sdate, '''',
                  'and dateadd(day, -1,', '''', @rdate, '''', ')
                   group by
                     convert(date,convert(varchar,concat([date],''01''))),
                     [AMSid],
                     [EAN]
                   having sum([SellinPPD]) <> 0
				       OR sum([SellinPXD]) <> 0
                  ')

IF OBJECT_ID('tempdb..#ppdpxd_data_on_ep') IS NOT NULL DROP TABLE [#ppdpxd_data_on_ep]
CREATE TABLE [#ppdpxd_data_on_ep] (
    [date]       DATE           NOT NULL,
    [distributor_id] VARCHAR(50)    NOT NULL,
    [ean]        VARCHAR(20)    NOT NULL,
    [ppd]        DECIMAL(19, 9) NOT NULL,
    [pxd]        DECIMAL(19, 9) NOT NULL,
                                  );

INSERT INTO [#ppdpxd_data_on_ep] EXEC (@sql) AT [FTPHBCHO.CDC.RU];

WITH [data] AS (
               SELECT YEAR([date])            AS [year]
                    , MONTH([date])           AS [month]
                    , 'Факт'                  AS [data_type]
                    , 'Промо'                 AS [promo/regular]
                    , [division_name]         AS [division]
                    , [distributor_name]      AS [distributor]
                    , [prod].[cdc_brandname]  AS [brand]
                    , SUM([ppd])              AS [ppd sell-in, руб]
                    , SUM([pxd])              AS [pxd sell-in, руб]
                    , 0                       AS [henkel ppd sell-through, руб]
                    , 0                       AS [henkel pxd sell-through, руб]
                    , 0                       AS [distributor ppd sell-through, руб]

               FROM [#ppdpxd_data_on_ep] AS [ppdpxd]

               JOIN [hbcams_integrationdb].[bi].[distributor] AS [distr] WITH (NOLOCK)
                    ON [ppdpxd].[distributor_id] = [distr].[distributor_id]

               JOIN [hbcams_mscrm].[dbo].[product] AS [prod] WITH (NOLOCK)
                    ON [ppdpxd].[ean] collate Cyrillic_General_CI_AS = [prod].[name]

               WHERE [ppdpxd].[ppd] > 0 OR [ppdpxd].[pxd] > 0

               GROUP BY YEAR([date]), MONTH([date]), [distr].[division_name], [distributor_name], [prod].[cdc_brandname]

               UNION ALL

               SELECT year([mut].[cdc_datum])                                                AS [year]
                    , month([mut].[cdc_datum])                                               AS [month]
                    , 'Факт'                                                                 AS [data_type]
                    , CASE WHEN [mut].[cdc_type] = 754460022 THEN 'Промо' ELSE 'Регуляр' END AS [promo/regular]
                    , [acc].[division_name]                                                AS [division]
                    , [acc].[distributor_name]                                             AS [distributor]
                    , [prod].[cdc_brandname]                                                 AS [brand]
                    , 0                                                                      AS [ppd sell-in, руб]
                    , 0                                                                      AS [pxd sell-in, руб]
                    , sum([mut].[cdc_ppd])                                                   AS [henkel ppd sell-through, руб]
                    , sum([mut].[cdc_pxd])                                                   AS [henkel pxd sell-through, руб]
                    , sum([mut].[cdc_ppd_distr])                                             AS [distributor ppd sell-through, руб]

               FROM [hbcams_mscrm].[dbo].[cdc_forcastmut] [mut] WITH (NOLOCK)

               JOIN [HBCAMS_IntegrationDB].[bi].[Account] [acc] WITH (NOLOCK) ON [mut].[cdc_ep] = [acc].[account_id]

               JOIN [hbcams_mscrm].[dbo].[product] [prod] WITH (NOLOCK) ON [mut].[cdc_ean] = [prod].[productid]

               WHERE [mut].[statecode] = 0
                 AND [mut].[cdc_datum] >= @sdate
                 AND [mut].[cdc_datum] < @rdate
                 AND [mut].[cdc_type] IN (754460020, 754460022, 754460024) /*Fact Reg, Fact Promo*/

               GROUP BY year([mut].[cdc_datum])
                      , month([mut].[cdc_datum])
                      , CASE WHEN [mut].[cdc_type] = 754460022 THEN 'Промо' ELSE 'Регуляр' END
                      , [acc].[division_name]
                      , [acc].[distributor_name]
                      , [prod].[cdc_brandname]

               UNION ALL

               SELECT year([mut].[cdc_datum])                                                   AS [year]
                    , month([mut].[cdc_datum])                                                  AS [month]
                    , 'Прогноз'                                                                 AS [data_type]
                    , CASE WHEN [mut].[cdc_type] = 754460012 THEN 'Промо' ELSE 'Регуляр' END    AS [promo/regular]
                    , [acc].[division_name]                                                     AS [division]
                    , [acc].[distributor_name]                                                  AS [distributor]
                    , [prod].[cdc_brandname]                                                    AS [brand]
                    , 0                                                                         AS [ppd sell-in, руб]
                    , 0                                                                         AS [pxd sell-in, руб]
                    , sum([mut].[cdc_ppd])                                                      AS [henkel ppd sell-through, руб]
                    , sum([mut].[cdc_pxd])                                                      AS [henkel pxd sell-through, руб]
                    , sum([mut].[cdc_ppd_distr])                                                AS [distributor ppd sell-through, руб]

               FROM [hbcams_mscrm].[dbo].[cdc_forcastmut] [mut] WITH (NOLOCK)

               JOIN [HBCAMS_IntegrationDB].[bi].[Account] [acc] WITH (NOLOCK) ON [mut].[cdc_ep] = [acc].[account_id]

               JOIN [hbcams_mscrm].[dbo].[product] [prod] WITH (NOLOCK) ON [mut].[cdc_ean] = [prod].[productid]

               WHERE [mut].[statecode] = 0
                 AND [mut].[cdc_datum] >= @rdate
                 AND [mut].[cdc_datum] < @edate
                 AND [mut].[cdc_type] IN (754460010, 754460011, 754460012) /*Baseline, BaselineCaniball, Promo*/

               GROUP BY year([mut].[cdc_datum])
                      , month([mut].[cdc_datum])
                      , CASE WHEN [mut].[cdc_type] = 754460012 THEN 'Промо' ELSE 'Регуляр' END
                      , [acc].[division_name]
                      , [acc].[distributor_name]
                      , [prod].[cdc_brandname]
               )

SELECT [year]
     , [month]
     , [data_type]
     , [promo/regular]
     , [division]
     , [distributor]
     , [brand]
     , SUM([ppd sell-in, руб])                  AS [ppd sell-in, руб]
     , SUM([pxd sell-in, руб])                  AS [pxd sell-in, руб]
     , SUM([henkel ppd sell-through, руб])      AS [henkel ppd sell-through, руб]
     , SUM([henkel pxd sell-through, руб])      AS [henkel pxd sell-through, руб]
     , SUM([distributor ppd sell-through, руб]) AS [distributor ppd sell-through, руб]
FROM [data]

WHERE [division] <> 'NKA'
  AND [division] IN (@division)
  AND [distributor] IN (@distributor)
  --AND [distributor] LIKE ('%Zimus%')


GROUP BY [year], [month], [data_type], [promo/regular], [division], [distributor], [brand]

OPTION (RECOMPILE)

-- Filters
-- Distrib
select distinct
  ISNULL(acc.[ParentAccountIdName], acc.[Name]) as [Distributor]
from [HBCAMS_MSCRM].[dbo].[FilteredAccount] acc
where cdc_type = 754460000
order by [Distributor]

-- Division
SELECT division.[Value]

FROM [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)

WHERE division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'
