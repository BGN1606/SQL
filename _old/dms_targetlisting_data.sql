USE [Mobile_Schwarzkopf_HO_Plus]
GO

/****** Object:  StoredProcedure [dbo].[dms_targetlisting_data]    Script Date: 24.04.2020 12:29:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER procedure [dbo].[dms_targetlisting_data]  @reportdate as date

as

begin

declare
  --@reportdate as date = '20200401',
  @sdate datetime,
  @cutdate datetime,
  @edate datetime

set @sdate = dateadd(mm,-5,@reportdate)
set @cutdate = dateadd(mm, +3, @sdate)
set @edate = eomonth(@reportdate)

print('Параметры отчета:')
print(concat('StartDate = ', convert(varchar,@sdate,121)))
print(concat('CutDate = ', convert(varchar,@cutdate,121)))
print(concat('EndDate = ', convert(varchar,@edate,121)))
print('')


--  < Блок 1: Формирование фактов >
print(convert(varchar,getdate(),121) + ': Начинаем формирование фактов')

if object_id('tempdb..#fact') is not null drop table #fact
create table #fact
    (
	 [date] date not null,
     [mfid] int not null,
     [iid] int not null,
	 [con] decimal(19,9) not null,
	 [ges] decimal(19,9) not null
    )

insert into #fact
select
  dateadd(mm, datediff(mm, 0, [Date00]), 0),
  [mfID],
  [iID],
  sum([Amount]),
  sum(isnull([GES], 0))
  
from [DW_M_SCHWARZKOPF].[dbo].[V_FactOrders] with (nolock)

where [Date00] between @sdate and @edate
  and [orType] in (677, 2)
  and [Amount] > 0

group by
  dateadd(mm, datediff(mm, 0, [Date00]), 0),
  [mfID],
  [iID]

option (recompile)
print(convert(varchar,getdate(),121) + ': Завершили формирование фактов');
--  < Блок 1: Формирование фактов />


--  < Блок 2: Формирование атрибутов >
print(convert(varchar,getdate(),121) + ': Начинаем формирование атрибутов')

if object_id('tempdb..#attribute') is not null drop table #attribute
create table #attribute
    (
     exid varchar(50) not null,
     id int not null
    )

;with dc as 
    (
     select [id]
     from [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes_History]
     where [AttrId] = 680
       and [AttrText] = 1
       and [ActiveFlag] = 1
       and @reportdate between cast([StartDate] as date ) and cast([EndDate] as date)
    )
	
insert into #attribute
select distinct
  av.[exid],
  oh.[Id]
  
from [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes_History] oh with (nolock)

join [Mobile_Schwarzkopf_HO].[dbo].[DS_AttributesValues] av with (nolock)
  on oh.[AttrId] = av.[AttrID]
 and oh.[AttrValueId] = av.[AttrValueID]

where oh.[AttrId] = 3061
  and OwnerDistID <> 92
  and oh.[DictId] = 2
  and oh.[ActiveFlag] = 1
  and @reportdate between cast(oh.[StartDate] as date ) and cast(oh.[EndDate] as date) 
  and oh.[Id] not in (select id from dc)

print(convert(varchar,getdate(),121) + ': Завершили формирование атрибутов')
--  < Блок 2: Формирование атрибутов />


--  < Блок 3: Определяем продажи на торг. точках >
print(convert(varchar,getdate(),121) + ': Начинаем определение продаж на торг. точках')

if object_id('dms_targetlisting_invoice', 'U') is not null drop table dms_targetlisting_invoice
create table dms_targetlisting_invoice
  (
   [exid] varchar(50) not null,
   [ean] varchar(50) not null,
   [sth_store_3month] decimal (19,9) not null,
   [sth_store_6month] decimal (19,9) not null,
   [sth_con_3month] decimal (19,9) not null,
   [sth_con_6month] decimal (19,9) not null,
   [sth_ges_3month] decimal (19,9) not null,
   [sth_ges_6month] decimal (19,9) not null
  )

;with Sth3Mth as 
	(
	select
	  attr.[exid],
	  i.[iidText]					as [ean],
	  count(distinct(fact.[mfid]))	as [sth_store_3month],
	  null							as [sth_store_6month],
	  sum(con)						as [sth_con_3month],
	  null							as [sth_con_6month],
	  sum(ges)						as [sth_ges_3month],
	  null							as [sth_ges_6month]
	
	from #fact fact
	
	join #attribute attr
	  on attr.[id] = fact.[mfid]
	
	join [Mobile_Schwarzkopf_HO].[dbo].[ds_items] i
	  on fact.[iid] = i.[iID]
	
	where fact.[date] between @cutdate and @edate
	
	group by
	  attr.[exid],
	  i.[iidText]
	),
Sth6Mth as
	(
	select
	  attr.[exid]					as [exid],
	  i.[iidText]					as [ean],
	  null							as [sth_store_3month],
	  count(distinct(fact.[mfid]))	as [sth_store_6month],
	  null							as [sth_con_3month],
	  sum(con)						as [sth_con_6month],
	  null							as [sth_ges_3month],
	  sum(ges)						as [sth_ges_6month]
	
	from #fact fact
	
	join #attribute attr
	  on attr.[id] = fact.[mfid]
	
	join [Mobile_Schwarzkopf_HO].[dbo].[ds_items] i
	  on fact.[iid] = i.[iID]
	
	where fact.[date] between @sdate and @edate
	
	group by
	  attr.[exid],
	  i.[iidText]
	)
	
insert into dms_targetlisting_invoice
select
  [exid],
  [ean],
  sum(isnull([sth_store_3month], 0)),
  sum(isnull([sth_store_6month], 0)),
  sum(isnull([sth_con_3month], 0)),
  sum(isnull([sth_con_6month], 0)),
  sum(isnull([sth_ges_3month], 0)),
  sum(isnull([sth_ges_6month], 0))

from (
	select * from Sth3Mth
	union all
	select * from Sth6Mth
	) as temp

group by
  [exid],
  [ean]

print(convert(varchar,getdate(),121) + ': Завершили определение продаж на торг. точках')
--  < Блок 3: Определяем продажи на торг. точках />


--  < Блок 4: Определяем off-take на торг. точках >
print(convert(varchar,getdate(),121) + ': Начинаем определение off-take на торг. точках')

if object_id('dms_targetlisting_offtake', 'U') is not null drop table  dms_targetlisting_offtake
create table dms_targetlisting_offtake
  (
   [exid] varchar(50) not null,
   [ean] varchar(50) not null,
   [point_count] int not null
  )

insert into dms_targetlisting_offtake
select distinct
  attr.[exid],
  i.[iidText],
  count(distinct(o.[mfID]))
from [Mobile_Schwarzkopf_HO].[dbo].[ds_orders] o with (nolock)

join [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders_Items] oi with (nolock)
  on o.[OwnerDistID] = oi.[OwnerDistID]
 and o.[orID] = oi.[orID]
 and o.[MasterFID] = oi.[MasterFID]

join [Mobile_Schwarzkopf_HO].[dbo].[ds_items] i with (nolock)
  on oi.[iID] = i.[iID]

join #attribute attr
  on o.[mfID] = attr.[id]

where o.[orDate] between @cutdate and @edate
  and o.[Condition] = 1
  and o.[orType] in (1621)

group by
  attr.[exid],
  i.[iidText]

print(convert(varchar,getdate(),121) + ': Завершили определение off-take на торг. точках')
--  < Блок 4: Определяем off-take на торг. точках />

--  < Блок 5: Определяем osa на торг. точках с площадок >
print(convert(varchar,getdate(),121) + ': Начинаем определение osa на торг. точках с площадок')

if object_id('tempdb..#osa') is not null drop table #osa
create table #osa
  (
   [exid] varchar(50) not null,
   [mfid] int not null,
   [ean] varchar(50) not null
  )

insert into #osa
select
  attr.[exid],
  o.[mfID],
  i.[iidText]
from [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders] o with (nolock)

join [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders_Objects_Attributes] oa with (nolock)
  on o.[OwnerDistID] = oa.[OwnerDistId]
 and o.[MasterFID] = oa.[MasterFid] 
 and o.[orID] = oa.[OrId] 
 and oa.[ActiveFlag] = 1
 and oa.[AttrText] = 1
 and oa.[AttrId] = 701

join [Mobile_Schwarzkopf_HO].[dbo].[DS_ITEMS] i with (nolock)
  on oa.[Id] = i.[iID]

join #attribute attr
  on attr.[id] = o.[mfID]

where o.[orDate] between @cutdate and @edate
  and o.[Condition] = 1
  and o.[orType] = 201

print(convert(varchar,getdate(),121) + ': Завершили определение osa на торг. точках с площадок')
--  < Блок 5: Определяем osa на торг. точках с площадок />


--  < Блок 6: Определяем osa на торг. точках с площадки мерч >
print(convert(varchar,getdate(),121) + ': Начинаем определение osa на торг. точках с площадки мерч')

;with merch as 
    (
     select
       fID,
       cast(replace ([exid],'transfer_','') as int) as pId
     from [Mobile_Schwarzkopf_HO].[dbo].[ds_faces] with (nolock)
     where OwnerDistID = 92
       and exid like 'Transfer_%'
       and isnumeric(replace(exid,'transfer_','')) = 1
    ),
osa_merch as
    (
     select
       attr.[exid],
       m.[pId] as [mfid],
       i.[iidText] as [ean]
     from [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders] o with (nolock)
     
     join [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders_Objects_Attributes] oa with (nolock)
       on o.[OwnerDistID] = oa.[OwnerDistId]
      and o.[MasterFID] = oa.[MasterFid] 
      and o.[orID] = oa.[OrId] 
      and oa.[ActiveFlag] = 1
      and oa.[AttrText] = 1
      and oa.[AttrId] = 701
     
     join [Mobile_Schwarzkopf_HO].[dbo].[DS_ITEMS] i with (nolock)
       on oa.[Id] = i.[iID]
     
     join merch m
       on o.[mfID] = m.[fID]
     
     join #attribute attr
       on m.[pId] = attr.[id]
     
     where o.[orDate] between @cutdate and @edate
       and o.[Condition] = 1
       and o.[orType] = 201
     
     group by
       attr.[exid],
       m.[pId],
       i.[iidText]
    )

merge #osa as target  
using osa_merch as source 
   on (target.[mfid] = source.[mfid]
  and  target.[ean] = source.[ean]
      )
when not matched then
  insert ([exid], [mfid], [ean])  
  values (source.[exid], source.[mfid], source.[ean]);

print(convert(varchar,getdate(),121) + ': Завершили определение osa на торг. точках с площадки мерч')
--  < Блок 6: Определяем osa на торг. точках с площадки мерч />


--  < Блок 7: Объединяем показатели osa >
print(convert(varchar,getdate(),121) + ': Начинаем объединение показателя osa на торг. точках')

if object_id('dms_targetlisting_osa', 'U') is not null drop table dms_targetlisting_osa
create table dms_targetlisting_osa
  (
   [exid] varchar(50) not null,
   [ean] varchar(50) not null,
   [point_count] int not null
  )

insert into dms_targetlisting_osa
select
  [exid],
  [ean],
  count(distinct([mfID]))
from #osa
group by
  [exid],
  [ean]

print(convert(varchar,getdate(),121) + ': Завершили объединение показателя osa на торг. точках')
--  < Блок 7: Объединяем показатели osa />


--  < Блок 8: Определяем кол-во всего торговых точек привязанных к фам >
print(convert(varchar,getdate(),121) + ': Начинаем определение кол-во всего торговых точек привязанных к фам')

if object_id('dms_targetlisting_attribute', 'U') is not null drop table dms_targetlisting_attribute
create table dms_targetlisting_attribute
  (
   [exid] varchar(50) not null,
   [point_count] int not null
  )

insert into dms_targetlisting_attribute
select
  [exid],
  count(distinct([id]))
from #attribute
group by
  [exid]

print(convert(varchar,getdate(),121) + ': Завершили определение кол-во всего торговых точек привязанных к фам')
--  < Блок 8: Определяем кол-во всего торговых точек привязанных к фам />

end
GO
