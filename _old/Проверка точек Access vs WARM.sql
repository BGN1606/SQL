USE Mobile_Schwarzkopf_HO
SELECT 
t.fName as '�������� �� Access',
f.fName as '�������� �� WARM',
f.fID as '��� �� WARM',
f.exid as '������� ��� �� WARM',
f.fActiveFlag as '���� ����������'
FROM Mobile_Schwarzkopf_HO_Plus.dbo.DS_Temp t
LEFT JOIN DS_FACES f
	   ON t.fName=f.fName
	  AND f.DistID <>92
	  AND f.fType=7
ORDER BY 1