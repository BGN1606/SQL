/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT TOP 1000 [LogRecordID]
--      ,[MasterfID]
--      ,[ActionID]
--      ,[LogID]
--      ,[LogDate]
--      ,[ActionTypeID]
--      ,[ObjectID]
--      ,[DopField]
--      ,[Comment]
--      ,[UserID]
--      ,[UserName]
--      ,[OwnerDistID]
--      ,[DistID]
--      ,[ChangeDate]
--      ,[LoginName]
--      ,[fState]
--      ,[guid]
--  FROM [Mobile_Schwarzkopf_HO].[dbo].[DS_ActionsLog]
--  where Comment like ('%синхр%')

Select fid, fname, ldate FROM [Mobile_Schwarzkopf_HO].[dbo].[DS_FACES]
join 
(select MasterfID, max(logdate) ldate from DS_ActionsLog
WHERE MasterfID in (select masterfid from mobiles) AND Comment='Запуск Синхронизации'
group by masterfid 
/*having  max(logdate) <= '2017-01-01 23:59:59.999'*/) A1 on A1.MasterfID = fID
where left(fID,2) = 92 and fid = 92008018

