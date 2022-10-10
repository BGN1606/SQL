use Mobile_Schwarzkopf_DirectSales

--SELECT f.fID, fAddress, len(f.fAddress) ln
--FROM DS_FACES f (nolock)
--WHERE f.ftype=7
--  and f.OwnerDistID=3
--  and f.fName not like '%¿˛ÒÒ%'
--  and f.fName not like '%ƒÛ·ËÌ%'
--  and f.fName not like '%÷»Ã”—%'
--  and f.fid not in (select Fid from DS_CityForest where OwnerDistId=3)



SELECT getdate(), count(*)
FROM DS_FACES f (nolock)
WHERE f.ftype=7
  and f.OwnerDistID=3
  and f.fName not like '%¿˛ÒÒ%'
  and f.fName not like '%ƒÛ·ËÌ%'
  and f.fName not like '%÷»Ã”—%'
  and f.fid not in (select Fid from DS_CityForest where OwnerDistId=3)

 --ÀŒ√:
 --2018-09-03 10:37	24754
 --2018-09-03 11:06 24657
 --2018-09-03 23:39	23280
 --2018-09-04 00:10	23122
 --2018-09-04 10:54	22552
 --2018-09-04 11:55	22099
 --2018-09-04 13:19 21582
 --2018-09-04 13:28	21518
 --2018-09-04 13:54	21406
 --2018-09-06 13:08	19978
 --2018-09-10 08:41	16684
 --2018-09-14 01:57	11535