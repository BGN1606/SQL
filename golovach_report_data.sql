SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
GO

USE [HBCAMS_IntegrationDB]
GO

DECLARE @curyear INT = 2021

BEGIN TRANSACTION
SELECT
    YEAR([delivery_date])  AS [year],
    MONTH([delivery_date]) AS [month],
    [data_type_lvl0]       AS [data_type],
    [account_name]         AS [account_name],
    [brand_name]           AS [brand_name],
    SUM([bs_con_fc])       AS [bs_con_fc]
FROM [HBCAMS_IntegrationDB].[bi].[ClosePeriodFreeze]
WHERE YEAR([delivery_date]) = @curyear - 1
GROUP BY YEAR([delivery_date]),
         MONTH([delivery_date]),
         [data_type_lvl0],
         [account_name],
         [brand_name]
HAVING SUM([bs_con_fc]) <> 0

UNION ALL

SELECT
    YEAR([delivery_date])  AS [year],
    MONTH([delivery_date]) AS [month],
    [data_type_lvl0]       AS [data_type],
    [account_name]         AS [account_name],
    [brand_name]           AS [brand_name],
    SUM([bs_con_fc])       AS [bs_con_fc]
FROM [HBCAMS_IntegrationDB].[bi].[OpenPeriodFreeze]
WHERE [datafreeze_type] = 'Updatable Slice'
  AND YEAR([delivery_date]) = @curyear
GROUP BY YEAR([delivery_date]),
         MONTH([delivery_date]),
         [data_type_lvl0],
         [account_name],
         [brand_name]
HAVING SUM([bs_con_fc]) <> 0;
