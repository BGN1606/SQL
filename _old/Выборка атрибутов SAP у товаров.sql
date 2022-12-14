USE Mobile_Schwarzkopf_HO
SELECT DISTINCT 
    itms.iidText,
    itms.iName,
	obatr3019.AttrText AS 'SAP Overall Market',
	obatr3020.AttrText AS 'SAP Market',
	obatr3021.AttrText AS 'SAP Brand',
	obatr3022.AttrText AS 'SAP Market Segment',
	obatr3023.AttrText AS 'SAP Sub Brand',
    itms.activeFlag
FROM DS_ITEMS AS itms
LEFT JOIN DS_ObjectsAttributes AS obatr3019
	ON itms.iID = obatr3019.Id
	AND obatr3019.AttrId in (3019) 
	AND obatr3019.DictId = 1
LEFT JOIN DS_ObjectsAttributes AS obatr3020
	ON itms.iID = obatr3020.Id
	AND obatr3020.AttrId in (3020) 
	AND obatr3020.DictId = 1
LEFT JOIN DS_ObjectsAttributes AS obatr3021
	ON itms.iID = obatr3021.Id
	AND obatr3021.AttrId in (3021) 
	AND obatr3021.DictId = 1
LEFT JOIN DS_ObjectsAttributes AS obatr3022
	ON itms.iID = obatr3022.Id
	AND obatr3022.AttrId in (3022) 
	AND obatr3022.DictId = 1
LEFT JOIN DS_ObjectsAttributes AS obatr3023
	ON itms.iID = obatr3023.Id
	AND obatr3023.AttrId in (3023) 
	AND obatr3023.DictId = 1
WHERE itms.iid in (SELECT iid FROM DS_Orders_Items)