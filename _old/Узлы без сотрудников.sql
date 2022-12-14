/****** Пустые  ******/
USE Mobile_Schwarzkopf_HO

SELECT 
	n7.NodeFullName 'n7',
	fcs7.fName 's7',
	n6.NodeFullName 'n6',
	fcs6.fName 's6',
	n5.NodeFullName 'n5',
	fcs5.fName 's5',
	n4.NodeFullName 'n4',
	fcs4.fName 's4',
	n3.NodeFullName 'n3',
	fcs3.fName 's3',
	n2.NodeFullName 'n2',
	fcs2.fName 's2',
	n1.NodeFullName 'n0',
	fcs.fName 's0'
FROM DS_Forest f1

LEFT JOIN DS_Forest f0
	ON f1.Id = f0.Id
	AND f0.ActiveFlag =1
	AND f0.TreeID=16
JOIN DS_Forest_Nodes n1
	ON f0.Id=n1.NodeID
	AND n1.ActiveFlag=1
LEFT JOIN DS_Forest s0
	 ON f0.GUID=s0.Father
	AND s0.ActiveFlag=1
	AND s0.TreeID=16
	AND s0.DictID=2
JOIN DS_FACES fcs
	ON s0.Id = fcs.fID

JOIN DS_Forest f2
	 ON f1.Father=f2.GUID
	AND f2.ActiveFlag=1
	AND f2.TreeID=14
JOIN DS_Forest_Nodes n2
	ON f2.Id=n2.NodeID
	AND n2.ActiveFlag=1
LEFT JOIN DS_Forest s2
	ON f2.Id = s2.Id
	AND s2.ActiveFlag=1
	AND s2.TreeID=15
LEFT JOIN DS_Forest ts2
	ON s2.GUID = ts2.Father
	AND ts2.ActiveFlag=1
	AND ts2.TreeID=15
	AND ts2.DictID=2
LEFT JOIN DS_FACES fcs2
	ON ts2.Id=fcs2.fID
	AND fcs2.fActiveFlag=1

JOIN DS_Forest f3
	 ON f2.Father=f3.GUID
	AND f3.ActiveFlag=1
	AND f3.TreeID=14
JOIN DS_Forest_Nodes n3
	ON f3.Id=n3.NodeID
	AND n3.ActiveFlag=1
LEFT JOIN DS_Forest s3
	ON f3.Id = s3.Id
	AND s3.ActiveFlag=1
	AND s3.TreeID=15
LEFT JOIN DS_Forest ts3
	ON s3.GUID = ts3.Father
	AND ts3.ActiveFlag=1
	AND ts3.TreeID=15
	AND ts3.DictID=2
LEFT JOIN DS_FACES fcs3	
	ON ts3.Id=fcs3.fID
	AND fcs3.fActiveFlag=1

JOIN DS_Forest f4
	 ON f3.Father=f4.GUID
	AND f4.ActiveFlag=1
	AND f4.TreeID=14
JOIN DS_Forest_Nodes n4
	ON f4.Id=n4.NodeID
	AND n4.ActiveFlag=1
LEFT JOIN DS_Forest s4
	ON f4.Id = s4.Id
	AND s4.ActiveFlag=1
	AND s4.TreeID=15
LEFT JOIN DS_Forest ts4
	ON s4.GUID = ts4.Father
	AND ts4.ActiveFlag=1
	AND ts4.TreeID=15
	AND ts4.DictID=2
LEFT JOIN DS_FACES fcs4	
	ON ts4.Id=fcs4.fID
	AND fcs4.fActiveFlag=1


JOIN DS_Forest f5
	 ON f4.Father=f5.GUID
	AND f5.ActiveFlag=1
	AND f5.TreeID=14
JOIN DS_Forest_Nodes n5
	ON f5.Id=n5.NodeID
	AND n5.ActiveFlag=1
LEFT JOIN DS_Forest s5
	ON f5.Id = s5.Id
	AND s5.ActiveFlag=1
	AND s5.TreeID=15
LEFT JOIN DS_Forest ts5
	ON s5.GUID = ts5.Father
	AND ts5.ActiveFlag=1
	AND ts5.TreeID=15
	AND ts5.DictID=2
LEFT JOIN DS_FACES fcs5	
	ON ts5.Id=fcs5.fID
	AND fcs5.fActiveFlag=1


JOIN DS_Forest f6
	 ON f5.Father=f6.GUID
	AND f6.ActiveFlag=1
	AND f6.TreeID=14
JOIN DS_Forest_Nodes n6
	ON f6.Id=n6.NodeID
	AND n6.ActiveFlag=1
LEFT JOIN DS_Forest s6
	ON f6.Id = s6.Id
	AND s6.ActiveFlag=1
	AND s6.TreeID=15
LEFT JOIN DS_Forest ts6
	ON s6.GUID = ts6.Father
	AND ts6.ActiveFlag=1
	AND ts6.TreeID=15
	AND ts6.DictID=2
LEFT JOIN DS_FACES fcs6	
	ON ts6.Id=fcs6.fID
	AND fcs6.fActiveFlag=1


JOIN DS_Forest f7
	 ON f6.Father=f7.GUID
	AND f7.ActiveFlag=1
	AND f7.TreeID=14
JOIN DS_Forest_Nodes n7
	ON f7.Id=n7.NodeID
	AND n7.ActiveFlag=1
LEFT JOIN DS_Forest s7
	ON f7.Id = s7.Id
	AND s7.ActiveFlag=1
	AND s7.TreeID=15
LEFT JOIN DS_Forest ts7
	ON s7.GUID = ts7.Father
	AND ts7.ActiveFlag=1
	AND ts7.TreeID=15
	AND ts7.DictID=2
LEFT JOIN DS_FACES fcs7	
	ON ts7.Id=fcs7.fID
	AND fcs7.fActiveFlag=1

WHERE	f1.TreeID=14 
	AND f1.ActiveFlag=1 
	AND f1.DictID=7 
