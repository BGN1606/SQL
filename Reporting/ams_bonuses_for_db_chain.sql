--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--BEGIN TRANSACTION;

--declare @reportDate as date = '20190501', @ep nvarchar (100) = '24 chasa_VladivostokVIP';

declare @ams_bonuses table
                     (
                         [month]                                      nvarchar(50)   null,
                         [division]                                   nvarchar(50)   null,
                         [distributor_total]                          nvarchar(50)   null,
                         [distributor]                                nvarchar(50)   null,
                         [hq]                                         nvarchar(100)  null,
                         [chain]                                      nvarchar(100)  null,
                         [ep_id]                                      nvarchar(100)  null,
                         [ep_name]                                    nvarchar(100)  null,

                         [assortment_plan]                            decimal(19, 9) null,
                         [assortment_fact]                            decimal(19, 9) null,
                         [assortment_contract_conditions_perc]        decimal(19, 9) null,
                         [assortment_execution_perc]                  decimal(19, 9) null,
                         [assortment_calc_conditions_perc]            decimal(19, 9) null,
                         [assortment_resellprice]                     decimal(19, 9) null,
                         [assortment_bonus_abs]                       decimal(19, 9) null,
                         [assortment_comment_bonus_perc]              decimal(19, 9) null,
                         [assortment_comment_bonus_abs]               decimal(19, 9) null,
                         [assortment_comment_bonus_reason]            nvarchar(255)  null,
                         [assortment_agreed]                          bit            null,
                         [assortment_total_bonus_perc]                decimal(19, 9) null,
                         [assortment_total_bonus_abs]                 decimal(19, 9) null,

                         [growth_plan]                                decimal(19, 9) null,
                         [growth_fact]                                decimal(19, 9) null,
                         [growth_contract_conditions_perc]            decimal(19, 9) null,
                         [growth_execution_perc]                      decimal(19, 9) null,
                         [growth_calc_conditions_perc]                decimal(19, 9) null,
                         [growth_resellprice]                         decimal(19, 9) null,
                         [growth_bonus_abs]                           decimal(19, 9) null,
                         [growth_comment_bonus_perc]                  decimal(19, 9) null,
                         [growth_comment_bonus_abs]                   decimal(19, 9) null,
                         [growth_comment_bonus_reason]                nvarchar(255)  null,
                         [growth_agreed]                              bit            null,
                         [growth_total_bonus_perc]                    decimal(19, 9) null,
                         [growth_total_bonus_abs]                     decimal(19, 9) null,

                         [innovation_plan]                            decimal(19, 9) null,
                         [innovation_fact]                            decimal(19, 9) null,
                         [innovation_contract_conditions_perc]        decimal(19, 9) null,
                         [innovation_execution_perc]                  decimal(19, 9) null,
                         [innovation_calc_conditions_perc]            decimal(19, 9) null,
                         [innovation_resellprice]                     decimal(19, 9) null,
                         [innovation_bonus_abs]                       decimal(19, 9) null,
                         [innovation_comment_bonus_perc]              decimal(19, 9) null,
                         [innovation_comment_bonus_abs]               decimal(19, 9) null,
                         [innovation_comment_bonus_reason]            nvarchar(255)  null,
                         [innovation_agreed]                          bit            null,
                         [innovation_total_bonus_perc]                decimal(19, 9) null,
                         [innovation_total_bonus_abs]                 decimal(19, 9) null,

                         [innovation_on-top_contract_conditions_perc] decimal(19, 9) null,
                         [innovation_on-top_calc_conditions_perc]     decimal(19, 9) null,
                         [innovation_on-top_resellprice]              decimal(19, 9) null,
                         [innovation_on-top_bonus_abs]                decimal(19, 9) null,
                         [innovation_on-top_comment_bonus_perc]       decimal(19, 9) null,
                         [innovation_on-top_comment_bonus_abs]        decimal(19, 9) null,
                         [innovation_on-top_comment_bonus_reason]     nvarchar(255)  null,
                         [innovation_on-top_agreed]                   bit            null,
                         [innovation_on-top_total_bonus_perc]         decimal(19, 9) null,
                         [innovation_on-top_total_bonus_abs]          decimal(19, 9) null,

                         [inout_plan]                                 decimal(19, 9) null,
                         [inout_fact]                                 decimal(19, 9) null,
                         [inout_contract_conditions_perc]             decimal(19, 9) null,
                         [inout_execution_perc]                       decimal(19, 9) null,
                         [inout_calc_conditions_perc]                 decimal(19, 9) null,
                         [inout_resellprice]                          decimal(19, 9) null,
                         [inout_bonus_abs]                            decimal(19, 9) null,
                         [inout_comment_bonus_perc]                   decimal(19, 9) null,
                         [inout_comment_bonus_abs]                    decimal(19, 9) null,
                         [inout_comment_bonus_reason]                 nvarchar(255)  null,
                         [inout_agreed]                               bit            null,
                         [inout_total_bonus_perc]                     decimal(19, 9) null,
                         [inout_total_bonus_abs]                      decimal(19, 9) null,

                         [color_contract_conditions_perc]             decimal(19, 9) null,
                         [color_resellPrice]                          decimal(19, 9) null,
                         [color_bonus_abs]                            decimal(19, 9) null,
                         [color_comment_bonus_perc]                   decimal(19, 9) null,
                         [color_comment_bonus_abs]                    decimal(19, 9) null,
                         [color_comment_bonus_reason]                 nvarchar(255)  null,
                         [color_agreed]                               bit            null,
                         [color_total_bonus_perc]                     decimal(19, 9) null,
                         [color_total_bonus_abs]                      decimal(19, 9) null,

                         [individual_contract_conditions_perc]        decimal(19, 9) null,
                         [individual_resellPrice]                     decimal(19, 9) null,
                         [individual_bonus_abs]                       decimal(19, 9) null,
                         [individual_comment_bonus_perc]              decimal(19, 9) null,
                         [individual_comment_bonus_abs]               decimal(19, 9) null,
                         [individual_comment_bonus_reason]            nvarchar(255)  null,
                         [individual_agreed]                          bit            null,
                         [individual_total_bonus_perc]                decimal(19, 9) null,
                         [individual_total_bonus_abs]                 decimal(19, 9) null,

                         [logistic_contract_conditions_perc]          decimal(19, 9) null,
                         [logistic_resellPrice]                       decimal(19, 9) null,
                         [logistic_bonus_abs]                         decimal(19, 9) null,
                         [logistic_comment_bonus_perc]                decimal(19, 9) null,
                         [logistic_comment_bonus_abs]                 decimal(19, 9) null,
                         [logistic_comment_bonus_reason]              nvarchar(255)  null,
                         [logistic_agreed]                            bit            null,
                         [logistic_total_bonus_perc]                  decimal(19, 9) null,
                         [logistic_total_bonus_abs]                   decimal(19, 9) null,

                         [planogram_contract_conditions_perc]         decimal(19, 9) null,
                         [planogram_resellPrice]                      decimal(19, 9) null,
                         [planogram_bonus_abs]                        decimal(19, 9) null,
                         [planogram_comment_bonus_perc]               decimal(19, 9) null,
                         [planogram_comment_bonus_abs]                decimal(19, 9) null,
                         [planogram_comment_bonus_reason]             nvarchar(255)  null,
                         [planogram_agreed]                           bit            null,
                         [planogram_total_bonus_perc]                 decimal(19, 9) null,
                         [planogram_total_bonus_abs]                  decimal(19, 9) null,

                         [promoplan_contract_conditions_perc]         decimal(19, 9) null,
                         [promoplan_resellPrice]                      decimal(19, 9) null,
                         [promoplan_bonus_abs]                        decimal(19, 9) null,
                         [promoplan_comment_bonus_perc]               decimal(19, 9) null,
                         [promoplan_comment_bonus_abs]                decimal(19, 9) null,
                         [promoplan_comment_bonus_reason]             nvarchar(255)  null,
                         [promoplan_agreed]                           bit            null,
                         [promoplan_total_bonus_perc]                 decimal(19, 9) null,
                         [promoplan_total_bonus_abs]                  decimal(19, 9) null,

                         [reporting_contract_conditions_perc]         decimal(19, 9) null,
                         [reporting_resellPrice]                      decimal(19, 9) null,
                         [reporting_bonus_abs]                        decimal(19, 9) null,
                         [reporting_comment_bonus_perc]               decimal(19, 9) null,
                         [reporting_comment_bonus_abs]                decimal(19, 9) null,
                         [reporting_comment_bonus_reason]             nvarchar(255)  null,
                         [reporting_agreed]                           bit            null,
                         [reporting_total_bonus_perc]                 decimal(19, 9) null,
                         [reporting_total_bonus_abs]                  decimal(19, 9) null,

                         [secondary_contract_conditions_perc]         decimal(19, 9) null,
                         [secondary_resellPrice]                      decimal(19, 9) null,
                         [secondary_bonus_abs]                        decimal(19, 9) null,
                         [secondary_comment_bonus_perc]               decimal(19, 9) null,
                         [secondary_comment_bonus_abs]                decimal(19, 9) null,
                         [secondary_comment_bonus_reason]             nvarchar(255)  null,
                         [secondary_agreed]                           bit            null,
                         [secondary_total_bonus_perc]                 decimal(19, 9) null,
                         [secondary_total_bonus_abs]                  decimal(19, 9) null,

                         [shelf_share_contract_conditions_perc]       decimal(19, 9) null,
                         [shelf_share_resellPrice]                    decimal(19, 9) null,
                         [shelf_share_bonus_abs]                      decimal(19, 9) null,
                         [shelf_share_comment_bonus_perc]             decimal(19, 9) null,
                         [shelf_share_comment_bonus_abs]              decimal(19, 9) null,
                         [shelf_share_comment_bonus_reason]           nvarchar(255)  null,
                         [shelf_share_agreed]                         bit            null,
                         [shelf_share_total_bonus_perc]               decimal(19, 9) null,
                         [shelf_share_total_bonus_abs]                decimal(19, 9) null,

                         [BMC_contract_perc]                          decimal(19, 9) null,
                         [BMC_contract_abs]                           decimal(19, 9) null,
                         [BMC_calculated_perc]                        decimal(19, 9) null,
                         [BMC_Total_actual]                           decimal(19, 9) null,
                         [BMC_LKAM/RKAM_perc]                         decimal(19, 9) null,
                         [BMC_LKAM/RKAM_abs]                          decimal(19, 9) null,
                         [Off_Extra_calculated_perc]                  decimal(19, 9) null,
                         [Off_Extra_abs]                              decimal(19, 9) null,
                         [Off_Extra_LKAM/RKAM_perc]                   decimal(19, 9) null,
                         [Off_Extra_LKAM/RKAM_abs]                    decimal(19, 9) null
                     );

declare @sql varchar(300) = concat('exec [Schwarzkopf].[dbo].[ams_bonuses_db_chain] ''', @reportDate, '''')

insert into @ams_bonuses
    exec (@sql) at VM1

select *
from @ams_bonuses
where [ep_name] in (@EP)

--COMMIT TRANSACTION;


-- Filters
-- EP
select distinct Name
from HBCAMS_MSCRM.dbo.FilteredAccount

-- ReportDate
exec [HBCAMS_MSCRM].[dbo].[ams_date_generator] '20200101', '20201201'
