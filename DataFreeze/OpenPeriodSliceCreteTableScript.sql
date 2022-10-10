USE [HBCAMS_IntegrationDB]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create table bi.OpenPeriodFreeze
(
    datafreeze_type              nvarchar(50),
    business_name                nvarchar(100),
    division_id                  int,
    division_name                nvarchar(4000),
    distributor_id               uniqueidentifier,
    distributor_name             nvarchar(160),
    account_id                   uniqueidentifier,
    account_name                 nvarchar(160),
    approve_cluster_name         nvarchar(100),
    account_channel              nvarchar(4000),
    delivery_lag                 int,
    sales_channel                nvarchar(4000),
    nrm                          nvarchar(4000),
    rating                       nvarchar(4000),
    hq                           nvarchar(100),
    is_it_have_parent            bit,
    is_covered_by_nielsen        nvarchar(4000),
    apopartner_code              nvarchar(100),
    apopartner_name              nvarchar(100),
    promo_id                     uniqueidentifier,
    promo_key                    int,
    promo_name                   nvarchar(100),
    promo_short_name             nvarchar(200),
    order_from                   datetime,
    order_to                     datetime,
    delivery_from                datetime,
    delivery_to                  datetime,
    onshelf_from                 datetime,
    onshelf_to                   datetime,
    mechanics                    nvarchar(4000),
    mechanics_individual         nvarchar(100),
    mechanics_1                  nvarchar(4000),
    mechanics_2                  nvarchar(4000),
    promo_type                   nvarchar(4000),
    is_scenario_included_working bit,
    henkel_promo_status          nvarchar(4000),
    promo_class                  nvarchar(4000),
    pc_guideline                 nvarchar(4000),
    ppd_guideline                nvarchar(4000),
    roi_guideline                nvarchar(4000),
    line_name                    nvarchar(100),
    category_name                nvarchar(100),
    brand_id                     uniqueidentifier,
    brand_name                   nvarchar(100),
    product_id                   uniqueidentifier,
    product_name                 nvarchar(231),
    ean                          nvarchar(100),
    lst_status                   nvarchar(4000),
    national_listing_date        datetime,
    national_delisting_date      datetime,
    product_volume               nvarchar(100),
    shipment_date                datetime,
    delivery_date                datetime,
    forecast_status              varchar(11),
    scenario                     varchar(14),
    activity_type                varchar(20),
    data_type                    nvarchar(4000),
    data_type_lvl0               varchar(12),
    data_type_lvl1               varchar(12),
    data_type_lvl2               varchar(16),
    con                          decimal(38, 10),
    cpv                          decimal(38, 10),
    rp                           decimal(38, 10),
    ges                          decimal(38, 10),
    nes                          decimal(38, 10),
    pld                          decimal(38, 10),
    pxd                          decimal(38, 10),
    ppd                          decimal(38, 10),
    ppd_distr                    decimal(38, 10),
    oncch                        decimal(38, 10),
    oncdb                        decimal(38, 10),
    offcch                       decimal(38, 10),
    offcdb                       decimal(38, 10),
    offextra                     decimal(38, 10),
    offextra_abs                 decimal(38, 10),
    comm                         decimal(38, 10),
    trwh                         decimal(38, 10),
    matcost                      decimal(38, 10),
    l17                          decimal(38, 10),
    gp1                          decimal(38, 10),
    gp2                          decimal(38, 10),
    offc_promo_abs               decimal(38, 10),
    offc_promo_perc              decimal(38, 10),
    bs_con_fc                    decimal(38, 10),
    shelf_disc                   decimal(23, 10),
    price_pld                    decimal(23, 10),
    price_ges                    decimal(23, 10),
    trdcond_On_cdb               decimal(38, 10),
    trdcond_Off_cdb              decimal(38, 10)
)
go

INSERT INTO [bi].[OpenPeriodFreeze]
SELECT *
FROM [dbo].[DataFreezeView]
GO

CREATE INDEX DataFreeze_type_index
    ON [bi].[OpenPeriodFreeze] (datafreeze_type)
GO

CREATE INDEX DataFreeze_account_id_index
    ON [bi].[OpenPeriodFreeze] (account_id)
GO

CREATE INDEX DataFreeze_delivery_date_index
    ON [bi].[OpenPeriodFreeze] (delivery_date)
GO

--set datafreeze_type = 'Closed Period'
--set datafreeze_type = 'Archive slice'
--set datafreeze_type = 'Fixed slice'
--set datafreeze_type = 'Updatable slice'

UPDATE [bi].[OpenPeriodFreeze]
SET [datafreeze_type] = 'Closed Period'
WHERE [delivery_date] < '20201101'

UPDATE [bi].[OpenPeriodFreeze]
SET [datafreeze_type] = 'Archive slice'
WHERE [delivery_date] >= '20201101'


USE [HBCAMS_IntegrationDB]
GO

ALTER INDEX [DataFreeze_type_index] ON [bi].[OpenPeriodFreeze]
    REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)
GO

ALTER INDEX [DataFreeze_account_id_index] ON [bi].[OpenPeriodFreeze]
    REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)
GO

ALTER INDEX [DataFreeze_delivery_date_index] ON [bi].[OpenPeriodFreeze]
    REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80)
GO