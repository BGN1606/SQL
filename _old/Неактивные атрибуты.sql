use Mobile_Schwarzkopf_HO

select distinct
  oba.[AttrId]
 ,oba.DictId
 ,oba.[Id]
 ,oba.[AttrValueId]
 ,av.[AttrValueName]
 --,oba.[OwnerDistID]
from DS_ObjectsAttributes oba
join DS_AttributesValues av
  on oba.AttrId=av.AttrID
 and oba.AttrValueId=av.AttrValueID
 and av.Activeflag=0
where oba.Activeflag=1
  and oba.DictId=1
  and oba.AttrID not in (select AttrId from DS_ObjectsAttributes_History)
order by 1,2