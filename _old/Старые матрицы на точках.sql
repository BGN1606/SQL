use Mobile_Schwarzkopf_HO

if OBJECT_ID('tempdb..#tmp1') is not null
drop table #tmp1

SELECT distinct h1.OwnerDistID, h1.id,h1.AttrValueId,h1.RecordId,h1.AttrText
into #tmp1
FROM [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes_History] h1
join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes_History]h2
  on h1.id=h2.Id
  and h2.AttrId=627
  and h2.ActiveFlag=1
  and h1.OwnerDistID=h2.OwnerDistID
where h1.AttrId=627
  and h1.ActiveFlag=1
  and h1.DictId=2
  and h1.OwnerDistID=3
group by h1.OwnerDistID,h1.id,h1.AttrValueId,h1.RecordId,h1.AttrText
having 
 h1.RecordId = case when 
    Max(h2.RecordId)-1 <1 then 1
	else Max(h2.RecordId)-1
	end 
 


select
  fid,
  exid,
  fName,
  fAddress,
  oa.AttrValueId,
  oa.AttrText,
  oa2.AttrValueId,
  oa2.AttrText,
  t1.AttrText
  --COUNT(oa3.Id)
  --i.iidText
from [Mobile_Schwarzkopf_HO].[dbo].[DS_FACES] f

left join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes] oa
  on f.fID=oa.Id
 and oa.DictId=2
 and oa.AttrId=627
 and oa.Activeflag=1

left join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes] oa2
  on f.fID=oa2.Id
 and oa2.DictId=2
 and oa2.AttrId=2062
 and oa2.Activeflag=1

left join #tmp1 t1
  on f.fID=t1.Id
 and f.OwnerDistID=t1.OwnerDistID

where f.fType=7
  and f.OwnerDistID=3 
  and oa2.AttrId is null
  and f.fName not like '%Аюсс%'
  and f.fName not like '%Дубин%'
  and f.fName not like '%ЦИМУС%'