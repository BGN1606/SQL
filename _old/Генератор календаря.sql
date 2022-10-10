USE HBCAMS_IntegrationDB
GO

SET DATEFIRST 1
GO

SET LANGUAGE english
GO

DECLARE @sdate	date = '20140101',
        @edate	date = '20501231',
	    @date	date
 
SET @date = @sdate
 
DECLARE @date_table AS TABLE (
  [date]					DATE		NOT NULL,
  [date_firstday]			DATE		NOT NULL,
  [date_lastday]			DATE		NOT NULL,
  [date_year_int]			INT			NOT NULL,
  [date_quarter_int]		VARCHAR(2)	NOT NULL,
  [date_month_number_int]	int			NOT NULL,
  [date_month_number_txt]	VARCHAR(2)	NOT NULL,
  [date_month_name_eng]		VARCHAR(20)	NOT NULL,
  [date_month_name_rus]		VARCHAR(20)	NULL,
  [date_week_int]			int			NOT NULL,
  [date_weekday_int]		int			NOT NULL,
  [date_weekday_name_eng]	VARCHAR(20)	NOT NULL,
  [date_weekday_name_rus]	VARCHAR(20)	NULL,
  [date_day_int]			int			NOT NULL,
  [date_day_txt]			VARCHAR(2)	NOT NULL
)
  
WHILE @date <= @edate
BEGIN
  
  INSERT INTO @date_table
  SELECT
	@date,
	dateadd(mm, datediff(mm, 0, @date), 0),
	EOMONTH(@date),
	DATEPART(yy, @date),
	DATEPART(Q, @date),
	DATEPART(mm, @date),
	FORMAT(@date, 'MM', 'en-gb'),
	DATENAME(mm, @date),
	NULL,
	DATEPART(WEEK, @date),
	DATEPART(WEEKDAY, @date),
	DATENAME(WEEKDAY, @date),
	NULL,
	DATEPART(DD, @date),
	FORMAT(@date, 'dd', 'en-gb')

  SET @date = dateadd(dd,1,@date)
END

SET LANGUAGE russian
UPDATE @date_table
SET [date_month_name_rus] = DATENAME(mm, [date]),
	[date_weekday_name_rus] = CONCAT(UPPER(LEFT(DATENAME(WEEKDAY, [date]), 1)), RIGHT(DATENAME(WEEKDAY, [date]),LEN(DATENAME(WEEKDAY, [date]))-1))

DROP TABLE [bi].[Calendar]
CREATE TABLE [bi].[Calendar] (
  [date]				DATE		NOT NULL,
  [date_firstday]			DATE		NOT NULL,
  [date_lastday]			DATE		NOT NULL,
  [date_year_int]			INT			NOT NULL,
  [date_quarter_int]		VARCHAR(2)	NOT NULL,
  [date_month_number_int]	int			NOT NULL,
  [date_month_number_txt]	VARCHAR(2)	NOT NULL,
  [date_month_name_eng]		VARCHAR(20)	NOT NULL,
  [date_month_name_rus]		VARCHAR(20)	NULL,
  [date_week_int]			int			NOT NULL,
  [date_weekday_int]		int			NOT NULL,
  [date_weekday_name_eng]	VARCHAR(20)	NOT NULL,
  [date_weekday_name_rus]	VARCHAR(20)	NULL,
  [date_day_int]			int			NOT NULL,
  [date_day_txt]			VARCHAR(2)	NOT NULL
)

INSERT INTO [bi].[Calendar]
SELECT * FROM @date_table
GO

SET LANGUAGE english
GO

CREATE CLUSTERED INDEX date_value ON [bi].[Calendar] ([date]); 

SELECT * FROM [bi].[Calendar]