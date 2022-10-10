--типы объектов дерева
select * from DS_Forest_Dict

--существующие иерархии
select * from DS_Forest_Trees

-- Само дерево, обычное и история
select * from DS_Forest
select * from DS_Forest_History

-- Ноды (Названия, прим. Афтара :) )
select * from DS_Forest_Nodes


-- Берем ТТ с кодом 42000105
select * from DS_FACES where Fid=42000105
-- "ООО  Андора"

-- Смотрим код иерархии "Территориальное деление точек"
select * from DS_Forest_Trees where Name like '%Территориальное деление точек%'
-- ID = 14

-- Ищем Father родителя ТТ в территориальном делении 
select * from DS_Forest where Id=42000105 and ActiveFlag=1 and TreeID=14 and DictID=2
-- Father = 1677197

-- Ищем Id Ноды, чтобы посмотреть имя родителя
-- Тут Father = GUID 
select * from DS_Forest where GUID=1677197 and TreeID=14 and DictID=7 and ActiveFlag=1
-- Id = 42735829

-- Смотрим в Нодах, Имя родителя
select * from DS_Forest_Nodes where NodeID=42735829 and ActiveFlag=1 
-- Получаем территорию, к которой привязана ТТ, -  "ТЕР SR/SE: Жукова Кристина"


-- Ищем Father родителя Ноды "ТЕР SR/SE: Жукова Кристина" в территориальном делении 
select * from DS_Forest where Id=42735829 and ActiveFlag=1 and TreeID=14 and DictID=7
-- Father = 1359645
-- Ищем Id Ноды, чтобы посмотреть имя родителя
-- Тут Father = GUID 
select * from DS_Forest where GUID=1359645 and TreeID=14 and DictID=7 and ActiveFlag=1
-- Id = 1005319
-- Смотрим в Нодах, Имя родителя
select * from DS_Forest_Nodes where NodeID=1005319 and ActiveFlag=1 
-- Получаем территорию, к которой привязана ТТ "SSV: Sigma, Voronezh"

-- и еще разок

-- Ищем Father родителя Ноды "SSV: Sigma, Voronezh" в территориальном делении 
select * from DS_Forest where Id=1005319 and ActiveFlag=1 and TreeID=14 and DictID=7
-- Father = 1183776
-- Ищем Id Ноды, чтобы посмотреть имя родителя
-- Тут Father = GUID 
select * from DS_Forest where GUID=1183776 and TreeID=14 and DictID=7 and ActiveFlag=1
-- Id = 1005319
-- Смотрим в Нодах, Имя родителя
select * from DS_Forest_Nodes where NodeID=1005318 and ActiveFlag=1 
-- Получаем территорию, к которой привязана ТТ "RSE: Губанов Роман"


-- проделаем то же самое для ТП

-- Берем ТП с кодом 42000004
select * from DS_FACES where Fid=42000004
-- "SE DB: Жукова Кристина"
-- Смотрим код иерархии "Территория -> Торгпред"
select * from DS_Forest_Trees where Name like '%Территория -> Торгпред%'
-- ID = 16
-- Ищем Father родителя ТП в территориальном делении 
select * from DS_Forest where Id=42000004 and ActiveFlag=1 and TreeID=16 and DictID=2
-- Father = 42436691
-- Ищем Id Ноды, чтобы посмотреть имя родителя
-- Тут Father = GUID 
select * from DS_Forest where GUID=42436691 and TreeID=16 and DictID=7 and ActiveFlag=1
-- Id = 42735829
-- Смотрим в Нодах, Имя родителя
select * from DS_Forest_Nodes where NodeID=42735829 and ActiveFlag=1 
-- Получаем территорию, к которой привязан ТП, -  "ТЕР SR/SE: Жукова Кристина"




-- узел ТТ, сотрудника 

select * from DS_Forest where id in(45005976) and treeid in(14)

-- узлы территории (подставляем father из первого запроса в guid)

select * from DS_Forest where guid in(45133931) and treeid in(14)

 -- территории (подставляем id из второго запроса в nodeid)

select * from DS_Forest_Nodes where nodeid in(106000304)

--ищем территорию
select * from ds_forest_nodes where nodename='ТЕР SR/SE: Абрамова Юлия'
--ищем узел территории: подставляем nodeid в id 
select * from DS_Forest where id=73268095 and treeid in(16) and ActiveFlag=1
--ищем привязанных: подставляем guid в father
select * from DS_Forest where father=73000025 and activeflag=1
--ищем соответствующие лица
select * from ds_faces where fid in (select id from DS_Forest where father=73000025 and activeflag=1) ---SR DB: Penza Абрамова Ю.
