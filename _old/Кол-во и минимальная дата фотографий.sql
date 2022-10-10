select distinct
       [ortype]
       ,doctype.[dtName]   as [Тип документа]
       ,min(orDate)        as [Минимальная дата документа]
	   ,min(DocAttachDate) as [Минимальная дата содержимого]
       ,count(orID)        as [Кол-во документов]
 
from [Mobile_Schwarzkopf_Merch].[dbo].[DS_Orders] ordrs
 
join [Mobile_Schwarzkopf_Merch].[dbo].[DS_DocTypes] doctype
  ON ordrs.[orType] = doctype.[dtID]
 
join [Mobile_Schwarzkopf_Merch].[dbo].[DS_DocAttachments] files
  ON ordrs.[orID] = files.[DocID]
  and ordrs.[MasterFID] = files.[MasterFID]
 
where files.[FileData] is not null
 
group by [ortype], doctype.[dtName]
order by [Кол-во документов] desc


select min(orDate) from DS_DocAttachments
where FileData is not null and ortype = 16000000