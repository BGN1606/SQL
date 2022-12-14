/****** Script for SelectTopNRows command from SSMS  ******/
SELECT Distinct  top 1000 histr.[AttrId]
	  , attr.AttrName
      /*,histr.[DictId]
	  ,frst.DictName
      ,histr.[Id]
      ,fc.fName
	  ,histr.[RecordId]
      ,histr.[AttrValueId]
      ,histr.[AttrText]
      ,histr.[OwnerDistID]
      ,histr.[Changedate]
      ,histr.[DistId]
      ,histr.[StartDate]
	  --,Hex.[StartDate] as HSTART
      ,histr.[EndDate]
	  --,HEX.EndDate as HEND
      ,histr.[ActiveFlag]
      ,histr.[GUID]*/
  FROM [SC_HO_1].[dbo].[DS_ObjectsAttributes_History] Histr
  join [dbo].[DS_Attributes] attr on histr.AttrId = attr.AttrID
  join [SC_HO_1].[dbo].[DS_Forest_Dict] FRST on Histr.DictId = frst.Id
  join [SC_HO_1].[dbo].[DS_FACES] FC on Histr.Id = FC.fID
  join [dbo].[DS_ObjectsAttributes_History_Exclude] Hex on histr.[GUID] = Hex.[GUID]
  --join (Select iD, COUNT(StartDate) CNT from [SC_HO_1].[dbo].[DS_ObjectsAttributes_History] where ActiveFlag = 1 and AttrId = 683 group by Id having COUNT(StartDate)>2) A1 on Histr.Id = A1.Id
  where histr.AttrId = 683 and histr.ActiveFlag = 1 and FC.fActiveFlag = 1 and fc.Uflag = 0 and YEAR(histr.StartDate) = '2016'
  Order by histr.Id, histr.StartDate