use mdm
go

with
    data as (
                select
                    partner_id = RP.value_id
                  , date       = dateadd(mm, datediff(mm, 0, date), 0)
                  , doc_type   = 'Sell In'
                  , product_id = SIR.product_id
                  , qty        = sum(SIR.quantity_item)
                from
                    mdm.dbo.mdm_retailer TT
                    inner join mdm.dbo.mdm_retailerpartner RP
                        on TT.id = RP.name_id
                    inner join mdm.dbo.mdm_invoicesellin SI
                        on TT.id = SI.retailer_id
                    inner join mdm.dbo.mdm_invoicesellinrows SIR
                        on SI.id = SIR.invoice_id
                where
                      TT.is_fake = 1
                  and SI.date between '20210101' and '20221231'
                group by
                    RP.value_id
                  , SIR.product_id
                  , TT.ext_id
                  , dateadd(mm, datediff(mm, 0, date), 0)
                  , SIR.product_id

                union all

                select
                    partner_id = RP.value_id
                  , date       = dateadd(mm, datediff(mm, 0, date), 0)
                  , doc_type   = 'Sell Through'
                  , product_id = STR.product_id
                  , qty        = sum(STR.quantity_item)
                from
                    mdm.dbo.mdm_retailer TT
                    inner join mdm.dbo.mdm_retailerpartner RP
                        on TT.id = RP.name_id
                    inner join mdm.dbo.mdm_invoicesellthrough ST
                        on TT.id = ST.retailer_id
                    inner join mdm.dbo.mdm_invoicesellthroughrow STR
                        on ST.id = STR.invoice_id
                where
                      TT.is_fake is null
                  and ST.date between '20210101' and '20221231'

                group by
                    RP.value_id
                  , STR.product_id
                  , TT.ext_id
                  , dateadd(mm, datediff(mm, 0, date), 0)

                union all

                select
                    partner_id = RP.value_id
                  , date       = dateadd(mm, datediff(mm, 0, date), 0)
                  , doc_type   = 'Stock'
                  , product_id = ST.product_id
                  , qty        = sum(ST.quantity_item)
                from
                    mdm.dbo.mdm_retailer TT
                    inner join mdm.dbo.mdm_retailerpartner RP
                        on TT.id = RP.name_id
                    inner join mdm.dbo.mdm_stock ST
                        on TT.id = ST.retailer_id
                where
                      TT.is_fake = 1
                  and ST.date between '20210101' and '20221231'

                group by
                    RP.value_id
                  , ST.product_id
                  , TT.ext_id
                  , dateadd(mm, datediff(mm, 0, date), 0)
    )
select
    partner  = PA.name
  , date
  , doc_type
  , product  = PR.name
  , category = C.name
  , brand    = B.name
  , segment  = S.name
  , ean
  , code
  , qty      = sum(qty)
into mdm.dbo.mdm_report_data_si_sth_stock
from
    data D
    inner join mdm.dbo.mdm_partner PA
        on D.partner_id = PA.id
    inner join mdm.dbo.mdm_product PR
        on PR.id = D.product_id
    inner join mdm.dbo.mdm_attributebrand B
        on PR.brand_id = B.id
    inner join mdm.dbo.mdm_attributecategory C
        on PR.category_id = C.id
    inner join mdm.dbo.mdm_attributesegment S
        on PR.segment_id = S.id
group by
    PA.name
  , date
  , doc_type
  , PR.name
  , C.name
  , B.name
  , S.name
  , ean
  , code;