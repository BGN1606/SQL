USE [IntegrationDB]
GO

/****** Object:  StoredProcedure [dbo].[DM_Client]    Script Date: 02.07.2020 16:28:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[DM_Client] AS
BEGIN

--сдюкъел бпелеммсч рюакхжс еякх нмю ясыеярбсер
IF OBJECT_ID('tempdb..#Client') IS NOT NULL DROP TABLE #Client;

--йнохпсел дюммше хг цнрнбни бэчух бн бпелеммсч рюакхжс
SELECT * INTO #Client FROM OPENQUERY ([FTPHBCHO.CDC.RU], '
	SELECT
	  [OwnerDistID],
	  [id],
	  [Client],
	  [Address],
	  [Street],
	  [City],
	  [District],
	  [Region]
	FROM [Mobile_Schwarzkopf_HO_Plus].[dbo].[bi_client]
	');


--намнбкъел дюммше он пецхнмюл
INSERT INTO [django_test].[dbo].[mdm_addressregion] ([name], [created_at], [updated_at])
SELECT DISTINCT
  TRIM([Region]),
  GETDATE(),
  GETDATE()
FROM #Client
WHERE TRIM([Region]) NOT IN (SELECT [name] FROM [django_test].[dbo].[mdm_addressregion])
  AND [Region] IS NOT NULL

--намнбкъел дюммше он накюяръл
INSERT INTO [django_test].[dbo].[mdm_addressdistrict] ([name], [created_at], [updated_at])
SELECT DISTINCT
  TRIM([District]),
  GETDATE(),
  GETDATE()
FROM #Client
WHERE TRIM([District]) NOT IN (SELECT [name] FROM [django_test].[dbo].[mdm_addressdistrict])
  AND [District] IS NOT NULL

--намнбкъел дюммше он цнпндюл
INSERT INTO [django_test].[dbo].[mdm_addresscity] ([name], [created_at], [updated_at])
SELECT DISTINCT
  TRIM([City]),
  GETDATE(),
  GETDATE()
FROM #Client
WHERE TRIM([City]) NOT IN (SELECT [name] FROM [django_test].[dbo].[mdm_addresscity])
  AND [City] IS NOT NULL

--намнбкъел дюммше он скхжюл
INSERT INTO [django_test].[dbo].[mdm_addressstreet] ([name], [created_at], [updated_at])
SELECT DISTINCT
  TRIM([Street]),
  GETDATE(),
  GETDATE()
FROM #Client
WHERE TRIM([Street]) NOT IN (SELECT [name] FROM [django_test].[dbo].[mdm_addressstreet])
  AND [Street] IS NOT NULL;


--гюонкмъел х намнбкъел рюакхжс юдпеянб
WITH 
[duplicate] AS (
	SELECT
	  TRIM([Address])	AS [address],
	  COUNT(id) AS [count]
	FROM #Client
	GROUP BY TRIM([Address])
	HAVING COUNT(id) = 1
	),

[address] AS (
	SELECT DISTINCT
	  TRIM(client.[Address])	AS [name],
	  CASE [OwnerDistID]
		WHEN 37 THEN 112
		ELSE 643
	  END						AS [county_id],
	  region.[id]				AS [region_id],
	  district.[id]				AS [district_id],
	  city.[id]					AS [city_id],
	  street.[id]				AS [street_id]

	FROM #Client client

	JOIN [django_test].[dbo].[mdm_addressregion] region
	  ON TRIM(client.[Region]) = region.[name]

	JOIN [django_test].[dbo].[mdm_addressdistrict] district
	  ON TRIM(client.[District]) = district.[name]

	JOIN [django_test].[dbo].[mdm_addresscity] city
	  ON TRIM(client.[City]) = city.[name]

	JOIN [django_test].[dbo].[mdm_addressstreet] street
	  ON TRIM(client.[street]) = street.[name]
	
	WHERE TRIM(client.[Address]) in (SELECT [address] FROM [duplicate])
	)

MERGE [django_test].[dbo].[mdm_address] AS trgt
USING [address] AS src
   ON (trgt.[name] = src.[name])
WHEN NOT MATCHED THEN
  INSERT ([name],[country_id],[region_id],[district_id],[city_id],[street_id],[created_at],[updated_at],[details])
  VALUES (src.[name],src.[county_id],src.[region_id],src.[district_id],src.[city_id],src.[street_id],getdate(), getdate(),'(n\s)');


--гюонкмъел рюакхжс йкхемрнб
WITH 
[duplicate] AS (
	SELECT
	  TRIM([Client])	AS [Client],
	  MAX(id)			AS [Id]
	FROM #Client
	GROUP BY TRIM([Client])
	),

[client] AS (
	SELECT DISTINCT
	  TRIM(client.[Client])			AS [name],
	  GETDATE()						AS [created_at],
	  GETDATE()						AS [updated_at],
	  client.[Id]					AS [sys_key],
	  ISNULL(address.[Id],1)		AS [address_id]
	FROM #Client client

	LEFT JOIN [django_test].[dbo].[mdm_address] address
	  ON TRIM(client.[address]) = address.[name]

	WHERE client.[Id] in (SELECT [Id] FROM [duplicate])
	)

MERGE [django_test].[dbo].[mdm_customer] AS trgt
USING [client] AS src
   ON (trgt.[name] = src.[name])
WHEN NOT MATCHED THEN
  INSERT ([name],[created_at],[updated_at],[sys_key], [address_id])
  VALUES (src.[name], src.[created_at], src.[updated_at], src.[sys_key], src.[address_id])
WHEN MATCHED AND src.[sys_key] <> trgt.[sys_key] THEN
	UPDATE SET trgt.[sys_key] = src.[sys_key],
			   trgt.[updated_at] = GETDATE();

END
GO


