USE Mobile_Schwarzkopf_HO
SELECT 
t.fName as 'Название ТТ Access',
f.fName as 'Название ТТ WARM',
f.fID as 'Код ТТ WARM',
f.exid as 'Внешний код ТТ WARM',
f.fActiveFlag as 'Флаг активности'
FROM Mobile_Schwarzkopf_HO_Plus.dbo.DS_Temp t
LEFT JOIN DS_FACES f
	   ON t.fName=f.fName
	  AND f.DistID <>92
	  AND f.fType=7
ORDER BY 1