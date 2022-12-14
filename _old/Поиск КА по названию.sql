--select * from vnetworks

select
n.hqnm,
  f1.ownerdistid,
  f1.fid,
  f1.fname,
  f1.fAddress
from DS_FACES f1
left join DS_FACES f2
  on f1.fName=f2.fName
 and f2.OwnerDistID=3
 and f2.fType=7
left join Mobile_Schwarzkopf_HO_Plus.dbo.vnetworks n
	on n.fid = f1.fid
where f1.fType=7
  and f2.fID is null
  and f1.OwnerDistID <>3
  and f1.OwnerDistID <>92
  and (f1.fName like '%Атак%'
   or f1.fName like '%Atak%'
   or f1.fName like '%Auchan%'
   or f1.fName like '%Billa%'
   or f1.fName like '%Diksi%'
   or f1.fName like '%Дикси%'
   or f1.fName like '%Giperglobus%'
   or f1.fName like '%Лента%'
   or f1.fName like '%Lenta%'
   or f1.fName like '%Letoile%'
   or f1.fName like '%МЕТРО%'
   or f1.fName like '%Metro%'
   or f1.fName like '%Noveks%'
   or f1.fName like '%О%КЕЙ%'
   or f1.fName like '%Okey%'
   or f1.fName like '%"О%кей"%'
   or f1.fName like '%ОКЕЙ%'
   or f1.fName like '%OPTIMA%'
   or f1.fName like '%Рив Гош%'
   or f1.fName like '%Spectr%'
   or f1.fName like '%Tander%'
   or f1.fName like '%Ulybka Radugi%'
   or f1.fName like '%Альпари%'
   or f1.fName like '%Perekrestok%'
   or f1.fName like '%Карусель%'
   or f1.fName like '%Пятерочка%'
   or f1.fName like '%Yuzhnyi Dvor%'
   or f1.fName like '%Zelgros%')