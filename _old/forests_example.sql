--���� �������� ������
select * from DS_Forest_Dict

--������������ ��������
select * from DS_Forest_Trees

-- ���� ������, ������� � �������
select * from DS_Forest
select * from DS_Forest_History

-- ���� (��������, ����. ������ :) )
select * from DS_Forest_Nodes


-- ����� �� � ����� 42000105
select * from DS_FACES where Fid=42000105
-- "���  ������"

-- ������� ��� �������� "��������������� ������� �����"
select * from DS_Forest_Trees where Name like '%��������������� ������� �����%'
-- ID = 14

-- ���� Father �������� �� � ��������������� ������� 
select * from DS_Forest where Id=42000105 and ActiveFlag=1 and TreeID=14 and DictID=2
-- Father = 1677197

-- ���� Id ����, ����� ���������� ��� ��������
-- ��� Father = GUID 
select * from DS_Forest where GUID=1677197 and TreeID=14 and DictID=7 and ActiveFlag=1
-- Id = 42735829

-- ������� � �����, ��� ��������
select * from DS_Forest_Nodes where NodeID=42735829 and ActiveFlag=1 
-- �������� ����������, � ������� ��������� ��, -  "��� SR/SE: ������ ��������"


-- ���� Father �������� ���� "��� SR/SE: ������ ��������" � ��������������� ������� 
select * from DS_Forest where Id=42735829 and ActiveFlag=1 and TreeID=14 and DictID=7
-- Father = 1359645
-- ���� Id ����, ����� ���������� ��� ��������
-- ��� Father = GUID 
select * from DS_Forest where GUID=1359645 and TreeID=14 and DictID=7 and ActiveFlag=1
-- Id = 1005319
-- ������� � �����, ��� ��������
select * from DS_Forest_Nodes where NodeID=1005319 and ActiveFlag=1 
-- �������� ����������, � ������� ��������� �� "SSV: Sigma, Voronezh"

-- � ��� �����

-- ���� Father �������� ���� "SSV: Sigma, Voronezh" � ��������������� ������� 
select * from DS_Forest where Id=1005319 and ActiveFlag=1 and TreeID=14 and DictID=7
-- Father = 1183776
-- ���� Id ����, ����� ���������� ��� ��������
-- ��� Father = GUID 
select * from DS_Forest where GUID=1183776 and TreeID=14 and DictID=7 and ActiveFlag=1
-- Id = 1005319
-- ������� � �����, ��� ��������
select * from DS_Forest_Nodes where NodeID=1005318 and ActiveFlag=1 
-- �������� ����������, � ������� ��������� �� "RSE: ������� �����"


-- ��������� �� �� ����� ��� ��

-- ����� �� � ����� 42000004
select * from DS_FACES where Fid=42000004
-- "SE DB: ������ ��������"
-- ������� ��� �������� "���������� -> ��������"
select * from DS_Forest_Trees where Name like '%���������� -> ��������%'
-- ID = 16
-- ���� Father �������� �� � ��������������� ������� 
select * from DS_Forest where Id=42000004 and ActiveFlag=1 and TreeID=16 and DictID=2
-- Father = 42436691
-- ���� Id ����, ����� ���������� ��� ��������
-- ��� Father = GUID 
select * from DS_Forest where GUID=42436691 and TreeID=16 and DictID=7 and ActiveFlag=1
-- Id = 42735829
-- ������� � �����, ��� ��������
select * from DS_Forest_Nodes where NodeID=42735829 and ActiveFlag=1 
-- �������� ����������, � ������� �������� ��, -  "��� SR/SE: ������ ��������"




-- ���� ��, ���������� 

select * from DS_Forest where id in(45005976) and treeid in(14)

-- ���� ���������� (����������� father �� ������� ������� � guid)

select * from DS_Forest where guid in(45133931) and treeid in(14)

 -- ���������� (����������� id �� ������� ������� � nodeid)

select * from DS_Forest_Nodes where nodeid in(106000304)

--���� ����������
select * from ds_forest_nodes where nodename='��� SR/SE: �������� ����'
--���� ���� ����������: ����������� nodeid � id 
select * from DS_Forest where id=73268095 and treeid in(16) and ActiveFlag=1
--���� �����������: ����������� guid � father
select * from DS_Forest where father=73000025 and activeflag=1
--���� ��������������� ����
select * from ds_faces where fid in (select id from DS_Forest where father=73000025 and activeflag=1) ---SR DB: Penza �������� �.
