/****** Script for SelectTopNRows command from SSMS  ******/
USE BAT_Schwarzkopf

SELECT DISTINCT 
	rpf3.rpfName,
	rpf2.rpfName,
	rpf1.rpfName,
	rptName,
	replace(replace(rptNotes, char(10), ''), char(13), ' '),
	rptStatus
FROM tblReports
join tblReportFolders rpf1 on rpt_rpfID = rpf1.rpfID
left join tblReportFolders rpf2 on rpf1.rpfParent_rpfID = rpf2.rpfID
left join tblReportFolders rpf3 on rpf2.rpfParent_rpfID = rpf3.rpfID