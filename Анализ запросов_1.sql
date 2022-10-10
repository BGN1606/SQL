USE [master]
GO

-- Посмотреть Настройки пользователя
DBCC USEROPTIONS

-- Проверка соединения
SELECT *
FROM [sys].[dm_exec_connections]
ORDER BY
    [session_id];

-- Просмотр сессий
SELECT *
FROM [sys].[dm_exec_sessions]
ORDER BY
    [session_id];

-- Посмотреть запросы
-- sql_handle - Сам запрос
-- plan_handle - План выполнения
SELECT *
FROM [sys].[dm_exec_requests] [r]
CROSS APPLY [sys].[dm_exec_sql_text]([r].[sql_handle]) [sql]
CROSS APPLY [sys].[dm_exec_query_plan]([r].[plan_handle]) [plan]
WHERE [sql_handle] IS NOT NULL;

-- Расшифровка sql_handle
SELECT *
FROM [sys].[dm_exec_sql_text](
        0x0200000016558C0E3DA1062165A5FE04E06347DD88ABC5060000000000000000000000000000000000000000);

-- Расшифровка query_plan
SELECT *
FROM [sys].[dm_exec_query_plan](
        0x0600010016558C0E30F3B95E0600000001000000000000000000000000000000000000000000000000000000);

-- Просмотр задач
-- session_id
-- task_state
SELECT *
FROM [sys].[dm_os_tasks]

-- Просмотр Workers
SELECT *
FROM [sys].[dm_os_workers];

-- Список ожидания
SELECT *
FROM [sys].[dm_os_waiting_tasks];

-- Просмотр потоков OS
SELECT *
FROM [sys].[dm_os_threads]

-- Просмотр планировщика
SELECT *
FROM [sys].[dm_os_schedulers]
WHERE [status] LIKE 'VISIBLE ONLINE%'

-- Цепочка анализа
SELECT [w].[state], *
FROM [sys].[dm_exec_connections] [c]
INNER JOIN [sys].[dm_exec_sessions] [s]
           ON [c].[session_id] = [s].[session_id]
INNER JOIN [sys].[dm_exec_requests] [r]
           ON [s].[session_id] = [r].[session_id]
INNER JOIN [sys].[dm_os_tasks] [t]
           ON [r].[session_id] = [t].[session_id]
INNER JOIN [sys].[dm_os_workers] [w]
           ON [t].[task_address] = [w].[task_address]
ORDER BY
    [c].[session_id]


-- Статистика по типам ожидания
SELECT *, [wait_time_ms] - [dm_os_wait_stats].[signal_wait_time_ms] AS [resource_wait_time_ms]
FROM [sys].[dm_os_wait_stats]
ORDER BY
    [resource_wait_time_ms] DESC;

-- Статистика ожидания по сессиям
SELECT *
FROM [sys].[dm_exec_session_wait_stats];

-- Просмотр кешированных планов
SELECT *
FROM [sys].[dm_exec_cached_plans] [cp]
CROSS APPLY [sys].[dm_exec_sql_text]([cp].[plan_handle])
CROSS APPLY [sys].[dm_exec_query_plan]([cp].[plan_handle])
ORDER BY
    [usecounts] DESC;





