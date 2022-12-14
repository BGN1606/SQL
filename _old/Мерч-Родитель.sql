SELECT mfcs.fID, fcs.fID as ParentFid FROM [Mobile_Schwarzkopf_HO].[dbo].[DS_FACES] FCS
JOIN (	SELECT fid ,CAST(Replace ([exid],'Transfer_','') as int) as exid
		FROM [Mobile_Schwarzkopf_HO].[dbo].[DS_FACES]
		WHERE DistID = 92 and LEFT(Exid,9) = 'Transfer_' 
						  and exid <> 'TT_unknown' 
						  and exid NOT like '% %' 
						  and exid <> '' 
						  and exid NOT like 'Transfer_92%' 
						  and exid not like '%old%' 
						  and exid not like '%del%'
						  and right(exid,1)<>'_' ) MFCS on FCS.fid = MFCS.exid