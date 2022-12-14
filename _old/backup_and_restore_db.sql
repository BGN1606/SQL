use [master]
go

backup database [Schwarzkopf] to  disk = N'D:\MSSQL13.VM1\MSSQL\Backup\Schwarzkopf.bak' with noformat, noinit,  name = N'Schwarzkopf-Full Database Backup', skip, norewind, nounload,  stats = 10
go

Restore filelistonly from disk ='D:\MSSQL13.VM1\MSSQL\Backup\Schwarzkopf.bak'
go

restore database Schwarzkopf_DEV
from disk = 'D:\MSSQL13.VM1\MSSQL\Backup\Schwarzkopf.bak'
with replace,
MOVE 'schwarzkopf' TO 'D:\MSSQL13.VM1\MSSQL\Backup\Schwarzkopf_DEV.mdf',
MOVE 'schwarzkopf_log' TO 'D:\MSSQL13.VM1\MSSQL\Backup\Schwarzkopf_DEV.ldf',
recovery --force