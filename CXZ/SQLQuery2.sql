use mdm
go

--truncate table dbo.mdm_InvoiceSellThroughRow
--go

--delete dbo.mdm_InvoiceSellThrough
--go

--dbcc checkident ('mdm_InvoiceSellThroughRow', reseed)
--go

--dbcc checkident ('mdm_InvoiceSellThrough', reseed, 0)
--go


--exec mdm_sync_InvoiceSellThrough @start_date = '20140101', @end_date = '20141231'
--exec mdm_sync_InvoiceSellThrough @start_date = '20150101', @end_date = '20151231'
--exec mdm_sync_InvoiceSellThrough @start_date = '20160101', @end_date = '20161231'
--exec mdm_sync_InvoiceSellThrough @start_date = '20170101', @end_date = '20171231'
--exec mdm_sync_InvoiceSellThrough @start_date = '20180101', @end_date = '20181231'
--exec mdm_sync_InvoiceSellThrough @start_date = '20190101', @end_date = '20191231'
--exec mdm_sync_InvoiceSellThrough @start_date = '20200101', @end_date = '20201231'
--exec mdm_sync_InvoiceSellThrough @start_date = '20210101', @end_date = '20211231'
--exec mdm_sync_InvoiceSellThrough @start_date = '20220101', @end_date = '20221231'

--exec mdm_sync_InvoiceSellThroughRow @start_date = '20140101', @end_date = '20141231'
--exec mdm_sync_InvoiceSellThroughRow @start_date = '20150101', @end_date = '20151231'
--exec mdm_sync_InvoiceSellThroughRow @start_date = '20220101', @end_date = '20221231'
--exec mdm_sync_InvoiceSellThroughRow @start_date = '20210101', @end_date = '20211231'
--exec mdm_sync_InvoiceSellThroughRow @start_date = '20200101', @end_date = '20201231'
--exec mdm_sync_InvoiceSellThroughRow @start_date = '20160101', @end_date = '20161231'
--exec mdm_sync_InvoiceSellThroughRow @start_date = '20170101', @end_date = '20171231'
--exec mdm_sync_InvoiceSellThroughRow @start_date = '20180101', @end_date = '20181231'
--exec mdm_sync_InvoiceSellThroughRow @start_date = '20190101', @end_date = '20191231'






---- SellThrough
----exec mdm_sync_InvoiceSellThrough @start_date = null, @end_date = null


----DBCC CHECKIDENT ('mdm_invoicesellthrough', NORESEED)

