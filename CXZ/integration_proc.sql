use integrationDB
go

/*
{{{ Интеграция справочников }}}
*/
raiserror ('Products', 0,1) with nowait
exec integrationDB.dbo.sp_bi_products_integration;

raiserror ('Distr', 0,1) with nowait
exec integrationDB.dbo.sp_bi_distr_integration;

raiserror ('TA', 0,1) with nowait
exec integrationDB.dbo.sp_bi_ta_integration;

raiserror ('TT_Attrs', 0,1) with nowait
exec integrationDB.dbo.sp_bi_tt_attributes_integration;

raiserror ('TT_Attrs_Value', 0,1) with nowait
exec integrationDB.dbo.sp_bi_tt_attribute_values_integration;

raiserror ('TT_Options', 0,1) with nowait
exec integrationDB.dbo.sp_bi_ttoptions_integration;

raiserror ('Sets', 0,1) with nowait
exec integrationDB.dbo.sp_bi_sets_integration;

/*
{{{ Интеграция транзакционных данных }}}

*/
declare @sdate date = '20220901' , @edate date = '20220930'

raiserror ('cancellations', 0,1) with nowait
exec integrationDB.dbo.sp_bi_cancellations_integration @start_date = @sdate, @end_date = @edate;

raiserror ('delivery', 0,1) with nowait
exec integrationDB.dbo.sp_bi_delivery_integration @start_date = @sdate, @end_date = @edate;

raiserror ('movements', 0,1) with nowait
exec integrationDB.dbo.sp_bi_movements_integration @start_date = @sdate, @end_date = @edate;

raiserror ('plans', 0,1) with nowait
exec integrationDB.dbo.sp_bi_plans_integration @start_date = @sdate, @end_date = @edate;

raiserror ('price', 0,1) with nowait
exec integrationDB.dbo.sp_bi_price_integration @start_date = @sdate, @end_date = @edate;

raiserror ('receive', 0,1) with nowait
exec integrationDB.dbo.sp_bi_receive_integration @start_date = @sdate, @end_date = @edate;

raiserror ('stocks', 0,1) with nowait
exec integrationDB.dbo.sp_bi_stocks_integration @start_date = @sdate, @end_date = @edate;
