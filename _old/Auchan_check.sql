use [Mobile_Schwarzkopf_HO_Plus]
go

;with fam as (
		
		select distinct
		  fam.[AttrValueId]   as [fam_id],
		  fam.[id],
		  fam.[StartDate],
		  fam.[EndDate]
		from [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes_History] fam with (nolock)

		where [AttrId] = 3061
		  and [DictId] = 2
		  and [ActiveFlag] = 1
)  

select
  fam.*,
  fact.[orDate],
  fact.[orID],
  fact.[MasterFID],
  oritems.[iID],
  fact2.[Amount] as [dwh_Amount]

from fam

left join [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders] fact with (nolock)
  on fam.[Id] = fact.[mfID]
 and fact.[orType] = 677
 and [orDate] >= '20200101'
 and [Condition] = 1

left join [Mobile_Schwarzkopf_HO].[dbo].[DS_Orders_Items] oritems with (nolock)
  on fact.[OwnerDistID] = oritems.[OwnerDistID]
 and fact.[orID] = oritems.[orID]
 and fact.[MasterFID] = oritems.[MasterFID]


left join [DW_M_SCHWARZKOPF].[dbo].[V_FactOrders_2020] fact2 with (nolock)
  on fam.[Id] = fact2.[mfID]

where fam_id in (498959, 499412, 499413) --(Auchan_Hyper, Auchan_City_3000, Auchan_City_5000)