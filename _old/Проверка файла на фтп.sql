USE Schwarzkopf
if (select count(AttrID) from DMT_Set_AttributeValueEx)>0
	begin
		Print '��������� ���� DMT_Set_AttributeValueEx.txt'	
		EXEC xp_cmdShell 'BCP "select * from Schwarzkopf.dbo.DMT_Set_AttributeValueEx" queryout D:\Transfer\AMS_Checks\DMT_Set_AttributeValueEx.txt -T -c -t "|" -C Win1251'
	end
else
	begin
		PRINT '������ �� ����������, ����������� ������'
	goto eof
	end

DECLARE @output INT

EXEC @output = [ftphbcho.cdc.ru].[master].[dbo].XP_CMDSHELL 'DIR "d:\ftp\schwarzho\DMT_Set_AttributeValue*.txt" /B', NO_OUTPUT

IF @output = 1
	begin
		PRINT 'DMT_Set_AttributeValue.txt �� FTP �� ���������, ���������� ����...'
		exec FTP_MPUT N'D:\Transfer\AMS_Checks', N'DMT_Set_AttributeValueex.txt'
	end
ELSE
	begin
		PRINT 'DMT_Set_AttributeValue.txt ���� �� FTP, ���������� ������'
		EXEC msdb.dbo.sp_send_dbmail
			@recipients = 'alexander.volkov@henkel.com;boris.gevorkyan@hotmail.com', 
			@subject = N'WARNING: AMS-DMS: EP, �� ������� ���� DMT_Set_AttributeValueEx.txt',
			@body = N'������ ���� ������������ �������������',
			@body_format = 'HTML',
			@file_attachments ='D:\Transfer\AMS_Checks\DMT_Set_AttributeValueEx.txt',
			@profile_name = 'Report_Mail'
	end
eof:
