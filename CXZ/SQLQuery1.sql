use mdm
go

declare @start_date date = '20190101', @end_date date = '20191231'

insert into dbo.mdm_stock(
    date
,   retailer_id
,   product_id
,   quantity_item
,   quantity_box
,   cost_without_tax
,   cost_with_tax
,   sum
,   created_at
,   updated_at
)
select
    date
  , retailer_id = R.id
  , product_id  = PR.id
  , amount
  , 0
  , 0
  , 0
  , isnull(money_purchase,0)
  , getdate()
  , getdate()
from
    integrationDB.dbo.spot2d_bi_stocks S
    inner join mdm.dbo.mdm_partner P
        on S.group_id = P.spot_code
    inner join mdm.dbo.mdm_retailer R
        on P.id = R.ext_id and R.is_fake = 1
    inner join mdm.dbo.mdm_product PR
        on S.id_product = PR.spot_id
where
    isnull(S.date, '19000101') between @start_date and @end_date


