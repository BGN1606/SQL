USE [Schwarzkopf]
GO

/****** Object:  StoredProcedure [dbo].[ftp_mget]    Script Date: 01.11.2018 17:12:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Boris Gevorkyan>
-- Create date: <20170927>
-- Description:	<FTP_MGET>
-- Simple: USE HBCDMS EXECUTE FTP_MGET N'E:\FTP', N'DS_MATRIX.txt';
-- =============================================
CREATE PROCEDURE [dbo].[ftp_mget]
	@DestPath varchar(128),   
    @SourceFiles varchar(128)   
AS
	SET NOCOUNT ON;
DECLARE 
 @FTPServer varchar(128)='ftphbcho.cdc.ru',
 @FTPUser varchar(128)='clientHO',
 @FTPPwd varchar(128)='KDyMsa83',
 @SourcePath varchar(128)='HOPlus',
 @FTPMode varchar(10)='binary',
 @cmd varchar(1000),
 @workfile varchar(128),
 @nowstr varchar(25),
 @tempdir varchar(128)

-- Get the %TEMP% environment variable.
CREATE TABLE #tempvartable(info VARCHAR(1000))
INSERT #tempvartable EXEC master..xp_cmdshell 'echo %temp%'
SET @tempdir = (SELECT top 1 info FROM #tempvartable)
IF RIGHT(@tempdir, 1) <> '\' SET @tempdir = @tempdir + '\'
DROP TABLE #tempvartable

-- Generate @workfile
SET @nowstr = replace(replace(convert(varchar(30), GETDATE(), 121), ' ', '_'), ':', '-')
SET @workfile = 'FTP_SPID' + convert(varchar(128), @@spid) + '_' + @nowstr + '.txt'

-- Deal with special chars for echo commands.
select @FTPServer = replace(replace(replace(@FTPServer, '|', '^|'),'<','^<'),'>','^>')
select @FTPUser = replace(replace(replace(@FTPUser, '|', '^|'),'<','^<'),'>','^>')
select @FTPPwd = replace(replace(replace(@FTPPwd, '|', '^|'),'<','^<'),'>','^>')
select @SourcePath = replace(replace(replace(@SourcePath, '|', '^|'),'<','^<'),'>','^>')
IF RIGHT(@DestPath, 1) = '\' SET @DestPath = LEFT(@DestPath, LEN(@DestPath)-1)

-- Build the FTP script file.
select @cmd = 'echo ' + 'open ' + @FTPServer + ' > ' + @tempdir + @workfile
EXEC master..xp_cmdshell @cmd, no_output
select @cmd = 'echo ' + @FTPUser + '>> ' + @tempdir + @workfile
EXEC master..xp_cmdshell @cmd, no_output
select @cmd = 'echo ' + @FTPPwd + '>> ' + @tempdir + @workfile
EXEC master..xp_cmdshell @cmd, no_output
select @cmd = 'echo ' + 'prompt ' + ' >> ' + @tempdir + @workfile
EXEC master..xp_cmdshell @cmd, no_output
IF LEN(@FTPMode) > 0
BEGIN
	select @cmd = 'echo ' + @FTPMode + ' >> ' + @tempdir + @workfile
	EXEC master..xp_cmdshell @cmd, no_output
END
select @cmd = 'echo ' + 'lcd ' + @DestPath + ' >> ' + @tempdir + @workfile
EXEC master..xp_cmdshell @cmd, no_output
IF LEN(@SourcePath) > 0
BEGIN
	select @cmd = 'echo ' + 'cd ' + @SourcePath + ' >> ' + @tempdir + @workfile
	EXEC master..xp_cmdshell @cmd, no_output
END
select @cmd = 'echo ' + 'mget ' + @SourceFiles + ' >> ' + @tempdir + @workfile
EXEC master..xp_cmdshell @cmd, no_output
select @cmd = 'echo ' + 'quit' + ' >> ' + @tempdir + @workfile
EXEC master..xp_cmdshell @cmd, no_output

-- Execute the FTP command via script file.
select @cmd = 'ftp -s:' + @tempdir + @workfile
create table #a (id int identity(1,1), s varchar(1000))
insert #a
EXEC master..xp_cmdshell @cmd, no_output
select id, ouputtmp = s from #a

-- Clean up.
drop table #a
select @cmd = 'del ' + @tempdir + @workfile
EXEC master..xp_cmdshell @cmd, no_output
GO