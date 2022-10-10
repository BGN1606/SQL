ALTER PROCEDURE [bi].[FixedPeriodSliceUpdater] @err INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @err = 0
    -- Выбираем ЕП с [new_is_NeedFixedSliceUpdate] = 1 из view Account
    -- 30 rows affected in 77 ms
    IF OBJECT_ID('tempdb..#NeedFixedSliceUpdate') IS NOT NULL
        DROP TABLE [#NeedFixedSliceUpdate];

    SELECT [AccountId]
    INTO [#NeedFixedSliceUpdate]
    FROM [HBCAMS_MSCRM].[dbo].[Account]
    WHERE [new_is_NeedFixedSliceUpdate] = 1


    -- Удаляем из таблицы [bi].[OpenPeriodFreeze] все строки с типом 'Updatable slice' и ЕП из списка #NeedFixedSliceUpdate
    -- 521015 rows affected in 2 m 29 s 49 ms
    DELETE [HBCAMS_IntegrationDB].[bi].[OpenPeriodFreeze]
    WHERE [datafreeze_type] = 'Fixed slice'
      AND [account_id] IN (SELECT * FROM [#NeedFixedSliceUpdate])


    -- Копируем новые данные по ЕП с [new_is_NeedFixedSliceUpdate] = 1 из [dbo].[DataFreezeView] в [bi].[OpenPeriodFreeze]
    -- 522833 rows affected in 14 m 24 s 867 ms
    DECLARE @date DATE = (SELECT MAX([delivery_date]) FROM [bi].[ClosePeriodFreeze]);

    INSERT INTO [HBCAMS_IntegrationDB].[bi].[OpenPeriodFreeze]

    SELECT 'Fixed slice',
           business_name,
           division_id,
           division_name,
           distributor_id,
           distributor_name,
           account_id,
           account_name,
           approve_cluster_name,
           account_channel,
           delivery_lag,
           sales_channel,
           nrm,
           rating,
           hq,
           is_it_have_parent,
           is_covered_by_nielsen,
           apopartner_code,
           apopartner_name,
           promo_id,
           promo_key,
           promo_name,
           promo_short_name,
           order_from,
           order_to,
           delivery_from,
           delivery_to,
           onshelf_from,
           onshelf_to,
           mechanics,
           mechanics_individual,
           mechanics_1,
           mechanics_2,
           promo_type,
           is_scenario_included_working,
           henkel_promo_status,
           promo_class,
           pc_guideline,
           ppd_guideline,
           roi_guideline,
           line_name,
           category_name,
           brand_id,
           brand_name,
           product_id,
           product_name,
           ean,
           lst_status,
           national_listing_date,
           national_delisting_date,
           product_volume,
           shipment_date,
           delivery_date,
           forecast_status,
           scenario,
           activity_type,
           data_type,
           data_type_lvl0,
           data_type_lvl1,
           data_type_lvl2,
           con,
           cpv,
           rp,
           ges,
           nes,
           pld,
           pxd,
           ppd,
           ppd_distr,
           oncch,
           oncdb,
           offcch,
           offcdb,
           offextra,
           offextra_abs,
           comm,
           trwh,
           matcost,
           l17,
           gp1,
           gp2,
           offc_promo_abs,
           offc_promo_perc,
           bs_con_fc,
           shelf_disc,
           price_pld,
           price_ges,
           trdcond_On_cdb,
           trdcond_Off_cdb
    FROM [HBCAMS_IntegrationDB].[dbo].[DataFreezeView] WITH (NOLOCK)
    WHERE [delivery_date] > @date
      AND [account_id] IN (SELECT * FROM [#NeedFixedSliceUpdate]);
    SET @err = 1
END
go
