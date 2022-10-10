use Mobile_Schwarzkopf_HO_Plus
go

create view bi_product
as

select distinct
  lower(items.[iName])			as [name],
  items.[iidText]				as [ean],
  category.[AttrValueId]		as [category_id],
  category_name.[AttrValueName]	as [category_name],
  brand.[AttrValueId]			as [brand_id],
  brand_name.[AttrValueName]	as [brand_name]

from [Mobile_Schwarzkopf_HO].[dbo].[DS_ITEMS] items with (nolock)

join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes] category with (nolock)
  on items.[iID] = category.[Id]
 and category.[Activeflag] = 1
 and category.[AttrId] = 661

join [Mobile_Schwarzkopf_HO].[dbo].[DS_AttributesValues] category_name with (nolock)
  on category.[AttrValueId] = category_name.[AttrValueId]

join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes] brand with (nolock)
  on items.[iID] = brand.[Id]
 and brand.[Activeflag] = 1
 and brand.[AttrId] = 665

join [Mobile_Schwarzkopf_HO].[dbo].[DS_AttributesValues] brand_name with (nolock)
  on brand.[AttrValueId] = brand_name.[AttrValueId]

where items.[activeFlag] = 1
  and items.[iID] in (select [iID] from [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders_Items] oritems with (nolock))
