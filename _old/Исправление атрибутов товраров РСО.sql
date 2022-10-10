USE Schwarzkopf
IF OBJECT_ID('bcptmp','U') IS NOT NULL DROP TABLE bcptmp
SELECT
  AttrId,ExidAttr,OwnerDistId,ExidOwner,DictId,SubDictId,id,ExId,RecordId,AttrValueID,
  ExidAttrValue,AttrText,ActiveFlag,Sort,Options,StartDate,EndDate,DictId_AttrText,Exid_AttrText
INTO bcptmp
FROM(
	SELECT DISTINCT
	  o.AttrId		AttrId,
	  NULL			ExidAttr,
	  o.OwnerDistID	OwnerDistId,
	  NULL			ExidOwner,
	  1				DictId,
	  NULL			SubDictId,
	  o.id			id,
	  NULL			ExId,
	  NULL			RecordId,
	  o.AttrValueId	AttrValueID,
	  NULL			ExidAttrValue,
	  NULL			AttrText,
	  0				ActiveFlag,
	  1				Sort,
	  NULL			Options,
	  NULL			StartDate,
	  NULL			EndDate,
	  NULL			DictId_AttrText,
	  NULL			Exid_AttrText
	FROM [FTPHBCHO.CDC.RU].[Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes] o
	WHERE o.dictid=1
	  AND o.activeflag=1
	  AND o.ownerdistid<>1
	  AND o.attrid not in (128,952,925,643,679,2113,2115)

	UNION ALL

	SELECT DISTINCT
	  o.AttrId		AttrId,
	  NULL			ExidAttr,
	  1				OwnerDistId,
	  NULL			ExidOwner,
	  1				DictId,
	  NULL			SubDictId,
	  o.id			id,
	  NULL			ExId,
	  NULL			RecordId,
	  o.AttrValueId	AttrValueID,
	  NULL			ExidAttrValue,
	  NULL			AttrText,
	  1				ActiveFlag,
	  1				Sort,
	  NULL			Options,
	  NULL			StartDate,
	  NULL			EndDate,
	  NULL			DictId_AttrText,
	  NULL			Exid_AttrText
	FROM [FTPHBCHO.CDC.RU].[Mobile_Schwarzkopf_HO].[dbo].[DS_ObjectsAttributes] o
	WHERE o.dictid=1
	  AND o.activeflag=1
	  AND o.ownerdistid<>1
	  AND o.attrid not in (128,952,925,643,679,2113,2115)
    ) STEP_1

IF (SELECT COUNT(*) FROM Schwarzkopf.dbo.bcptmp)>0
BEGIN
  EXEC xp_cmdShell 'bcp "select * from Schwarzkopf.dbo.bcptmp" queryout C:\Transfer\Other\DMT_Set_ObjectsAttribute_batch.txt -T -c -t "|" -C Win1251'
  EXEC ftp_mput N'C:\Transfer\Other\',N'DMT_Set_ObjectsAttribute_batch.txt'
  EXEC ftp_mput N'C:\Transfer\Other\',N'DMT_Set_ObjectsAttribute_batch_init.txt'
  EXEC ftp_mput N'C:\Transfer\Other\',N'DMT_Set_ObjectsAttribute_batch_commit.txt'
END