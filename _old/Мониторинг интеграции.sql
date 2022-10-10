DROP TABLE #t1
DROP TABLE #t2

SET DATEFIRST 1
SELECT fid, dt.dt 
INTO #t1
FROM Mobile_Schwarzkopf_HO.dbo.DS_FACES (nolock)
CROSS JOIN (
	SELECT DISTINCT 
	CAST(AttrText AS date) AS dt 
	FROM Mobile_Schwarzkopf_HO.dbo.DS_DocAttributes (nolock)
	WHERE CAST(AttrText AS date) between '20170701' and '20170731'
		AND AttrID = 1726
			) AS dt
WHERE	fType = 12 and fActiveFlag = 1
	AND fid not in (3,92)
	AND DATEPART(dw, dt.dt)<6;

SET DATEFIRST 1

SELECT DISTINCT 
	ordrs.DistID,
	CAST(docatr.AttrText AS date) AS dt
INTO #t2
FROM Mobile_Schwarzkopf_HO.dbo.DS_Orders ordrs (nolock)
JOIN Mobile_Schwarzkopf_HO.dbo.DS_DocAttributes docatr (nolock)
	on ordrs.orID = docatr.DocID 
	AND ordrs.MasterFID = docatr.MASterfID
	AND AttrID = 1726
	AND docatr.ActiveFlag = 1
LEFT JOIN Mobile_Schwarzkopf_HO.dbo.DS_DocAttributes AS orAttr2 (nolock)
	ON  ordrs.orID=orAttr2.DocID
	AND ordrs.MasterFID = orAttr2.MASterfID
	AND orAttr2.AttrID = 685
	AND orAttr2.ActiveFlag=1
	AND orAttr2.AttrValueID = 685000002
WHERE   orDate between '20170701' and '20170801'
	AND ordrs.Condition = 1 
	AND orAttr2.AttrValueID is null
	AND orType in (2,9,607)
	AND DATEPART(dw, CAST(docatr.AttrText AS date))<6;

SELECT
	t1.fid AS 'Код площадки',
	t1.dt AS 'Плановая дата',
	fName AS 'Название площадки',
	t2.dt AS 'Фактическая дата'
	FROM #t1 AS t1
LEFT JOIN #t2 AS t2 on t1.fID = t2.DistID
	AND t1.dt = t2.dt
Left join Mobile_Schwarzkopf_HO.dbo.DS_FACES fcs on t1.fID = fcs.fID
ORDER BY 1,2
