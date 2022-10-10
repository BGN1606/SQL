--DECLARE
--	 @sdate DATE = '20200101'
--	,@edate DATE = '20211231'
--	,@cutdate DATE = '20201231'
--	,@region VARCHAR(50) = 'Center';

WITH region AS (
	SELECT DISTINCT
		acc.[division_name]
	FROM [HBCAMS_IntegrationDB].[bi].[Account] acc WITH (NOLOCK)
	WHERE acc.[division_name] IS NOT NULL
), 
	region_filter AS (
	SELECT
		CASE WHEN @region = 'ho'	THEN (SELECT * FROM region)
			 WHEN @region = 'LKA'	THEN (SELECT * FROM region WHERE [division_name] IN ('LKA', 'TOP DB'))
		ELSE (SELECT * FROM region WHERE [division_name] = @region)
		END	AS [region]

)

WHERE ((mut.[delivery_date] BETWEEN @cutdate AND @edate AND mut.[data_type_lvl0] = 'Baseline') OR
	   (mut.[delivery_date] BETWEEN @sdate AND DATEADD(DAY, -1, @cutdate)	AND mut.[data_type_lvl0] = 'Fact'))
  AND acc.[division_name] IN (SELECT * FROM region_filter)
