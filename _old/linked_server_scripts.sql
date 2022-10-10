
/*�������� �����*/
USE [master]  
GO  
EXEC master.dbo.sp_addlinkedserver   
    @server = N'DB',   
    @srvproduct=N'AMS_DB',
	@provider = N'SQLNCLI',
	@datasrc = N'192.168.100.103'
	;  
GO 

/*��������� ��������� ������ ��� ������������� ������� ������ ������ ��� ����� �����, ������� ���������� ��������� ������.*/
EXEC master.dbo.sp_addlinkedsrvlogin   
    @rmtsrvname = N'DBDEV',   
    @locallogin = NULL ,   
    @useself = N'True' ;  
GO 

/*�������� RPC*/

EXEC master.dbo.sp_serveroption
     @server=[FTPHBCHO.CDC.RU]
       , @optname=N'remote proc transaction promotion'
       , @optvalue=N'false'


/*�������� �������� linkedServer*/       
SELECT
          srv.name AS [Name]
        , CAST(srv.server_id AS int) AS [ID]
        , product
        , data_source
        , srv.modify_date AS [DateLastModified]
        , srv.is_remote_proc_transaction_promotion_enabled
        , CAST(srv.is_remote_proc_transaction_promotion_enabled AS bit)
            AS [IsPromotionofDistributedTransactionsForRPCEnabled]
        , srv.provider_string AS [ProviderStringIn]
FROM sys.servers AS srv
