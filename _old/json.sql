/*alter function [dbo].[POSTHttp]
(
@url varchar(8000),
@data varchar(2000)
)
returns varchar(8000)
as

BEGIN
DECLARE @win int
DECLARE @hr  int
DECLARE @text varchar(8000)

EXEC @hr=sp_OACreate 'WinHttp.WinHttpRequest.5.1',@win OUT
IF @hr <> 0 EXEC sp_OAGetErrorInfo @win

EXEC @hr=sp_OAMethod @win, 'Open',NULL,'POST',@url,'false'
IF @hr <> 0 EXEC sp_OAGetErrorInfo @win

EXEC @hr=sp_OAMethod @win, 'setRequestHeader',NULL, 'Content-type'
, 'application/json'
IF @hr <> 0 EXEC sp_OAGetErrorInfo @win

EXEC @hr=sp_OAMethod @win, 'setRequestHeader',NULL, 'Accept'
, 'application/json'
IF @hr <> 0 EXEC sp_OAGetErrorInfo @win

EXEC @hr=sp_OAMethod @win, 'setRequestHeader',NULL, 'Authorization'
, 'Token db3e0f4696e4b0a50ecba8987c909e1ab74a7c85'
IF @hr <> 0 EXEC sp_OAGetErrorInfo @win


EXEC @hr=sp_OAMethod @win,'Send',null,@data
IF @hr <> 0 EXEC sp_OAGetErrorInfo @win

EXEC @hr=sp_OAGetProperty @win,'ResponseText',@text OUTPUT
IF @hr <> 0 EXEC sp_OAGetErrorInfo @win

EXEC @hr=sp_OAGetProperty @win,'ResponseText',@text OUTPUT
IF @hr <> 0 EXEC sp_OAGetErrorInfo @win

EXEC @hr=sp_OADestroy @win
IF @hr <> 0 EXEC sp_OAGetErrorInfo @win

RETURN @text

END
*/

/*
declare @data varchar(4000)
select @data=dbo.POSTHttp('https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address','{ "query": "г.Кемерово, пр.Ленина,24", "count": 1 }')
select @data*/

declare @data varchar(max)=
'
{"suggestions":[{"value":"г Кемерово, пр-кт Ленина, д 24","unrestricted_value":"Кемеровская обл, г Кемерово, пр-кт Ленина, д 24","data":{"postal_code":"650025","country":"Россия","federal_district":"Сибирский","region_fias_id":"393aeccb-89ef-4a7e-ae42-08d5cebc2e30","region_kladr_id":"4200000000000","region_with_type":"Кемеровская обл","region_type":"обл","region_type_full":"область","region":"Кемеровская","area_fias_id":null,"area_kladr_id":null,"area_with_type":null,"area_type":null,"area_type_full":null,"area":null,"city_fias_id":"94bb19a3-c1fa-410b-8651-ac1bf7c050cd","city_kladr_id":"4200000900000","city_with_type":"г Кемерово","city_type":"г","city_type_full":"город","city":"Кемерово","city_area":null,"city_district_fias_id":null,"city_district_kladr_id":null,"city_district_with_type":null,"city_district_type":null,"city_district_type_full":null,"city_district":null,"settlement_fias_id":null,"settlement_kladr_id":null,"settlement_with_type":null,"settlement_type":null,"settlement_type_full":null,"settlement":null,"street_fias_id":"363ced92-346f-49a7-bd9d-6d5fb2ca4f73","street_kladr_id":"42000009000083600","street_with_type":"пр-кт Ленина","street_type":"пр-кт","street_type_full":"проспект","street":"Ленина","house_fias_id":"f7730363-4887-4d13-9295-c3aaca28e0a2","house_kladr_id":"4200000900008360137","house_type":"д","house_type_full":"дом","house":"24","block_type":null,"block_type_full":null,"block":null,"flat_type":null,"flat_type_full":null,"flat":null,"flat_area":null,"square_meter_price":null,"flat_price":null,"postal_box":null,"fias_id":"f7730363-4887-4d13-9295-c3aaca28e0a2","fias_code":"42000009000000008360137","fias_level":"8","fias_actuality_state":"0","kladr_id":"4200000900008360137","geoname_id":null,"capital_marker":"2","okato":"32401000000","oktmo":"32701000001","tax_office":"4205","tax_office_legal":"4205","timezone":null,"geo_lat":"55.3445762","geo_lon":"86.0741714","beltway_hit":null,"beltway_distance":null,"metro":null,"qc_geo":"0","qc_complete":null,"qc_house":null,"history_values":null,"unparsed_parts":null,"source":null,"qc":null}}]}
' 
--select isjson(@data)
SELECT *
FROM OPENJSON(@data)
WITH (
[ID]								  varchar(4000) '$.zzz',
[ФИО (было)]						  varchar(4000) '$.zzz',
[Адрес (было)]						  varchar(4000) '$.zzz',
[Адрес (стало)]						  varchar(4000) '$.suggestions[0].value',
[Индекс]							  varchar(4000) '$.suggestions[0].data.postal_code',
[Страна]							  varchar(4000) '$.suggestions[0].data.country',
[Тип региона]						  varchar(4000) '$.suggestions[0].data.region_type',
[Регион]							  varchar(4000) '$.suggestions[0].data.region',
[Тип района]						  varchar(4000) '$.suggestions[0].data.area_type',
[Район]								  varchar(4000) '$.suggestions[0].data.area',
[Тип города]						  varchar(4000) '$.suggestions[0].data.city_type',
[Город]								  varchar(4000) '$.suggestions[0].data.city',
[Тип н/п]							  varchar(4000) '$.suggestions[0].data.settlement_type',
[Н/п]								  varchar(4000) '$.suggestions[0].data.settlement',
[Район города]						  varchar(4000) '$.suggestions[0].data.city_district',
[Тип улицы]							  varchar(4000) '$.suggestions[0].data.street_type',
[Улица]								  varchar(4000) '$.suggestions[0].data.street',
[Тип дома]							  varchar(4000) '$.suggestions[0].data.house_type',
[Дом]								  varchar(4000) '$.suggestions[0].data.house',
[Тип корпуса/строения]				  varchar(4000) '$.suggestions[0].data.block_type',
[Корпус/строение]					  varchar(4000) '$.suggestions[0].data.block',
[Тип квартиры]						  varchar(4000) '$.suggestions[0].data.flat_type',
[Квартира]							  varchar(4000) '$.suggestions[0].data.flat',
[Абонентский ящик]					  varchar(4000) '$.suggestions[0].data.postal_box',
[Код КЛАДР]							  varchar(4000) '$.suggestions[0].data.kladr_id',
[Код ФИАС]							  varchar(4000) '$.suggestions[0].data.fias_id',
[Уровень по ФИАС]					  varchar(4000) '$.suggestions[0].data.fias_level',
[Признак центра района или региона]	  varchar(4000) '$.suggestions[0].data.capital_marker',
[Код ОКАТО]							  varchar(4000) '$.suggestions[0].data.okato',
[Код ОКТМО]							  varchar(4000) '$.suggestions[0].data.oktmo',
[Код ИФНС для физических лиц]		  varchar(4000) '$.suggestions[0].data.tax_office',
[Площадь квартиры]					  varchar(4000) '$.suggestions[0].data.flat_area',
[Стоимость м²]						  varchar(4000) '$.suggestions[0].data.square_meter_price',
[Стоимость квартиры]				  varchar(4000) '$.suggestions[0].data.flat_price',
[Часовой пояс]						  varchar(4000) '$.suggestions[0].data.timezone',
[Широта]							  varchar(4000) '$.suggestions[0].data.geo_lat',
[Долгота]							  varchar(4000) '$.suggestions[0].data.geo_lon',
[Внутри кольцевой?]					  varchar(4000) '$.suggestions[0].data.beltway_hit',
[Расстояние от кольцевой]			  varchar(4000) '$.suggestions[0].data.beltway_distance',
[Точность координат]				  varchar(4000) '$.suggestions[0].data.qc_geo',
[Подходит для рассылки?]			  varchar(4000) '$.suggestions[0].data.qc_house',
[Код проверки]						  varchar(4000) '$.suggestions[0].data.qc_complete',
[Нераспознанная часть]				  varchar(4000) '$.suggestions[0].data.unparsed_parts',
[Паспорт]							  varchar(4000) '$.suggestions[0].zzz',
[Серия]								  varchar(4000) '$.suggestions[0].zzz',
[Номер]								  varchar(4000) '$.suggestions[0].zzz',
[Код проверки]						  varchar(4000) '$.suggestions[0].zzz',
[Автомобиль (было)]					  varchar(4000) '$.suggestions[0].zzz',
[Автомобиль (стало)]				  varchar(4000) '$.suggestions[0].zzz',
[Марка]								  varchar(4000) '$.suggestions[0].zzz',
[Модель]							  varchar(4000) '$.suggestions[0].zzz',
[Код проверки]						  varchar(4000) '$.suggestions[0].zzz'
) 

 --{"suggestions":[{"value":"г Москва, ул Хабаровская","unrestricted_value":"г Москва, р-н Гольяново, ул Хабаровская","data":{"postal_code":null,"country":"Россия","federal_district":"Центральный","region_fias_id":"0c5b2444-70a0-4932-980c-b4dc0d3f02b5","region_kladr_id":"7700000000000","region_with_type":"г Москва","region_type":"г","region_type_full":"город","region":"Москва","area_fias_id":null,"area_kladr_id":null,"area_with_type":null,"area_type":null,"area_type_full":null,"area":null,"city_fias_id":"0c5b2444-70a0-4932-980c-b4dc0d3f02b5","city_kladr_id":"7700000000000","city_with_type":"г Москва","city_type":"г","city_type_full":"город","city":"Москва","city_area":"Восточный","city_district_fias_id":null,"city_district_kladr_id":null,"city_district_with_type":"р-н Гольяново","city_district_type":"р-н","city_district_type_full":"район","city_district":"Гольяново","settlement_fias_id":null,"settlement_kladr_id":null,"settlement_with_type":null,"settlement_type":null,"settlement_type_full":null,"settlement":null,"street_fias_id":"32fcb102-2a50-44c9-a00e-806420f448ea","street_kladr_id":"77000000000713400","street_with_type":"ул Хабаровская","street_type":"ул","street_type_full":"улица","street":"Хабаровская","house_fias_id":null,"house_kladr_id":null,"house_type":null,"house_type_full":null,"house":null,"block_type":null,"block_type_full":null,"block":null,"flat_type":null,"flat_type_full":null,"flat":null,"flat_area":null,"square_meter_price":null,"flat_price":null,"postal_box":null,"fias_id":"32fcb102-2a50-44c9-a00e-806420f448ea","fias_code":"77000000000000071340000","fias_level":"7","fias_actuality_state":"0","kladr_id":"77000000000713400","geoname_id":null,"capital_marker":"0","okato":"45263564000","oktmo":"45305000","tax_office":"7718","tax_office_legal":"7718","timezone":null,"geo_lat":"55.8212481","geo_lon":"37.8260663","beltway_hit":null,"beltway_distance":null,"metro":null,"qc_geo":"2","qc_complete":null,"qc_house":null,"history_values":null,"unparsed_parts":null,"source":null,"qc":null}}]}

