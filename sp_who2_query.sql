/*
KILL 60
*/

-- Ожидания
SELECT [session_id]
--      , [exec_context_id]            AS [context_id]
     , [wait_duration_ms]
     , [wait_type]
     , [blocking_session_id]
--      , [blocking_exec_context_id]   AS [block_context_id]
--      , [resource_description]       AS [resource_description]
FROM [sys].[dm_os_waiting_tasks] WITH (NOLOCK)
WHERE [session_id] IN
      (SELECT [session_id]
       FROM [sys].[dm_exec_sessions]
       WHERE [is_user_process] = 1
         AND [Status] NOT IN ('sleeping', 'background'))
ORDER BY [wait_duration_ms] DESC, [session_id], [wait_type];

-- Процессы
WITH [c] AS (
    SELECT [a].[request_session_id]  AS [spid]
         , [b].[blocking_session_id] AS [blkby]
    FROM [sys].[dm_tran_locks] [a] WITH (NOLOCK)
    JOIN [sys].[dm_os_waiting_tasks] [b]
         ON [a].[lock_owner_address] = [b].[resource_address]
)
   , [p] AS (
    SELECT [a].[session_id]                                                   AS [spid]
         , [a].[login_name]                                                   AS [login]
         , [a].[host_name]                                                    AS [host]
         , [a].[program_name]                                                 AS [progname]
         , DB_NAME([b].[database_id])                                         AS [dbname]
         , [b].[command]                                                      AS [cmd]
         , ISNULL([b].[status], [a].[status])                                 AS [status]
         , [C].[blkby]                                                        AS [blkby]
         , ISNULL([b].[cpu_time], [a].[cpu_time]) / 60000                     AS [cputime]
         , ISNULL(([b].[reads] + [b].[writes]), ([a].[reads] + [a].[writes])) AS [diskio]
--          , [a].[last_request_start_time]                                      AS [lastbatch]
         , [d].[text]                                                         AS [sqlstatement]

    FROM [sys].[dm_exec_sessions] [a] WITH (NOLOCK)
    LEFT JOIN [sys].[dm_exec_requests] [b]
              ON [a].[session_id] = [b].[session_id]
    LEFT JOIN [c]
              ON [a].[session_id] = [c].[spid]
    OUTER APPLY [sys].[dm_exec_sql_text]([sql_handle]) [d]
)
SELECT *
FROM [p] WITH (NOLOCK)
WHERE ([status] NOT IN ('sleeping', 'background') /*OR diskio > 5000 OR cputime > 0*/)
--   AND [sqlstatement] IS NOT NULL
  AND [spid] > 50
ORDER BY [login], [status], [diskio] DESC, [cputime] DESC, [cmd];

/*
-- Просмотр имени пользователя по его ИД
SELECT [FullName]
FROM [HBCAMS_MSCRM].[dbo].[SystemUser]
WHERE [SystemUserId] = '4d21b433-9a83-e911-810a-0050560186bb';
*/

/*
-- Анализ выполняемых запросов
SELECT *
FROM [sys].[dm_exec_requests] [r]
CROSS APPLY [sys].[dm_exec_sql_text]([r].[sql_handle]) [sql]
CROSS APPLY [sys].[dm_exec_query_plan]([r].[plan_handle]) [plan]
WHERE [sql_handle] IS NOT NULL;
 */
