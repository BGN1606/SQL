USE [IntegrationDB]
GO

/****** Object:  StoredProcedure [dbo].[DM_Products]    Script Date: 17.06.2020 17:30:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[DM_Products]

as

begin
IF object_id('tempdb..#dms_items') IS NOT NULL
	DROP TABLE #dms_items

SELECT *
INTO #dms_items
FROM openquery([FTPHBCHO.CDC.RU], '
	select [name], [ean], [category_id], [category_name], [brand_id], [brand_name]
	from [Mobile_Schwarzkopf_HO_Plus].[dbo].[bi_product]
	');

WITH Brand
AS (
	SELECT DISTINCT brand_name
		,brand_id
	FROM #dms_items
	)
MERGE [django_test].[dbo].[mdm_productbrand] AS T_Base
USING [Brand] AS T_Source
	ON (T_Base.sys_key = T_Source.brand_id)
WHEN NOT MATCHED
	THEN
		INSERT (
			name
			,created_at
			,updated_at
			,sys_key
			)
		VALUES (
			T_Source.brand_name
			,getdate()
			,getdate()
			,T_Source.brand_id
			);;

WITH Category
AS (
	SELECT DISTINCT category_name
		,category_id
	FROM #dms_items
	)
MERGE [django_test].[dbo].[mdm_productcategory] AS T_Base
USING [Category] AS T_Source
	ON (T_Base.sys_key = T_Source.category_id)
WHEN NOT MATCHED
	THEN
		INSERT (
			name
			,created_at
			,updated_at
			,sys_key
			)
		VALUES (
			T_Source.category_name
			,getdate()
			,getdate()
			,T_Source.category_id
			);;

WITH Product
AS (
	SELECT items.[name]
		,items.[ean]
		,category.[id] AS [category]
		,brand.[id] AS [brand]
	FROM #dms_items items
	INNER JOIN [django_test].[dbo].[mdm_productcategory] AS category
		ON items.[category_id] = category.[sys_key]
	INNER JOIN [django_test].[dbo].[mdm_productbrand] AS brand
		ON items.[brand_id] = brand.[sys_key]
	)
MERGE [django_test].[dbo].[mdm_product] AS T_Base
USING Product AS T_Source
	ON (T_Base.ean = T_Source.ean)
WHEN NOT MATCHED
	THEN
		INSERT (
			name
			,created_at
			,updated_at
			,ean
			,brand_id
			,category_id
			,manufacturer_id
			)
		VALUES (
			T_Source.name
			,getdate()
			,getdate()
			,T_Source.ean
			,T_Source.brand
			,T_Source.category
			,1
			);
end
GO


