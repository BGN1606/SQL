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

EXEC master.dbo.sp_serveroption
     @server=DB
       , @optname=N'remote proc transaction promotion'
       , @optvalue=N'false'