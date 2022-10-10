DECLARE @db_name varchar(50) = N'Mobile_Schwarzkopf_HO',
                @table_name varchar(250) --= N'db_name.dbo.tbl_name'

SELECT  
  IndStat.database_id, 
  IndStat.object_id, 
  QUOTENAME(s.name) + '.' + QUOTENAME(o.name) AS [object_name], 
  IndStat.index_id, 
  QUOTENAME(i.name) AS index_name,
  IndStat.avg_fragmentation_in_percent,
  IndStat.partition_number, 
  (select count (*)
   from sys.partitions p
   where p.object_id = IndStat.object_id
     and p.index_id = IndStat.index_id) as partition_count

from sys.dm_db_index_physical_stats (DB_ID(@db_name), OBJECT_ID(@table_name), NULL, NULL , 'LIMITED') AS IndStat
join sys.objects as o 
  on (IndStat.object_id = o.object_id)
join sys.schemas as s
  on s.schema_id = o.schema_id
join sys.indexes i
  on (i.object_id = IndStat.object_id AND i.index_id = IndStat.index_id)
where IndStat.index_id > 0
  --AND IndStat.avg_fragmentation_in_percent > 10
order by object_name
