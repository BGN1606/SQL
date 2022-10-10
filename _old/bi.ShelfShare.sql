use [Mobile_Schwarzkopf_HO_Plus]
go

alter procedure bi_get_ShelfShare_data @date date = null

as

begin

----declare @date date = '20190101'
--declare @command varchar (max)

----Устанавливаем дату для всех отчетов
--update [Mobile_Schwarzkopf_HO_Plus].[dbo].[Everest_Settings]
--set val=isnull(@date,cast(getdate() as date))
--where id=1

---- Актуализация иерархии, не зависит от даты
--exec [Mobile_Schwarzkopf_HO_Plus].[dbo].[Everest_UpdateHierarchy]

---- Обновляем справочник
--exec [Mobile_Schwarzkopf_HO_Plus].[dbo].[Everest_GetEmployees]

---- Обновляем данные по доле полки
--exec [Mobile_Schwarzkopf_HO_Plus].[dbo].[Everest_GetShelfShare]


-- Забираем данные для интеграции в DB BI
select
  shelf.[Reportdate]		as [date],
  epname.[AttrValueName]	as [account_name],
  epname.[exid]				as [account_id],
  client.[MasterPointID]	as [point_id],
  shelf.[Category]			as [category],
  avg(shelf.[Share])		as [share],
  avg(shelf.[Planned])		as [plan],
  avg(shelf.[Result])		as [fact]

from [Mobile_Schwarzkopf_HO_Plus].[dbo].[Everest_ShelfShareTT]  shelf

join [Mobile_Schwarzkopf_HO_Plus].[dbo].[vSlave2MasterPointMapping] client with (nolock)
  on shelf.[TT] = client.[SlavePointId]

left join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes_History] chain_data with (nolock)
  on shelf.[TT] = chain_data.[Id]
 and shelf.[Reportdate] between chain_data.[StartDate] and chain_data.[EndDate]
 and chain_data.[ActiveFlag] = 1
 and chain_data.[AttrId] = 687
 and chain_data.[DictId] = 2

left join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes_History] ep with (nolock)
  on chain_data.[AttrValueId] = ep.[Id]
 and shelf.[Reportdate] between ep.[StartDate] and ep.[EndDate]
 and ep.[ActiveFlag] = 1
 and ep.[AttrId] = 3039
 and ep.[DictId] = 5

join [Mobile_Schwarzkopf_HO].[dbo].[DS_AttributesValues] epname with (nolock)
  on ep.[AttrValueId] = epname.[AttrValueID]

group by
  shelf.[Reportdate],
  epname.[AttrValueName],
  epname.[exid],
  client.[MasterPointID],
  shelf.[Category]

end