/****** Script for SelectTopNRows command from SSMS  ******/

SELECT distinct 'Gradient' as Distrib, DateCreated  FROM [Mobile_Schwarzkopf_GradientMsk].[dbo].[DS_SalesVerificationReport]
union all
SELECT distinct 'Urves' as distrib, DateCreated  FROM  [Mobile_Schwarzkopf_UrvesMsk].[dbo].[DS_SalesVerificationReport]
union all
SELECT distinct 'AA Atirau' as distrib ,DateCreated  FROM [Mobile_Schwarzkopf_KZ_Atirau].[dbo].[DS_SalesVerificationReport]



--SELECT *  FROM [Mobile_Schwarzkopf_GradientMsk].[dbo].[DS_SalesVerificationReport] where DateCreated=CAST(GETDATE() as date)
--order by docdate

--SELECT *  FROM [Mobile_Schwarzkopf_UrvesMsk].[dbo].[DS_SalesVerificationReport] where DateCreated=CAST(GETDATE() as date)
--order by docdate

--SELECT *  FROM [Mobile_Schwarzkopf_KZ_Atirau].[dbo].[DS_SalesVerificationReport] where DateCreated=CAST(GETDATE() as date)
--order by docdate



--SELECT CAST(GETDATE() AS DATE)


--SELECT distinct 'Gradient' as Distrib, svr.DateCreated, SVR.DocDate FROM [Mobile_Schwarzkopf_GradientMsk].[dbo].[DS_SalesVerificationReport] SVR