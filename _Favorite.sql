USE [HBCAMS_IntegrationDB]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET STATISTICS TIME OFF --|Отображает время в миллисекундах, необходимое для синтаксического анализа, компиляции и выполнения каждой инструкции.
SET STATISTICS IO OFF --|Позволяет SQL Server отображать сведения об активности диска, связанной с выполнением инструкций Transact-SQL.
SET ARITHABORT OFF --|Завершает запрос, если во время выполнения запроса возникает ошибка переполнения или деления на ноль.
SET ANSI_WARNINGS OFF --|Задает поведение в соответствии со стандартом ISO для некоторых условий ошибок.
GO

-- Первый день месяца
SELECT DATEADD(MM, DATEDIFF(MM, 0, GETDATE()), 0);
SELECT DATEADD(DAY, 1 - DAY(GETDATE()), GETDATE());

-- Первый понедельник месяца
SELECT DATEADD(DAY, 8 - DATEPART(WEEKDAY, DATEADD(DAY, 1 - DAY(GETDATE()), GETDATE())),
               DATEADD(DAY, 1 - DAY(GETDATE()), GETDATE()));

-- Пример использования словаря АМС
SELECT [AttributeName], [AttributeValue], [Value]
FROM [HBCAMS_MSCRM].[dbo].[FilteredStringMap]
WHERE [LangId] = 1049
  AND [FilteredViewName] = 'Filteredcdc_ForcastMut'
  AND [AttributeName] = 'cdc_type';


-- Информация о БД на сервере
SELECT *
FROM [sys].[databases];


-- Информация о таблицах в выбранной БД
SELECT *
FROM [sys].[objects]
WHERE [type] NOT IN ('D', '');

-- Информация обо всех объектах в выбранной БД
SELECT *
FROM [sys].[all_objects];


-- Информация обо всех объектах на сервере
[sp_helpdb];


-- Просмотр списка баз данных в экземпляре SQL Server
SELECT [Name], [Database_id], [Create_date]
FROM [sys].[databases] [d];

-- ДОСТАТЬ ВСЕ ПРОЦЕДУРЫ
USE [Mobile_Schwarzkopf_HO]
SELECT 'EXEC xp_cmdShell ''bcp "USE Mobile_Schwarzkopf_HO EXEC sp_helptext ' + [name] +
       '" queryout D:\FTP\HOPlus\Proc\' + [name] + '.txt -T -c -C Win1251'', no_output'
FROM [sysobjects]
WHERE [type] = 'P'

-- Скопировать вставаить в SSMS и запустить выполнение c сохранением в файл Ctrl+Shift+F
SELECT CONCAT('EXEC sp_helptext ', [name])
FROM [sysobjects]
WHERE [type] = 'P'

-- Missing Index Stats
SELECT TOP 100 *
FROM [sys].[dm_DB_Missing_Index_Group_Stats] [GS]
INNER JOIN [sys].[dm_DB_Missing_Index_Groups] [G]
           ON [GS].[Group_Handle] = [G].[Index_Group_Handle]
INNER JOIN [sys].[dm_db_missing_index_details] [ID]
           ON [G].[index_handle] = [ID].[index_handle]
ORDER BY ([user_seeks] + [user_scans]) * [avg_total_user_cost] * [avg_user_impact] DESC

-- Статистика по ожиданиям
SELECT [wait_type]
     , [wait_time_ms]
     , CONVERT(DECIMAL(7, 4), 100 * [wait_time_ms] / SUM([wait_time_ms]) OVER ()) AS [Percent]
FROM [sys].[dm_os_wait_stats]
WHERE [wait_type] NOT LIKE 'Broker%'
ORDER BY [Percent] DESC;

-- Обновление статистики
USE [HBCAMS_IntegrationDB];
EXEC [sp_updatestats];
USE [HBCAMS_MSCRM];
EXEC [sp_updatestats];
EXEC [sp_MSForEachTable] 'UPDATE STATISTICS ? WITH FULLSCAN;';


-- Блокировки
sp_lock;

SELECT [name]
     , [snapshot_isolation_state]
     , [snapshot_isolation_state_desc]
FROM [sys].[databases];

-- Просмотр Collation Сервера
SELECT CONVERT(VARCHAR(256), SERVERPROPERTY('collation'));

-- Просмотр Collation Базы данных
SELECT [name], [collation_name]
FROM [sys].[databases];

-- Просмотр Collation Таблиц и столбцов
SELECT [o].[name], [o].[type_desc], [c].[name], [c].[collation_name]
FROM [sys].[columns] [c]
JOIN [sys].[tables] [o]
     ON [c].[object_id] = [o].[object_id]
WHERE [o].[type] = 'U'
  AND [o].[name] = 'Calendar'

-- Удаление индексов
USE [HBCAMS_MSCRM]
GO

SELECT
--DROP INDEX [_dta_index_cdc_promoitemsBase_8_1967606348__K1] ON [dbo].[cdc_promoitemsBase]
CONCAT('DROP INDEX ', [s].[name], ' ON dbo.', [o].[name], ';')
FROM [sys].[stats] [s]
JOIN [sys].[tables] [o]
     ON [s].[object_id] = [o].[object_id]
WHERE [s].[name] LIKE '_dta%'
--AND s.[object_id] = OBJECT_ID('dbo.cdc_promoitemsBase')

-- Перестроения всей статистики по всем таблицам
EXEC [sp_MSForEachTable] 'UPDATE STATISTICS ? WITH FULLSCAN;'

-- Kill Sleeping Sessions
DECLARE @user_spid INT
DECLARE [CurSPID] CURSOR FAST_FORWARD
    FOR
    SELECT [SPID]
    FROM [master].[dbo].[sysprocesses] (NOLOCK)
    WHERE [spid] > 50           -- avoid system threads
      AND [status] = 'sleeping' -- only sleeping threads
-- AND DATEDIFF(MINUTE,last_batch,GETDATE())>=600 -- thread sleeping for 12 hours
      AND [spid] <> @@SPID -- ignore current spid
OPEN [CurSPID]
FETCH NEXT FROM [CurSPID] INTO @user_spid
WHILE (@@FETCH_STATUS = 0)
    BEGIN
        PRINT 'Killing ' + CONVERT(VARCHAR, @user_spid)
        EXEC ('KILL '+@user_spid)
        FETCH NEXT FROM [CurSPID] INTO @user_spid
    END
CLOSE [CurSPID]
DEALLOCATE [CurSPID]

-- Kill bi_creators Sessions
DECLARE @user_spid INT
DECLARE [CurSPID] CURSOR FAST_FORWARD
    FOR
    SELECT [SPID]
    FROM [master].[dbo].[sysprocesses] (NOLOCK)
    WHERE [spid] > 50 -- avoid system threads
      AND [loginame] IN ('bi_creators', 'NT AUTHORITY\NETWORK SERVICE') -- only bi_creators threads
OPEN [CurSPID]
FETCH NEXT FROM [CurSPID] INTO @user_spid
WHILE (@@FETCH_STATUS = 0)
    BEGIN
        PRINT 'Killing ' + CONVERT(VARCHAR, @user_spid)
        EXEC ('KILL '+@user_spid)
        FETCH NEXT FROM [CurSPID] INTO @user_spid
    END
CLOSE [CurSPID]
DEALLOCATE [CurSPID]

-- SHRINKFILE LOG
USE [HBCAMS_IntegrationDB]
GO
DBCC SHRINKFILE (N'HBCAMS_IntegrationDB_log' , EMPTYFILE)
GO