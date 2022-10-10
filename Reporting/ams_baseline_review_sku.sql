USE HBCAMS_MSCRM
SELECT
division.[Value] as 'Регион',
CASE
	WHEN mut.cdc_type in (754460010)  THEN 'Baseline'
	WHEN mut.cdc_type in (754460012)  THEN 'Promo'
END as 'Тип строки',
accnt.ParentAccountIdName as 'Дистрибьютор',
mut.cdc_epname as 'Контрагент',
year(mut.cdc_datum) as 'Год',
month(mut.cdc_datum) as 'Месяц',
prod.cdc_caterogyname as 'Категория',
prod.cdc_brandname as 'Бренд',
prod.Name as 'EAN',
prod.cdc_description as 'Наименование',
SUM(mut.cdc_con) as 'CON',
SUM(mut.cdc_ges) as 'GES',
SUM(mut.cdc_pld) as 'PLD',
CASE
	WHEN mut.cdc_type in (754460010)  THEN null
	ELSE mut.cdc_promoname
END as 'Промо',
ISNULL(promo.cdc_clientconfirmed,1) as 'Подтверждена клиентом',
promo.cdc_is_mm 'Передавать в ММ',
SUM(mut.cdc_ppd) as 'PPD',
SUM(mut.cdc_oncch) as 'ONcch',
SUM(mut.cdc_ONcdb) as 'ONcdb',
SUM(mut.cdc_cpv) as 'CPV',
SUM(mut.cdc_rp) as 'RP',
SUM(mut.cdc_offcch) as 'OFFcch',
SUM(mut.cdc_offc_promo_abs) as 'OFFc_promo_abs',
SUM(mut.cdc_offc_promo_perc) as 'OFFc_promo_perc',
SUM(mut.cdc_offcdb) as 'OFFcdb',
SUM(mut.cdc_offextra) as 'OFFextra',
SUM(mut.cdc_nes) as 'NES',
SUM(mut.cdc_comm) as 'COMM',
SUM(mut.cdc_matcost) as 'MatCost',
SUM(mut.cdc_trwh) as 'TrWh',
SUM(mut.cdc_gp1) as 'GP1',
SUM(mut.cdc_l17) as 'L17',
SUM(mut.cdc_gp2) as 'GP2'
FROM cdc_ForcastMut mut WITH (NOLOCK)
LEFT JOIN Product prod WITH (NOLOCK)
  ON mut.cdc_ean=prod.productid

LEFT JOIN cdc_Promo promo WITH (NOLOCK)
  ON mut.cdc_promo=promo.cdc_promoid
 AND promo.statecode=0

LEFT JOIN Account accnt WITH (NOLOCK)
  ON mut.cdc_EP=accnt.AccountId
 AND accnt.StateCode=0
 AND accnt.cdc_Type=754460000

LEFT JOIN [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)
  ON accnt.[new_division_EP] = division.[AttributeValue]
 AND division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'

WHERE mut.cdc_type in (754460010)
  AND mut.statecode=0
  AND mut.cdc_datum>=DATEADD(month, DATEDIFF(month, 0, getdate()), 0)

 /*Фильтры для интерфейса*/
AND mut.cdc_epname in (@EP)
AND month(cdc_datum) in (@Month)
AND division.[Value] in (@Region)
AND YEAR(mut.cdc_datum) in (@Year)

GROUP BY
division.[Value],
CASE
	WHEN mut.cdc_type in (754460010)  THEN 'Baseline'
	WHEN mut.cdc_type in (754460012)  THEN 'Promo'
END,
accnt.ParentAccountIdName,
mut.cdc_epname,
YEAR(mut.cdc_datum),
MONTH(mut.cdc_datum),
prod.cdc_caterogyname,
prod.cdc_brandname,
prod.Name,
prod.cdc_description,
CASE
	WHEN mut.cdc_type in (754460010)  THEN null
	ELSE mut.cdc_promoname
END,
ISNULL(promo.cdc_clientconfirmed,1),
promo.cdc_is_mm

-- Filters
-- Ep
select distinct Name from FilteredAccount

-- Region
SELECT division.[Value]
FROM [HBCAMS_MSCRM].[dbo].[FilteredStringMap] division WITH (NOLOCK)

WHERE division.[LangId] = 1049
 AND division.[FilteredViewName] = 'FilteredAccount'
 AND division.[AttributeName] = 'new_division_EP'
