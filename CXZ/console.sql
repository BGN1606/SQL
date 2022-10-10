use mdm
go

-- Category
exec dbo.mdm_sync_1c_TrademarkCategories_and_mdm_AttributeCategory;
select * from mdm.dbo.mdm_attributecategory;

-- Brand
exec dbo.mdm_sync_1c_Trademarks_and_mdm_AttributeBrand;
select * from mdm.dbo.mdm_attributebrand;

-- Segment
exec dbo.mdm_sync_1c_Segments_and_mdm_AttributeSegment;
select * from mdm.dbo.mdm_attributesegment;

-- Product
exec dbo.mdm_sync_1c_Products_and_mdm_Product;
select * from dbo.mdm_product;

-- PartnerTypes
exec dbo.mdm_sync_1c_PartnerTypes_and_mdm_AttributePartnerType;
select * from mdm_attributepartnertype;

-- Partner
exec dbo.mdm_sync_1c_Partner_and_mdm_Partner;
select * from mdm_Partner;

-- Client
-- exec dbo.mdm_sync_Spot_Client_and_mdm_Client;
-- select * from mdm_client;

-- Area
exec mdm_sync_Spot_Area_and_mdm_AttributeArea;
select * from mdm_attributearea;

-- Chain
exec mdm_sync_Spot_Chain_and_mdm_AttributeChain;
select * from mdm_attributechain;

-- TradeChannel
exec mdm_sync_Spot_TradeChannel_and_mdm_AttributeTradeChannel;
select * from mdm.dbo.mdm_attributetradechannel;

-- Spot Employee
exec mdm_sync_Spot_Employee_and_mdm_Employee;
select * from mdm.dbo.mdm_employee;

-- Atrribute Location
exec mdm_sync_Spot_location_and_mdm_location;
select * from mdm_attributelocation;

-- Retailer
exec mdm_sync_Spot_retailer_and_mdm_retailer;
-- select * from mdm.dbo.mdm_retailer;
select count(*) from mdm.dbo.mdm_retailer where isnull(is_fake,0) = 1;

-- Section
exec mdm_sync_Spot_Section_and_mdm_AttributeSection;
select * from mdm.dbo.mdm_attributesection;

-- SellIn
declare @start_date date = '20160101', @end_date date = '20221231'
exec mdm.dbo.mdm_sync_SellIn @start_date = @start_date, @end_date = @end_date
exec mdm.dbo.mdm_sync_SellInRow @start_date = @start_date, @end_date = @end_date
select * from mdm.dbo.mdm_invoicesellin

-- SellThrough
exec mdm_sync_InvoiceSellThrough @start_date = '20220101', @end_date = '20221231'
exec mdm_sync_InvoiceSellThroughRow @start_date = '20220101', @end_date = '20221231'
select * from mdm.dbo.mdm_invoicesellthrough

-- Stock
exec mdm.dbo.mdm_sync_Stock '20140101', '20141231'
exec mdm.dbo.mdm_sync_Stock '20150101', '20151231'
exec mdm.dbo.mdm_sync_Stock '20160101', '20161231'
exec mdm.dbo.mdm_sync_Stock '20170101', '20171231'
exec mdm.dbo.mdm_sync_Stock '20180101', '20181231'
exec mdm.dbo.mdm_sync_Stock '20190101', '20191231'
exec mdm.dbo.mdm_sync_Stock '20200101', '20201231'
exec mdm.dbo.mdm_sync_Stock '20210101', '20211231'
exec mdm.dbo.mdm_sync_Stock '20220101', '20221231'


/*1c*/
select * from integrationDB.dbo.[1c_Areas]
select * from integrationDB.dbo.[1c_Divisions]
select * from integrationDB.dbo.[1c_Employees]
select * from integrationDB.dbo.[1c_MMLGroups]
select * from integrationDB.dbo.[1c_Partners]
select * from integrationDB.dbo.[1c_PartnerTypes]
select * from integrationDB.dbo.[1c_Products]
select * from integrationDB.dbo.[1c_Regions]
select * from integrationDB.dbo.[1c_SectionsTM]
select * from integrationDB.dbo.[1c_Segments]
select * from integrationDB.dbo.[1c_Trademarks]
select * from integrationDB.dbo.[1c_TrademarkCategories]
select * from integrationDB.dbo.[1c_PriceTypes]


/*Spot2d*/
select * from integrationDB.dbo.spot2d_bi_distr
select * from integrationDB.dbo.spot2d_bi_sets
select * from integrationDB.dbo.spot2d_bi_ta
select * from integrationDB.dbo.spot2d_bi_tt_attribute_values
select * from integrationDB.dbo.spot2d_bi_tt_attributes
select * from integrationDB.dbo.spot2d_bi_ttoptions
select * from integrationDB.dbo.spot2d_bi_products
-- справочник цен производителя
select * from integrationDB.dbo.spot2d_bi_price

--------
-- Отгрузки
select * from integrationDB.dbo.[1c_Invoices]
select * from integrationDB.dbo.[1c_InvoiceRows]
where Invoice_id = 109955

-- данные об обороте продукции (отгрузки на ТТ, возвраты с ТТ, корректировочный СФ)
select * from integrationDB.dbo.spot2d_bi_delivery

-- данные по остаткам продукции на складе дистрибутора
select date, group_id, id_product, amount, money_purchase from integrationDB.dbo.spot2d_bi_stocks


-- данные по перемещениям между дистрибуторами
select * from integrationDB.dbo.spot2d_bi_movements
-- данные по приходам дистрибутора и возвраты производителю
select * from integrationDB.dbo.spot2d_bi_receive
-- данные по другим операциям, которые не могут быть отнесены к файлу delivery (списание, недостача, излишки)
select * from integrationDB.dbo.spot2d_bi_cancellations



-- данные по остаткам продукции на складе дистрибутора

-- 56 299 150
-- 53 021 231
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


select * from mdm.dbo.mdm_stock;
