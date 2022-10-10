use [IntegrationDB]
go

declare
  @sdate date = '20190301',
  @edate date = '20200401',
  @date date

while @sdate <= @edate

begin
  print (@sdate)
  
  set @date = eomonth(@sdate)
  print (@date)
  
  exec [IntegrationDB].[dbo].[get_ShelfShare] @date
  
  set @sdate = dateadd(mm,1,@sdate)
end
