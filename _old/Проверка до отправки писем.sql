USE Schwarzkopf
DECLARE 
  @dval nvarchar(max) = 'Mobile_Schwarzkopf_AlyansEkbrg',
  @rval nvarchar(max) = 'SalesVerification',
  @dkey nvarchar(max), 
  @rkey nvarchar(max),
  @cmd nvarchar(2048),
  @rcp nvarchar(256)

EXEC getkey @dval, @rval, @dkey=@dkey OUTPUT, @rkey=@rkey OUTPUT

SET @cmd = CONCAT('BCP "EXEC [Reporting].[dbo].[dms_SalesVerification] ''',@dkey,''',''',@rkey,'''" queryout D:\Transfer\DS_SalesVerificationRep\',@dval,'.csv -T -c -R -t ";" -C Win1251' )

EXEC xp_cmdShell @cmd

SET @rcp = (SELECT CONCAT([DA_mail],'; ',[it_mail],';',[dc_mail]) 
            FROM [Schwarzkopf].[dbo].[contactlist] c
            JOIN [Schwarzkopf].[dbo].[dblist] d
			  ON c.country=d.Country
			 AND c.fid=d.fid
			WHERE d.name=@dval)


IF  @rcp is null
   BEGIN
        PRINT (@rcp)--(EXEC [Reporting].[dbo].[dms_SalesVerification] @dkey,@rkey)
        GOTO eof
   END
ELSE PRINT ('!!!!')
    --EXEC('
    --	EXEC msdb.dbo.sp_send_dbmail 
    --	@recipients = N'''+ @rcp +''',
    --	@subject = N''Автоматическая сверка продаж дистрибьютора "'+ @dval +'"'',
    --	@body = N''Данное письмо сформировано автоматически и содержит в себе результат сверки продаж между ВАРМ и КИС(Report.txt).'',
    --	@body_format = ''HTML'',
    --	@file_attachments =''D:\Transfer\DS_SalesVerificationRep\' + @dval + '.csv'',
    --	@copy_recipients =''dmitrij.chernov@henkel.com'',
    --	@profile_name = ''Report_Mail''
    --	')
	eof:
	    PRINT ('???')