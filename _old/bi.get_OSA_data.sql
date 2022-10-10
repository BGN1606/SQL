use [Mobile_Schwarzkopf_HO_Plus]
go

declare
  @date date = '20200101',
  @startdate date, 
  @enddate date

set @startdate = @date
set @enddate = eomonth(@date)

begin

---- ƒистрибьюци€ и OSA

;with 

matrix as ( -- —обираем данные по матрицам на первое число выбранного мес€ца @date
  select distinct
    field_matrix.[Id]		as [point_id],
    matrix_items.[Id]		as [product_id]
  
  from [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes_History] field_matrix with (nolock)
  
  join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes_History] matrix_items with (nolock)
    on field_matrix.[AttrValueId] = matrix_items.[AttrValueId]
   and @date between matrix_items.[StartDate] and matrix_items.[EndDate]
   and matrix_items.[DictId] = 1
   and matrix_items.[AttrId] = 627
   and matrix_items.[ActiveFlag] = 1
  
  where field_matrix.[AttrId] = 627
    and @date between field_matrix.[StartDate] and field_matrix.[EndDate]
    and field_matrix.[DictId] = 2
    and field_matrix.[ActiveFlag] = 1
),

osa_doc_count as ( -- считаем кол-во всех документов сделанных на торговую точку в отчетном мес€це

  select
    orders.[mfID]					as [point_id],
	count(distinct orders.[orID])	as [doc_count]

  from [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders] orders with (nolock)
 
  where cast(orders.[orDate] as date) between @startdate and @enddate
    and orders.[Condition] = 1
    and orders.orType in (201)

  group by
    orders.[mfID]
),

osa_data as ( -- считаем сколько раз каждый продукт был отмечен в документах в отчетном мес€це

  select
    orders.[mfID]										as [point_id],
	orobjects.[Id]										as [product_id],
    sum(convert(int, orobjects.[AttrText]))				as [is_on-shelf_count]

  from [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders] orders with (nolock)
  
  join [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders_Objects_Attributes] orobjects with (nolock)
    on orders.[OwnerDistID] = orobjects.[OwnerDistId]
    and orders.[MasterFID] = orobjects.[MasterFid]
    and orders.[orID] = orobjects.[OrId]
    and orobjects.[AttrId] = 701 -- ƒистрибьюци€
    and orobjects.[AttrText] = '1'
    and orobjects.[DictId] = 1
    and orobjects.[ActiveFlag] = 1
  
  where cast(orders.[orDate] as date) between @startdate and @enddate
    and orders.[Condition] = 1
    and orders.orType in (201)
    
  group by
    orders.[mfID],
	orobjects.[Id]
),
osa as ( -- —обираем в единую базу и матрицы и дистрибьюцию

  select 
    matrix.[point_id],
    matrix.[product_id],
    osa.[is_on-shelf_count]
  from matrix
  
  left join osa_data osa
    on matrix.[point_id] = osa.[point_id]
   and matrix.[product_id] = osa.[product_id]
  
   union all
  
  select
    osa.[point_id],
    osa.[product_id],
    osa.[is_on-shelf_count]
  from osa_data osa
  
  left join matrix
    on osa.[point_id] = matrix.[point_id]
   and osa.[product_id] = matrix.[product_id]
  
  where matrix.[product_id] is null
)

-- ќбогощаем даннные атрибутами, объедин€ем точки с площадки мерчей и родительские точки, приводим в дружелюбный вид

select
  @date										as [date],
  epname.[AttrValueName]					as [ep_name],
  epname.[exid]								as [ep_id],
  client.[MasterPointID]					as [point_id],
  sum(osa_doc_count.[doc_count])			as [doc_count],
  items.[iidText]							as [ean],
  items.[iName]								as [product_name],
  sum(osa.[is_on-shelf_count])	as [is_on-shelf_count]

from osa

left join osa_doc_count
  on osa.[point_id] = osa_doc_count.[point_id]

join [Mobile_Schwarzkopf_HO_Plus].[dbo].[vSlave2MasterPointMapping] client with (nolock)
  on osa.[point_id] = client.[SlavePointId]

join [Mobile_Schwarzkopf_HO].[dbo].[DS_ITEMS] items with (nolock)
  on osa.[product_Id] = items.[iID]

left join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes_History] chain_data with (nolock)
  on osa.[point_id] = chain_data.[Id]
 and @date between chain_data.[StartDate] and chain_data.[EndDate]
 and chain_data.[DictId] = 2
 and chain_data.[AttrId] = 687
 and chain_data.[ActiveFlag] = 1

join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes_History] ep with (nolock)
  on chain_data.[AttrValueId] = ep.[Id]
 and @date between ep.[StartDate] and ep.[EndDate]
 and ep.[DictId] = 5
 and ep.[AttrId] = 3039
 and ep.[ActiveFlag] = 1

join [Mobile_Schwarzkopf_HO].[dbo].[DS_AttributesValues] epname with (nolock)
  on ep.[AttrValueId] = epname.[AttrValueID]

group by
  epname.[AttrValueName],
  epname.[exid],
  client.[MasterPointID],
  items.[iidText],
  items.[iName]

option (recompile)

end