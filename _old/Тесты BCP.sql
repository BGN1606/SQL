--SELECT TOP 10 FROM DS_Attributes

--BCP mobile_schwarzkopf_HO.dbo.DS_Attributes IN D:\FTP\HOPlus\DS_OffTake.bcp -f D:\FTP\HOPlus\DS_OffTake.txt -T

 --bcp "SELECT top 10 * FROM mobile_schwarzkopf_HO.dbo.DS_Attributes" queryout "D:\FTP\HOPlus\test.txt" -c -T

-- DECLARE @result int

--EXEC @result = master..xp_cmdshell 'osql -S MYSQLSERVER -E -Q "SELECT top 10 * FROM mobile_schwarzkopf_HO.dbo.DS_Attributes" -b -o D:\FTP\HOPlus\test.txt', no_output
--IF (@result = 0)
--   PRINT 'Success'
--ELSE
--   PRINT 'Failure'



--exec [master].[sys].[xp_cmdshell] 'sql -S MYSQLSERVER -E -Q "SELECT top 10 * FROM mobile_schwarzkopf_HO.dbo.DS_Attributes" -b -o D:\FTP\HOPlus\test.txt'
--exec [Mobile_Schwarzkopf_HO_Plus].[sys].[xp_cmdshell]

exec xp_cmdshell 'bcp "mobile_schwarzkopf_HO.dbo.DS_Attributes" queryout D:\FTP\HOPlus\test.txt  -T -c -t "|"'