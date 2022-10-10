DECLARE @SQL NVARCHAR(MAX)

SELECT @SQL = STUFF((
    SELECT 'UNION ALL SELECT ''' + o.name + ''', COUNT_BIG(*)
    FROM [' + SCHEMA_NAME(o.[schema_id]) + '].[' + o.name + ']'
    FROM sys.all_objects o
    WHERE [type] = 'V'
	  and [name] not like '%Filtered%'
	  and [schema_id] = 1
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 10, '') + ' ORDER BY 2 DESC'

PRINT @SQL

EXEC sys.sp_executesql @SQL