use mdm
go

alter procedure mdm_sync_Stock
    @start_date date, @end_date date as

begin
    declare @sdate_txt varchar(8), @edate_txt varchar(8)

    if @start_date is null
        begin
            set @start_date = dateadd(mm, datediff(mm, 0, getdate()), 0)
        end

    if @end_date is null
        begin
            set @end_date = cast(eomonth(getdate()) as date)
        end

    set @sdate_txt = convert(nvarchar(8), @start_date, 112)
    set @edate_txt = convert(nvarchar(12), @end_date, 112)

    raiserror (N'начинаем интеграцию данных за период с %s по %s',0,1,@sdate_txt, @edate_txt) with nowait;

    raiserror (N'Удаляем накладные, которых нет',0,1) with nowait
    delete src
    from
        mdm.dbo.mdm_stock src
    where
        not exists(select
                       date
                     , retailer_id    = R.id
                     , product_id     = PR.id
                     , amount
                     , money_purchase = isnull(money_purchase, 0)
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
                     and isnull(S.date, '19000101') = src.date
                     and R.id = src.retailer_id
                     and PR.id = src.product_id);

    raiserror (N'Обновляем накладные, которые уже были интегрированы и добавляем недостающие',0,1) with nowait
    merge mdm.dbo.mdm_stock as tgt
    using (
              select
                  date
                , retailer_id = R.id
                , product_id  = PR.id
                , amount
                , money_purchase
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
          ) as src
    on (tgt.date = src.date and tgt.retailer_id = src.retailer_id and tgt.product_id = src.product_id)
    when matched then
        update
        set
            quantity_item = src.amount
          , sum           = src.money_purchase
          , updated_at    = getdate()
    when not matched then
        insert (
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
        values
            (
                src.date
            ,   src.retailer_id
            ,   src.product_id
            ,   src.amount
            ,   0
            ,   0
            ,   0
            ,   src.money_purchase
            ,   getdate()
            ,   getdate()
            );
end
go