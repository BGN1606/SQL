use Mobile_Schwarzkopf_HO

select distinct
  av.exid 
 ,av.AttrValueID
 ,av.[AttrValueName]
 ,count(oba.[Id]) SKU_Count
from DS_ObjectsAttributes oba

join DS_AttributesValues av
  on oba.AttrId=av.AttrID
 and oba.AttrValueId=av.AttrValueID
 and av.Activeflag=1

where oba.Activeflag=1
  and oba.DictId=1
  and oba.AttrID=627

group by
  av.exid 
 ,av.AttrValueID
 ,av.[AttrValueName]
--having count(oba.[Id])<10