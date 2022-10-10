USE [IntegrationDB]
go

/****** Object:  StoredProcedure [dbo].[get_ShelfShare]    Script Date: 09.04.2020 14:18:54 ******/
set ansi_nulls on
go

set quoted_identifier on
go

--drop table [dbo].[ShelfShare]
--go

--create table ShelfShare 
--  (
--    [date]  date    not null,
--    [account_name] varchar(255) not null,
--    [account_id] varchar(50) not null,
--    [point_id] int not null,
--    [category] varchar(50) not null,
--    [share] real not null,
--	[plan] real null,
--	[fact] real null
--  )
--go
---- Add the clustered index
--create clustered index CIX_unic_id on ShelfShare ([date],[account_id],[point_id],[category]);
--create index IX_date on ShelfShare ([date])
--go


alter procedure [dbo].[get_ShelfShare] @date date = null

as

begin

declare
  @cdate date = isnull(@date, cast(getdate() as date)),
  @sdate date,
  @edate date,
  @sql varchar (255)

set @sdate = dateadd(mm, datediff(mm, 0, @cdate), 0)

set @edate = cast(@cdate as date)

set @sql = concat('exec [Mobile_Schwarzkopf_HO_Plus].[dbo].[bi_get_ShelfShare_data] ''', @date, '''')

print(@sql)

delete [IntegrationDB].[dbo].[ShelfShare]
where [date] between @sdate and @edate

insert into [IntegrationDB].[dbo].[ShelfShare]
exec (@sql) at [FTPHBCHO.CDC.RU]

end
GO


