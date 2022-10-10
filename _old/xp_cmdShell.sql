USE Schwarzkopf
IF (SELECT COUNT(*) FROM [FTPHBCHO.CDC.RU].[Mobile_Schwarzkopf_HO_Plus].[dbo].[DS_TrgtLstngReport])>0 BEGIN
EXEC xp_cmdShell 'bcp "SELECT [YEAR],[MONTH],[NET_HQ],[REGION],[GKAM],[RKAM],[KAM\SKAM],[LKAM\RSE],[JKAM],[FAM_ExId],[FAM],[TRADE_CHANNEL],[CATIGORY],[BRAND],[EAN],[PROD_NAME],[LNCH_RNCH_DLSTD_STATUS],[LNCH_RNCH_DLSTD_DATE],[KPI_Flag],[Target],[LS],[RESULT_1],[RESULT_2],[RESULT_3] FROM [FTPHBCHO.CDC.RU].[Mobile_Schwarzkopf_HO_Plus].[dbo].[DS_TrgtLstngReport]" queryout C:\Transfer\DS_TrgtLstngReport.txt -T -c -t "|" -C Win1251', no_output
EXEC ftp_mput N'C:\Transfer\',N'DS_TrgtLstngReport.txt'
END;