/****** Script for SelectTopNRows command from SSMS  ******/
SELECT
   p.[fID]			 AS pId
  ,p.[fActiveFlag]	 AS pActiveFlag
  ,f.[fID]			 AS fId
  ,f.[fActiveFlag]	 AS fActiveFlag
  ,poa.[AttrText]    AS pABC
  ,poa.AttrValueId   AS pABCID
  ,foa.[AttrText]    AS fABC
FROM [Mobile_Schwarzkopf_HO].[dbo].[DS_FACES] p
join [Mobile_Schwarzkopf_HO].[dbo].[DS_FACES] f
  ON CONCAT('Transfer_',p.fID) = f.exid
  and f.OwnerDistID=92
left join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes]  poa with (nolock)
  on p.fid=poa.id
 and poa.activeflag=1
 and poa.attrid=611
 and poa.DictId=2
left join [Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes]  foa with (nolock)
  on f.fid=foa.id
 and foa.activeflag=1
 and foa.attrid=611
 and foa.DictId=2
WHERE p.OwnerDistID <>92 
  AND p.fType=7
  AND poa.AttrValueId<>foa.AttrValueId