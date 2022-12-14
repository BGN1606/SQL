USE [Authentication]

DECLARE
  @key nvarchar (max),
  @ReportID int,
  @Value nvarchar(100)

exec pwdgen 256, @Value = @key output
set @ReportID = (select max([ReportID])+1 from [Authentication].[dbo].[Report])
set @Value = 'CustomerBrand_review'

insert into [Authentication].[dbo].[Report]
select @key,@ReportID,@Value;


--delete [Authentication].[dbo].[Report]
--where [key] = 'k9Xv+OH2TjhThxzuNgGYiORJpXlzl0Lcz2n1FwGFiY2QLCwNKXpekQjkFAxZGnusc8Pys691j5JAF3/DWqoZerSFKaqMirmz06kKaARjGbCaKQ4Q6JtDdKNiSZWY+oPhdR4T/XI0qoB42by3IjAS2s/3sMapMb1HLj6JY618QldWoXVDv6O2/Y8fvKs+csDbtj0p1i4jGHEFsuQPHlGuF1nzg2saN4dCm0xL5d8kHsWKunN2hVJ4JeLPSdp2GABwIQ7h45Ry6tO5/zq4H50fAE3r0kwVbJKBdq9jLyv8mn2Ku4JGj91u1SAw5Iz6z6SyYSh/ClLDEML4ezolUnbCGg=='


select * from [Authentication].[dbo].[Report]
where ReportID = @ReportID
