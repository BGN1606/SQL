SELECT * FROM [msdb].[dbo].[sysjobhistory];


SELECT * FROM [msdb].[dbo].[sysjobs];


SELECT * FROM [msdb].[dbo].[sysjobsteps];


SELECT [database_name]
     , [name]
     , [enabled]
     , [description]
     , s.[step_id]
     , s.[step_name]
     , [command]
     , [last_run_outcome]
     , [last_run_duration]
     , [last_run_retries]
     , [last_run_date]
     , [last_run_time]
     , [sql_message_id]
     , [sql_severity]
     , [message]
     , [run_status]
     , [run_date]
     , [run_time]
     , [run_duration]
FROM [msdb].[dbo].[sysjobs]             [J]
INNER JOIN [msdb].[dbo].[sysjobsteps]   [S] ON [J].[job_id] = [S].[job_id]
INNER JOIN [msdb].[dbo].[sysjobhistory] [H] ON [J].[job_id] = [H].[job_id]
WHERE [run_date] = [last_run_date]
and [run_time] = [last_run_time]































