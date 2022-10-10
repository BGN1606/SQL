
select * from bi_ta();

select * from bi_distr();

select * from bi_allowed_groups();

select * from bi_cancellations('20220701', '20220715');

select * from bi_cancellations_aggregated('20220701', '20220715');

select * from bi_custom_form_components();

select * from bi_custom_form_fields();

select * from bi_custom_form_params();

select * from bi_custom_form_values('20220701', '20220715');

select * from bi_custom_form_values_by_field('20220701', '20220715');

select * from bi_delivery('20220701', '20220715');

select * from bi_delivery_aggregated('20220701', '20220715');

select * from bi_distr();

select * from bi_form_matrix_by_shop(form_id := '');

select * from bi_invoices('20220701', '20220715');

select * from bi_itt();

select * from bi_module2shops();

select * from bi_module2workers();

select * from bi_modules();

select * from bi_moneys('20220701', '20220715');

select * from bi_movements('20220701', '20220715');

select * from bi_movements_aggregated();

select * from bi_offtake();

select * from bi_orders();

select * from bi_plans();

select * from bi_pm();

select * from bi_price();

select * from bi_products();

select * from bi_receive();

select * from bi_receive_aggregated();

select * from bi_refunds();

select * from bi_routes();

select * from bi_sets();

select * from bi_stocks();

select * from bi_stocks_aggregated();

select * from bi_stocks_tt();

select * from bi_synchronizations();

select * from bi_ta();

select * from bi_tt_attribute_values();

select * from bi_tt_attributes();

select * from bi_ttoptions();

select * from bi_visits();

select * from bi_workdays();

select * from bi_worker2shops();

select * from bi_worker_movements();

select * from bi_workers();


select count(distinct attribute5) from bi_ttoptions();