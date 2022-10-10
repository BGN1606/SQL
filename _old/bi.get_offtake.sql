use [IntegrationDB]
go

--create table Offtake 
--  (
--    [date]  date    not null,
--    [account_name] varchar(255) not null,
--    [account_id] varchar(50) not null,
--    [ean] varchar(50) not null,
--    [product_name]  varchar(255) not null,
--    [amount] real not null
--  )

---- Add the clustered index
--create clustered index CIX_doc_id on Offtake (doc_id);
--create index IX_date on Offtake (date)
--create index IX_account_id on Offtake (account_id)



alter procedure get_Offtake @startdate date = null, @enddate date = null

as

begin

declare
  --@startdate date = null, @enddate date = null,
  @sdate date,
  @edate date,
  @sql varchar (255)

set @sdate = isnull(@startdate, dateadd(mm, -1, dateadd(mm, datediff(mm, 0, getdate()), 0)))
set @edate = isnull(@enddate, cast(getdate() as date))
set @sql = concat('exec [Mobile_Schwarzkopf_HO_Plus].[dbo].[bi_get_Offtake_data] ''', @sdate, ''', ''', @edate,'''')

print(@sql)

delete [IntegrationDB].[dbo].[Offtake]
where [date] between @startdate and @enddate

insert into [IntegrationDB].[dbo].[Offtake]
exec (@sql) at [FTPHBCHO.CDC.RU]

end