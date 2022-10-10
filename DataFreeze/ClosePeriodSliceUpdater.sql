USE [HBCAMS_IntegrationDB]
GO

CREATE PROCEDURE [bi].[ClosePeriodSliceUpdater] @sdate date, @edate date
AS
BEGIN
-- Объявление переменных
--     DECLARE
--         @sdate VARCHAR(10) = NULL
--         , @edate VARCHAR(10) = NULL
--         , @query VARCHAR(1500) = NULL
--         , @sql VARCHAR(2000) = NULL;

-- Присвоение переменных
--     SET @sdate = '20201101';
--     SET @edate = '20201130';

-- Удаление данных за выбранный период
    DELETE [bi].[ClosePeriodFreeze] WHERE [delivery_date] BETWEEN @sdate AND @edate

-- Заполнение таблицы для хранения данных в закрытом периоде данными из витрины данных dbo.DataFreezeView
    INSERT INTO [bi].[ClosePeriodFreeze]
    SELECT * FROM [HBCAMS_IntegrationDB].[dbo].[DataFreezeView] WITH (NOLOCK)
    WHERE [delivery_date] BETWEEN @sdate AND @edate

-- Перестроение индексов
    ALTER INDEX [ClosePeriodFreeze_delivery_date_index] ON [bi].[ClosePeriodFreeze] REORGANIZE  WITH ( LOB_COMPACTION = ON )

--     ALTER INDEX [ClosedPeriodFreeze_delivery_date_index] ON [bi].[ClosePeriodFreeze] REBUILD PARTITION = ALL
--         WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)
END