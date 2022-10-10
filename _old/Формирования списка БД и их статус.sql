USE [Schwarzkopf]
IF OBJECT_ID('tempdb..#tmp_db') IS NOT NULL DROP TABLE #tmp_db
SELECT ROW_NUMBER() OVER(ORDER BY Database_id ASC) as ID, Name, CAST('' as int) fid, CAST('' as nvarchar(100)) fname, CAST(0 as bit) activeflg
INTO #tmp_db
FROM [FTPHBC.CDC.RU].[master].[sys].[databases]
WHERE LEFT(name,19)='Mobile_Schwarzkopf_'
  AND name NOT LIKE '%_CAC_%'
  AND name NOT LIKE '%_KZ_%'
  AND name <> 'Mobile_Schwarzkopf_DirectSales'
  AND name <> 'Mobile_Schwarzkopf_Merch'
  AND name <> 'Mobile_Schwarzkopf_UZ_Highlands'

DECLARE @db_name nvarchar(50), @min_id int = 1, @max_id int
SET @max_id=(SELECT MAX(ID) FROM #tmp_db)
SET @db_name=(SELECT Name FROM #tmp_db WHERE id = @min_id)

WHILE @min_id <= @max_id 
	BEGIN
	SET @db_name=(SELECT Name FROM #tmp_db WHERE id = @min_id)
		EXECUTE(' 
				UPDATE #tmp_db
				SET fid = (SELECT CAST([val] as int) 
				FROM [FTPHBC.CDC.RU].[' + @db_name + '].[dbo].[d_options] WHERE optionid=2)
				WHERE name =''' + @db_name + '''
				')
		SET @min_id=@min_id+1
	END;

UPDATE db
SET db.activeflg = fcs.factiveflag , db.fname = fcs.fname
FROM #tmp_db db 
JOIN [FTPHBCHO.CDC.RU].[Mobile_Schwarzkopf_HO].[dbo].[DS_FACES] fcs
  ON db.fid = fcs.fid
  AND fcs.fType = 12

IF OBJECT_ID('dbo.dblist','U') IS NOT NULL 
TRUNCATE TABLE dbo.dblist
INSERT INTO dbo.dblist
SELECT 'RUS' Country,fid,fname,name,activeflg 
FROM #tmp_db