SELECT DISTINCT CONCAT([da_mail],';') Mail FROM [Schwarzkopf].[dbo].[contactlist]
UNION ALL
SELECT DISTINCT CONCAT([dc_mail],';') Mail FROM [Schwarzkopf].[dbo].[contactlist]
UNION ALL
SELECT DISTINCT CONCAT([it_mail],';') Mail FROM [Schwarzkopf].[dbo].[contactlist]
