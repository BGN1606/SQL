use schwarzkopf

if object_id('tempdb..#tmp_db') is not null drop table #tmp_db
select row_number() over(order by fid asc) as id,name,fid database_id 
into #tmp_db
from [dbo].[dblist] d
where activeflg=1 and country='rus'

declare 
@db_name nvarchar(100),
@db_id int

set @db_id=(select min(id) from #tmp_db)
set @db_name=(select name from #tmp_db where id=@db_id)

while @db_id>0
  begin
  execute('
  insert into doc_unknown
  select distinct 
	d.fid,d.fname place,isnull(count(orid),0) doc_count
  from [ftphbc.cdc.ru].['+@db_name+'].[dbo].[ds_orders] o
  join [ftphbc.cdc.ru].['+@db_name+'].[dbo].[ds_faces] f
	on o.mfid=f.fid
	and f.exid=''tt_unknown''
  join [ftphbc.cdc.ru].['+@db_name+'].[dbo].[ds_faces] d
	on f.distid=d.fid
  where year(ordate)=2018
	and month(ordate)=2
	and condition=1
	and ortype in (2,9,680)
  group by d.fid,d.fname
			')
  delete #tmp_db where id=@db_id
  set @db_id=(select min(id) from #tmp_db)
  end
drop table #tmp_db