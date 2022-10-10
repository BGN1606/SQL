--select * from DS_Forest where treeid=14 and dictid=2 and id=2000042 and ActiveFlag=1 -- 
--select * from ds_forest where treeid=14 and guid=2409309 -- 
--select * from DS_Forest_Nodes where nodeid=2000004 -- 



----
--select * from ds_forest where treeid=16 and dictid=7 and id=2000004 -- Находим территорию в другом дереве
--select * from ds_forest where treeid=16 and father = 2000007 -- 



--***************** территории
--select 
--f8.guid, n8.NodeName , f8.Father
--,f7.guid, n7.NodeName , f7.Father
--,f6.guid, n6.NodeName , f6.Father
--,f5.guid, n5.NodeName , f5.Father
--from ds_forest f8
--join DS_Forest_Nodes n8 on f8.id=n8.NodeID

--join DS_Forest f7
--on f7.guid = f8.Father

--and f7.TreeID = f8.TreeID
--join DS_Forest_Nodes n7 on f7.id=n7.NodeID

--join DS_Forest f6
--on f6.guid = f7.Father
--and f6.TreeID = f7.TreeID
--join DS_Forest_Nodes n6 on f6.id=n6.NodeID

--join DS_Forest f5
--on f5.guid = f6.Father
--and f5.TreeID = f6.TreeID
--join DS_Forest_Nodes n5 on f5.id=n5.NodeID

--where f8.guid=2409309 and f8.TreeID=14 and f8.ActiveFlag=1

--**** сотрудники

select 
f8.guid, n8.NodeName , f8.Father, tp8.fname
,f7.guid, n7.NodeName , f7.Father, tp7.fname
,f6.guid, n6.NodeName , f6.Father
,f5.guid, n5.NodeName , f5.Father
from ds_forest f8
join DS_Forest_Nodes n8 on f8.id=n8.NodeID
join DS_Forest terr8
on terr8.TreeID=16 and terr8.DictID=f8.dictid and terr8.id = f8.id
join ds_forest terr_tp8
on terr_tp8.treeid = terr8.TreeID and terr_tp8.Father=terr8.guid
join DS_FACES tp8
on tp8.fid = terr_tp8.Id

join DS_Forest f7
on f7.guid = f8.Father
and f7.TreeID = f8.TreeID
join DS_Forest_Nodes n7 on f7.id=n7.NodeID
join DS_Forest terr7
on terr7.TreeID=15 and terr7.DictID=f7.dictid and terr7.id = f7.id
join ds_forest terr_tp7
on terr_tp7.treeid = terr7.TreeID and terr_tp7.Father=terr7.guid
join DS_FACES tp7
on tp7.fid = terr_tp7.Id

join DS_Forest f6
on f6.guid = f7.Father
and f6.TreeID = f7.TreeID
join DS_Forest_Nodes n6 on f6.id=n6.NodeID

join DS_Forest f5
on f5.guid = f6.Father
and f5.TreeID = f6.TreeID
join DS_Forest_Nodes n5 on f5.id=n5.NodeID

where f8.guid=2409309 and f8.TreeID=14 and f8.ActiveFlag=1

----******* Нас пункт.
--SELECT TOP 10 * FROM [dbo].[DS_CityForest]
--where fid=12001341