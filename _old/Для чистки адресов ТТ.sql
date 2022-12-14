/****** Script for SelectTopNRows command from SSMS  ******/
USE Mobile_Schwarzkopf_HO
SELECT
	div.AttrText 'Дивизион',
	reg.AttrText 'Регион', 
	dist.fname 'Площадка',
	fcs.fID 'Код торг. точки',
    fcs.fActiveFlag 'Активность торг. точки',
    fcs.fName 'Название торг. точки',
    fcs.fAddress 'Адрес торг. точки' 
FROM DS_FACES fcs
JOIN DS_FACES dist
	ON fcs.OwnerDistID =dist.fID
JOIN DS_ObjectsAttributes reg
	ON dist.fID = reg.Id
	AND reg.AttrId = 3008
	AND reg.Activeflag = 1
JOIN DS_ObjectsAttributes div
	ON dist.fID = div.Id
	AND div.AttrId = 3007
	AND div.Activeflag = 1

WHERE fcs.fType=7


--SELECT * FROM DS_ObjectsAttributes
--WHERE id = 12