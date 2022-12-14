USE Schwarzkopf

DECLARE
  @sDate DATE,
  @eDate DATE,
  @ErrCode INT,
  @ErrText NVARCHAR (100),
  @Details NVARCHAR (255)

SET @sDate='20180901'
SET @eDate='20180930'

/*============================================================*/
/*=============Копирование данных из Report.txt===============*/
/*============================================================*/

IF OBJECT_ID('DMS_SalesVerification_KIS','U') IS NOT NULL
DROP TABLE [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS]

SELECT * INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS]
FROM [FTPHBC.CDC.RU].[Distr_Plus].[dbo].[vDS_SalesVerificationReport] WITH (NOLOCK)
WHERE DateCreated = CAST(GETDATE() AS DATE)
  AND DocDate between @sDate and @eDate

/*============================================================*/
/*===============Копирование данных из БД WARM================*/
/*============================================================*/

IF OBJECT_ID('DMS_SalesVerification_WARM','U') IS NOT NULL
DROP TABLE [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM]

SELECT * INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM]
FROM [FTPHBC.CDC.RU].[Distr_Plus].[dbo].[vDS_Orders]  WITH (NOLOCK)
WHERE orDate between @sDate and @eDate

/*============================================================*/
/*===============Чистка результирующей таблицы================*/
/*============================================================*/

IF OBJECT_ID('DMS_SalesVerification_Report','U') IS NOT NULL
TRUNCATE TABLE [Schwarzkopf].[dbo].[DMS_SalesVerification_Report]

/*============================================================*/
/*=============Проверка на предоставление данных==============*/
/*============================================================*/

set @ErrCode = 1001
set @ErrText = 'Нет данных для проведения автосверки'
set @Details = 'На момент проведения сверки, отчет Report.txt не был выгружен, просьба проверить соответствие регламенту из ТЗ и наличие ошибок загрузки на ftp'

INSERT INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_Report]
SELECT  
  DATENAME(MONTH,@sDate) AS Month,
  db.Country             AS Country,
  db.fid                 AS PlaceId,
  db.fname               AS PlaceName,
  @ErrCode               AS ErrCode,
  @ErrText               AS ErrText,
  null                   AS UfaceExId,
  null                   AS UfaceName,
  null                   AS DocType,
  null                   AS DocDate,
  null                   AS DocId,
  null                   AS DocNumber,
  null                   AS ProductName,
  null                   AS EAN,
  null                   AS IDH,
  null                   AS Amount,
  null                   AS SUMM,
  @Details               AS Details
FROM dblist db
JOIN (SELECT DISTINCT [OwnerDistID], [dbname] FROM [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM]) w
  ON db.name = w.dbname
LEFT JOIN (SELECT DISTINCT  [Country], [db_name] FROM [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS]) k
  ON w.dbname = k.db_name
WHERE k.db_name is null

/*============================================================*/
/*==============Поиск нераспределенных накладных==============*/
/*============================================================*/

set @ErrCode = 1002
set @ErrText = 'Нераспределенная накладная'
set @Details = 'Отсутствует привязанное к торг. точке Юр. лицо, необходимо выполнить привязку и перераспределить накладную'

INSERT INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_Report]
SELECT DISTINCT
  DATENAME(MONTH,@sDate)                      AS Month,
  db.Country                                  AS Country,
  db.fid                                      AS PlaceId,
  db.fname                                    AS PlaceName,
  @ErrCode                                    AS ErrCode,
  @ErrText                                    AS ErrText,
  k.UFaceID                                   AS UfaceExId,
  k.UFaceName                                 AS UfaceName,
  dtName                                      AS DocType,
  w.ordate                                    AS DocDate,
  w.DocId                                     AS DocId,
  w.orNumber                                  AS DocNumber,
  null                                        AS ProductName,
  null                                        AS EAN,
  null                                        AS IDH,
  CONVERT(int,SUM(w.Amount))                  AS Amount,
  CONVERT(decimal(18,2),SUM(w.Amount*w.Cost)) AS SUMM,
  @Details                                    AS Details
FROM dblist db
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM] w
  ON db.name = w.dbname
LEFT JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS] k
  ON w.[dbname]=k.[db_name]
 AND w.Docid=k.Docid
WHERE w.uexid = 'tt_unknown'
  and w.ortype in (2,9)
GROUP BY
db.Country,
db.fid,    
db.fname,  
k.UFaceID,
k.UFaceName,
dtName,    
w.ordate,  
w.DocId,   
w.orNumber

/*============================================================*/
/*==================Проверка связки EAN-IDH===================*/
/*============================================================*/

set @ErrCode = 1003
set @ErrText = 'Неправильная связка EAN - IDH в справочнике товаров КИС Дистрибьютора'
set @Details = 'Необходимо сверить соответствие связки EAN - IDH из справочника товаров КИС Дистрибьютора с мастер-данными от ГО Henlkel (Schwarzkopf). После корректировки справочника необходимо перевыгрузить накладные и остатки'

INSERT INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_Report]
SELECT DISTINCT 
  DATENAME(MONTH,@sDate) AS Month,
  db.Country             AS Country,
  db.fid                 AS PlaceId,
  db.fname               AS PlaceName,
  @ErrCode               AS ErrCode,
  @ErrText               AS ErrText,
  null                   AS UfaceExId,
  null                   AS UfaceName,
  null                   AS DocType,
  null                   AS DocDate,
  null                   AS DocId,
  null                   AS DocNumber,
  k.[ItemsName]          AS ProductName,
  k.EAN                  AS EAN,
  k.IDH                  AS IDH,
  null                   AS Amount,
  null                   AS SUMM,
  @Details               AS Details
FROM dblist db
JOIN (SELECT DISTINCT [db_name],[IDH],[EAN],[ItemsName]
      FROM [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS]) k
  ON db.name = k.[db_name]
LEFT JOIN (SELECT i.iID,i.iidText EAN,p.Exid IDH,i.iName Product
           FROM [FTPHBCHO.CDC.RU].[Mobile_Schwarzkopf_HO].[dbo].[DS_ITEMS] i
           join [FTPHBCHO.CDC.RU].[Mobile_Schwarzkopf_HO].[dbo].[DS_Parts] p
             ON i.iId=p.IID) p
  ON convert(nvarchar,k.IDH) = CONVERT(nvarchar,p.IDH)
LEFT JOIN (SELECT i.iID,i.iidText EAN,p.Exid IDH,i.iName Product
      FROM [FTPHBCHO.CDC.RU].[Mobile_Schwarzkopf_HO].[dbo].[DS_ITEMS] i
      join [FTPHBCHO.CDC.RU].[Mobile_Schwarzkopf_HO].[dbo].[DS_Parts] p
        ON i.iId=p.IID) E
  ON CONVERT(nvarchar,k.EAN)=CONVERT(nvarchar,e.EAN)
WHERE p.IID <> e.iid

/*============================================================*/
/*==============Целостность документов нарушена===============*/
/*============================================================*/

set @ErrCode = 1004
set @ErrText = 'Целостность документов нарушена'
set @Details = 'Документ с таким кодом не найден в КИС (Report.txt), но пристутствует в WARM'

INSERT INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_Report]
SELECT 
  DATENAME(MONTH,@sDate)                      AS Month,
  db.Country                                  AS Country,
  db.fid                                      AS PlaceId,
  db.fname                                    AS PlaceName,
  @ErrCode                                    AS ErrCode,
  @ErrText                                    AS ErrText,
  null                                        AS UfaceExId,
  null                                        AS UfaceName,
  w.[dtName]                                  AS DocType,
  null                                        AS DocDate,
  w.DocID                                     AS DocId,
  w.orNumber                                  AS DocNumber,
  null                                        AS ProductName,
  null                                        AS EAN,
  null                                        AS IDH,
  CONVERT(int,SUM(w.Amount))                  AS Amount,
  CONVERT(decimal(18,2),SUM(w.Amount*w.Cost)) AS SUMM,
  @Details                                    AS Details
FROM dblist db
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM] w
  ON db.[name]=w.[dbname]
LEFT JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS] k
  ON w.[dbname]=k.[db_name]
 AND w.DocID=k.DocID
WHERE w.dbname in (select db_name from [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS])
  AND k.DocID IS NULL
GROUP BY
db.Country
,db.fid
,db.fname
,w.dtName
,w.DocID
,w.orNumber

/*============================================================*/
/*==============Целостность документов нарушена===============*/
/*============================================================*/

set @ErrCode = 1004
set @ErrText = 'Целостность документов нарушена'
set @Details = 'Документ с таким кодом не найден в WARM, но пристутствует в КИС (Report.txt)'

INSERT INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_Report]
SELECT 
  DATENAME(MONTH,@sDate)                      AS Month,
  db.Country                                  AS Country,
  db.fid                                      AS PlaceId,
  db.fname                                    AS PlaceName,
  @ErrCode                                    AS ErrCode,
  @ErrText                                    AS ErrText,
  null                                        AS UfaceExId,
  null                                        AS UfaceName,
  dt.dtName                                   AS DocType,
  null                                        AS DocDate,
  k.DocID                                     AS DocId,
  k.DocNumber                                 AS DocNumber,
  null                                        AS ProductName,
  null                                        AS EAN,
  null                                        AS IDH,
  CONVERT(int,SUM(k.Amount))                  AS Amount,
  CONVERT(decimal(18,2),SUM(k.Sum))           AS SUMM,
  @Details                                    AS Details
FROM dblist db
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS] k
  ON db.[name]=k.[db_name]
LEFT JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM] w
  ON k.[db_name]=w.[dbname]
 AND k.DocID=w.DocID
JOIN (SELECT DISTINCT [orType], [dtName]
           FROM [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM]) dt
  ON k.DocType=dt.orType
WHERE w.DocID IS NULL
GROUP BY
 db.Country
,db.fid
,db.fname
,dt.dtName
,k.DocID
,k.DocNumber

/*============================================================*/
/*=====================Избыточные данные======================*/
/*============================================================*/

set @ErrCode = 1005
set @ErrText = 'Избыточные данные'
set @Details = 'Выгружаемый из КИС (Report.txt) -тип документа не объявлен в ТЗ. Необходимо исключить из выгрузки Report.txt'

INSERT INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_Report]
SELECT DISTINCT
  DATENAME(MONTH,@sDate) AS Month,
  db.Country             AS Country,
  db.fid                 AS PlaceId,
  db.fname               AS PlaceName,
  @ErrCode               AS ErrCode,
  @ErrText               AS ErrText,
  null                   AS UfaceExId,
  null                   AS UfaceName,
  k.DocType              AS DocType,
  null                   AS DocDate,
  null                   AS DocId,
  null                   AS DocNumber,
  null                   AS ProductName,
  null                   AS EAN,
  null                   AS IDH,
  null                   AS Amount,
  null                   AS SUMM,
  @Details               AS Details
FROM dblist db
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS] k
  ON db.[name]=k.[db_name]
LEFT JOIN (SELECT DISTINCT [orType], [dtName]
           FROM [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM]) dt
  ON k.DocType=dt.orType
WHERE dt.orType is null

/*============================================================*/
/*===========Проверка соответствия типов документов===========*/
/*============================================================*/

set @ErrCode = 1006
set @ErrText = 'Несоответствие типов документов'

INSERT INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_Report]
SELECT DISTINCT
  DATENAME(MONTH,@sDate) AS Month,
  db.Country             AS Country,
  db.fid                 AS PlaceId,
  db.fname               AS PlaceName,
  @ErrCode               AS ErrCode,
  @ErrText               AS ErrText,
  null                   AS UfaceExId,
  null                   AS UfaceName,
  k.DocType              AS DocType,
  k.DocDate              AS DocDate,
  k.DocID                AS DocId,
  k.DocNumber            AS DocNumber,
  null                   AS ProductName,
  null                   AS EAN,
  null                   AS IDH,
  null                   AS Amount,
  null                   AS SUMM,
  CONCAT('Выгружаемый из КИС (Report.txt) документ уже был ранее выгружен в WARM с типом документа "',w.orType,'"')  AS Details
FROM dblist db
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM] w
  ON db.[name]=w.[dbname]
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS] k
  ON w.[dbname]=k.[db_name]
 AND w.DocID=k.DocID
WHERE w.orType<>k.DocType

/*============================================================*/
/*============Проверка соответствия дат документов============*/
/*============================================================*/

set @ErrCode = 1007
set @ErrText = 'Несоответствие дат документов'

INSERT INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_Report]
SELECT DISTINCT
  DATENAME(MONTH,@sDate) AS Month,
  db.Country             AS Country,
  db.fid                 AS PlaceId,
  db.fname               AS PlaceName,
  @ErrCode               AS ErrCode,
  @ErrText               AS ErrText,
  k.UFaceID              AS UfaceExId,
  k.UFaceName            AS UfaceName,
  k.DocType              AS DocType,
  k.DocDate              AS DocDate,
  k.DocID                AS DocId,
  k.DocNumber            AS DocNumber,
  null                   AS ProductName,
  null                   AS EAN,
  null                   AS IDH,
  null                   AS Amount,
  null                   AS SUMM,
  CONCAT('Выгружаемый из КИС (Report.txt) документ уже был ранее выгружен в WARM с датой документа "',w.orDate,'"')  AS Details
FROM dblist db
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM] w
  ON db.[name]=w.[dbname]
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS] k
  ON w.[dbname]=k.[db_name]
 AND w.DocID=k.DocID
WHERE w.orDate<>k.DocDate

/*============================================================*/
/*=========Проверка соответствия юр. лиц в документах=========*/
/*============================================================*/

set @ErrCode = 1008
set @ErrText = 'Несоответствие юр. лиц документов'

INSERT INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_Report]
SELECT DISTINCT
  DATENAME(MONTH,@sDate) AS Month,
  db.Country             AS Country,
  db.fid                 AS PlaceId,
  db.fname               AS PlaceName,
  @ErrCode               AS ErrCode,
  @ErrText               AS ErrText,
  k.UFaceID              AS UfaceExId,
  k.UFaceName            AS UfaceName,
  k.DocType              AS DocType,
  k.DocDate              AS DocDate,
  k.DocID                AS DocId,
  k.DocNumber            AS DocNumber,
  null                   AS ProductName,
  null                   AS EAN,
  null                   AS IDH,
  null                   AS Amount,
  null                   AS SUMM,
  CONCAT('Выгружаемый из КИС (Report.txt) документ уже был ранее выгружен в WARM с кодом юр. лица "',w.UExId,'"')  AS Details
FROM dblist db
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM] w
  ON db.[name]=w.[dbname]
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS] k
  ON w.[dbname]=k.[db_name]
 AND w.DocID=k.DocID
WHERE w.UExId<>k.UFaceID
  and w.UExId <> 'TT_unknown'

/*============================================================*/
/*=============Проверка кол-ва товара в документах============*/
/*============================================================*/

set @ErrCode = 1009
set @ErrText = 'Несоответствие кол-ва товара в документе'

INSERT INTO [Schwarzkopf].[dbo].[DMS_SalesVerification_Report]
SELECT DISTINCT
  DATENAME(MONTH,@sDate)            AS Month,
  db.Country                        AS Country,
  db.fid                            AS PlaceId,
  db.fname                          AS PlaceName,
  @ErrCode                          AS ErrCode,
  @ErrText                          AS ErrText,
  k.UFaceID                         AS UfaceExId,
  k.UFaceName                       AS UfaceName,
  w.dtName                          AS DocType,
  k.DocDate                         AS DocDate,
  k.DocID                           AS DocId,
  k.DocNumber                       AS DocNumber,
  k.ItemsName                       AS ProductName,
  k.EAN                             AS EAN,
  null                              AS IDH,
  CONVERT(int,SUM(k.Amount))        AS Amount,
  CONVERT(decimal(18,2),SUM(k.Sum)) AS SUMM,
  CONCAT('Выгружаемое из КИС (Report.txt) кол-во товара в документе не соответствует кол-ву товара из документа в WARM "', CONVERT(int,SUM(k.Amount)),'"')  AS Details
FROM dblist db
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_WARM] w
  ON db.[name]=w.[dbname]
JOIN [Schwarzkopf].[dbo].[DMS_SalesVerification_KIS] k
  ON w.[dbname]=k.[db_name]
 AND w.DocID=k.DocID
 AND w.iidText=k.EAN
GROUP BY
db.Country,
db.fid,
db.fname,
k.UFaceID,
k.UFaceName,
w.dtName,
k.DocDate,
k.DocID,
k.DocNumber,
k.ItemsName,
k.EAN
HAVING SUM(k.Amount) <> SUM(w.Amount)