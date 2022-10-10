/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT
	TargetID,
	OwnerDistID,
	ExId
	TypeID,
	Comment,
	DateBegin,
	DateEnd,
	Value,
	Bonus,
	Flags,
	ActiveFlag,
	DistID,
	ChangeDate,
	FatherID,
	BonusType,
	Shortfall,
	AssociateTargetID
--INTO Mobile_Schwarzkopf_HO_Plus.dbo.DS_PlanCheck
FROM Mobile_Schwarzkopf_HO.dbo.DS_Targets
WHERE DateBegin>='20170801'
	AND FatherID not in (1031350,1031351,1043307,1043316,1043317,1043318,1043319,1043320)


--Шаблоны планов
--select * from DS_Targets where DistID=1 and ActiveFlag=1 and FatherID is null and Flags > 1000