CREATE OR REPLACE FUNCTION unit_tests.presencer()
RETURNS int
LANGUAGE plpgsql
AS $function$
DECLARE
	res int := 0;
BEGIN
	CREATE TABLE IF NOT EXISTS unit_tests.presence_table
	(
		schema_name varchar (20)
		, object_name varchar (200)
		, object_type varchar (50)
		, comment varchar (250)
	);
	
	delete from unit_tests.presence_table;
	
	-- Vérifier si des éléments sont manquants
	with cte_func_list as
	(
		select *
		from 
			(VALUES
				('common', 'build_if_has_to_fks')
				,('common', 'build_if_has_to_idxs')
				,('common', 'build_if_has_to_pks')
				,('common', 'build_if_has_to_roles')
				,('common', 'build_if_has_to_sqs')
				,('common', 'build_if_has_to_tables')
				,('common', 'check_column_presence')
				,('common', 'check_data_purge_retentioninterval')
				,('common', 'check_table_presence')
				,('common', 'constraint_naming_control')
				,('common', 'constraint_naming_control_first')
				,('common', 'constraint_naming_control_limiter')
				,('common', 'create_new_client')
				,('common', 'data_purge')
				,('common', 'deblog')
				,('common', 'delete_indexes_on_cascade')
				,('common', 'drop_cascade_fks')
				,('common', 'drop_cascade_pks')
				,('common', 'drop_cascade_roles')
				,('common', 'drop_client')
				,('common', 'drop_roles')
				,('common', 'isnumeric')
				,('common', 'sys_index_diag')
				,('common', 'sys_vacuum_diag')
				,('common', 'up_version')
				,('master', 'ddl_trigger_alter_table_fct')
				,('master', 'ddl_trigger_create_idx_fct')
				,('master', 'ddl_trigger_create_table_fct')
				,('master', 'ddl_trigger_drop_idx_fct')
				,('master', 'ddl_trigger_drop_table_fct')
				,('master', 'pg_relpages')
				,('master', 'pgstatindex')
				,('master', 'pgstatginindex')
				,('master', 'pgstathashindex')
				,('master', 'pgstattuple_approx')
				,('master', 'pg_relpages')
				,('master', 'pgstatindex')
				,('master', 'pgstatginindex')
				,('master', 'pgstathashindex')
				,('master', 'pgstattuple')
				,('master', 'pgstattuple')
				,('master', 'pgstattuple_approx')
				,('unit_tests', 'build_if_has_to_fks_err_1')
				,('unit_tests', 'build_if_has_to_fks_err_1_res')
				,('unit_tests', 'build_if_has_to_fks_nom_1')
				,('unit_tests', 'build_if_has_to_fks_nom_1_res')
				,('unit_tests', 'build_if_has_to_fks_nom_2')
				,('unit_tests', 'build_if_has_to_fks_nom_2_res')
				,('unit_tests', 'build_if_has_to_fks_nom_3')
				,('unit_tests', 'build_if_has_to_fks_nom_3_res')
				,('unit_tests', 'build_if_has_to_idxs_err_1')
				,('unit_tests', 'build_if_has_to_idxs_err_1_res')
				,('unit_tests', 'build_if_has_to_idxs_nom_1')
				,('unit_tests', 'build_if_has_to_idxs_nom_1_res')
				,('unit_tests', 'build_if_has_to_idxs_nom_2')
				,('unit_tests', 'build_if_has_to_idxs_nom_2_res')
				,('unit_tests', 'build_if_has_to_idxs_nom_3')
				,('unit_tests', 'build_if_has_to_idxs_nom_3_res')
				,('unit_tests', 'build_if_has_to_pks_nom_1')
				,('unit_tests', 'build_if_has_to_pks_nom_1_res')
				,('unit_tests', 'build_if_has_to_pks_nom_2')
				,('unit_tests', 'build_if_has_to_pks_nom_2_res')
				,('unit_tests', 'build_if_has_to_pks_nom_3')
				,('unit_tests', 'build_if_has_to_pks_nom_3_res')
				,('unit_tests', 'build_if_has_to_pks_nom_4')
				,('unit_tests', 'build_if_has_to_pks_nom_4_res')
				,('unit_tests', 'build_if_has_to_pks_nom_5')
				,('unit_tests', 'build_if_has_to_pks_nom_5_res')
				,('unit_tests', 'build_if_has_to_pks_nom_6')
				,('unit_tests', 'build_if_has_to_pks_nom_6_res')
				,('unit_tests', 'build_if_has_to_roles_err_1')
				,('unit_tests', 'build_if_has_to_roles_err_1_res')
				,('unit_tests', 'build_if_has_to_roles_err_2')
				,('unit_tests', 'build_if_has_to_roles_err_2_res')
				,('unit_tests', 'build_if_has_to_roles_nom_1')
				,('unit_tests', 'build_if_has_to_roles_nom_1_res')
				,('unit_tests', 'build_if_has_to_roles_nom_2')
				,('unit_tests', 'build_if_has_to_roles_nom_2_res')
				,('unit_tests', 'build_if_has_to_roles_nom_3')
				,('unit_tests', 'build_if_has_to_roles_nom_3_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_1')
				,('unit_tests', 'build_if_has_to_sqs_nom_1_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_2')
				,('unit_tests', 'build_if_has_to_sqs_nom_2_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_3')
				,('unit_tests', 'build_if_has_to_sqs_nom_3_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_4')
				,('unit_tests', 'build_if_has_to_sqs_nom_4_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_5')
				,('unit_tests', 'build_if_has_to_sqs_nom_5_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_6_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_6')
				,('unit_tests', 'build_if_has_to_sqs_nom_7')
				,('unit_tests', 'build_if_has_to_sqs_nom_7_res')
				,('unit_tests', 'build_if_has_to_tables_nom_1')
				,('unit_tests', 'build_if_has_to_tables_nom_1_res')
				,('unit_tests', 'build_if_has_to_tables_nom_2')
				,('unit_tests', 'build_if_has_to_tables_nom_2_res')
				,('unit_tests', 'check_column_presence_err_1')
				,('unit_tests', 'check_column_presence_nom_1')
				,('unit_tests', 'check_data_purge_retentioninterval_err_1')
				,('unit_tests', 'check_data_purge_retentioninterval_nom_1')
				,('unit_tests', 'check_table_presence_err_1')
				,('unit_tests', 'check_table_presence_nom_1')
				,('unit_tests', 'clean_all_clients')
				,('unit_tests', 'constraint_naming_control_err_1')
				,('unit_tests', 'constraint_naming_control_err_1_res')
				,('unit_tests', 'constraint_naming_control_err_2')
				,('unit_tests', 'constraint_naming_control_err_2_res')
				,('unit_tests', 'constraint_naming_control_nom_1')
				,('unit_tests', 'constraint_naming_control_nom_1_res')
				,('unit_tests', 'constraint_naming_control_nom_2')
				,('unit_tests', 'constraint_naming_control_nom_2_res')
				,('unit_tests', 'constraint_naming_control_nom_3')
				,('unit_tests', 'constraint_naming_control_nom_3_res')
				,('unit_tests', 'constraint_naming_control_nom_4')
				,('unit_tests', 'constraint_naming_control_nom_4_res')
				,('unit_tests', 'create_new_client_err_1')
				,('unit_tests', 'create_new_client_nom_1')
				,('unit_tests', 'create_new_client_nom_1_res')
				,('unit_tests', 'data_purge_err_1')
				,('unit_tests', 'data_purge_err_2')
				,('unit_tests', 'data_purge_err_3')
				,('unit_tests', 'data_purge_err_4')
				,('unit_tests', 'data_purge_err_5')
				,('unit_tests', 'data_purge_nom_1')
				,('unit_tests', 'data_purge_nom_1_res')
				,('unit_tests', 'deblog')
				,('unit_tests', 'deblog_nom_1')
				,('unit_tests', 'deblog_nom_1_res')
				,('unit_tests', 'delete_indexes_on_cascade_nom_1')
				,('unit_tests', 'delete_indexes_on_cascade_nom_1_res')
				,('unit_tests', 'delete_indexes_on_cascade_nom_2')
				,('unit_tests', 'delete_indexes_on_cascade_nom_2_res')
				,('unit_tests', 'delete_indexes_on_cascade_nom_3')
				,('unit_tests', 'delete_indexes_on_cascade_nom_3_res')
				,('unit_tests', 'drop_cascade_pks_nom_1')
				,('unit_tests', 'drop_cascade_pks_nom_1_res')
				,('unit_tests', 'drop_cascade_pks_nom_2')
				,('unit_tests', 'drop_cascade_pks_nom_2_res')
				,('unit_tests', 'drop_cascade_pks_nom_3')
				,('unit_tests', 'drop_cascade_pks_nom_3_res')
				,('unit_tests', 'drop_cascade_pks_nom_4')
				,('unit_tests', 'drop_cascade_pks_nom_4_res')
				,('unit_tests', 'drop_cascade_roles_nom_1')
				,('unit_tests', 'drop_cascade_roles_nom_1_res')
				,('unit_tests', 'drop_client_err_1')
				,('unit_tests', 'drop_client_err_1_res')
				,('unit_tests', 'drop_client_nom_1')
				,('unit_tests', 'drop_client_nom_1_res')
				,('unit_tests', 'init_between_tests')
				,('unit_tests', 'sys_index_diag_nom_1')
				,('unit_tests', 'sys_index_diag_nom_1_res')
				,('unit_tests', 'sys_index_diag_nom_2')
				,('unit_tests', 'sys_index_diag_nom_2_res')
				,('unit_tests', 'sys_vacuum_diag_nom_1')
				,('unit_tests', 'sys_vacuum_diag_nom_1_res')
				,('unit_tests', 'presencer')
			) as t (schema_name, routine_name)
	)
	, cte_table_list as
	(
		select *
		from 
			(values
				('unit_tests', 'test_category')
				,('unit_tests', 'test_part')
				,('unit_tests', 'test')
				,('unit_tests', 'detail_report_table')
				,('common', 'purge_tool_conf')
				,('common', 'vacuum_script_results')
				,('common', 'debugger')
				,('common', 'index_script_results')
				,('common', 'dwh_dm_client')
				,('unit_tests', 'presence_table')
			) as t(schema_name, table_name)
	)
	, cte_evt_trg_list as
	(
		select *
		from 
			(values
				('ddl_trigger_create_table')
				,('ddl_trigger_create_idx')
				,('ddl_trigger_drop_table')
				,('ddl_trigger_drop_idx')
				,('ddl_trigger_alter_table')
			) as t(event_trigger_name)
	)
	insert into unit_tests.presence_table
	select distinct
		cte.schema_name as schema_name
		, cte.routine_name as name
		, 'FUNCTION OR PROCEDURE' as type
		, 'Cet élément devrait être en base et n''y est pas.' as comment
	from cte_func_list cte
	where (cte.schema_name, cte.routine_name) not in (
		select r.specific_schema, r.routine_name
		from information_schema."routines" r
		where specific_schema = 'common'
			or specific_schema = 'master'
			or specific_schema = 'unit_tests')
	union	
	select distinct
		cte.schema_name as schema_name
		, cte.table_name as name
		, 'TABLE' as type
		, 'Cet élément devrait être en base et n''y est pas.' as comment
	from cte_table_list cte
	where (cte.schema_name, cte.table_name) not in (
	select table_schema, table_name
	from information_schema."tables"
	where table_schema = 'common'
		or table_schema = 'unit_tests')
	union
	select distinct
		'NA' as schema_name
		, cte.event_trigger_name as name
		, 'EVENT_TRIGGER' as type
		, 'Cet élément devrait être en base et n''y est pas.' as comment
	from cte_evt_trg_list cte
	where cte.event_trigger_name not in (
		select evtname
		from pg_catalog.pg_event_trigger);
		
	-- Vérifier si des éléments ne sont pas référencés comme testés
	with cte_func_list as
	(
		select *
		from 
			(VALUES
				('common', 'build_if_has_to_fks')
				,('common', 'build_if_has_to_idxs')
				,('common', 'build_if_has_to_pks')
				,('common', 'build_if_has_to_roles')
				,('common', 'build_if_has_to_sqs')
				,('common', 'build_if_has_to_tables')
				,('common', 'check_column_presence')
				,('common', 'check_data_purge_retentioninterval')
				,('common', 'check_table_presence')
				,('common', 'constraint_naming_control')
				,('common', 'constraint_naming_control_first')
				,('common', 'constraint_naming_control_limiter')
				,('common', 'create_new_client')
				,('common', 'data_purge')
				,('common', 'deblog')
				,('common', 'delete_indexes_on_cascade')
				,('common', 'drop_cascade_fks')
				,('common', 'drop_cascade_pks')
				,('common', 'drop_cascade_roles')
				,('common', 'drop_client')
				,('common', 'drop_roles')
				,('common', 'isnumeric')
				,('common', 'sys_index_diag')
				,('common', 'sys_vacuum_diag')
				,('common', 'up_version')
				,('master', 'ddl_trigger_alter_table_fct')
				,('master', 'ddl_trigger_create_idx_fct')
				,('master', 'ddl_trigger_create_table_fct')
				,('master', 'ddl_trigger_drop_idx_fct')
				,('master', 'ddl_trigger_drop_table_fct')
				,('master', 'pg_relpages')
				,('master', 'pgstatindex')
				,('master', 'pgstatginindex')
				,('master', 'pgstathashindex')
				,('master', 'pgstattuple_approx')
				,('master', 'pg_relpages')
				,('master', 'pgstatindex')
				,('master', 'pgstatginindex')
				,('master', 'pgstathashindex')
				,('master', 'pgstattuple')
				,('master', 'pgstattuple')
				,('master', 'pgstattuple_approx')
				,('unit_tests', 'build_if_has_to_fks_err_1')
				,('unit_tests', 'build_if_has_to_fks_err_1_res')
				,('unit_tests', 'build_if_has_to_fks_nom_1')
				,('unit_tests', 'build_if_has_to_fks_nom_1_res')
				,('unit_tests', 'build_if_has_to_fks_nom_2')
				,('unit_tests', 'build_if_has_to_fks_nom_2_res')
				,('unit_tests', 'build_if_has_to_fks_nom_3')
				,('unit_tests', 'build_if_has_to_fks_nom_3_res')
				,('unit_tests', 'build_if_has_to_idxs_err_1')
				,('unit_tests', 'build_if_has_to_idxs_err_1_res')
				,('unit_tests', 'build_if_has_to_idxs_nom_1')
				,('unit_tests', 'build_if_has_to_idxs_nom_1_res')
				,('unit_tests', 'build_if_has_to_idxs_nom_2')
				,('unit_tests', 'build_if_has_to_idxs_nom_2_res')
				,('unit_tests', 'build_if_has_to_idxs_nom_3')
				,('unit_tests', 'build_if_has_to_idxs_nom_3_res')
				,('unit_tests', 'build_if_has_to_pks_nom_1')
				,('unit_tests', 'build_if_has_to_pks_nom_1_res')
				,('unit_tests', 'build_if_has_to_pks_nom_2')
				,('unit_tests', 'build_if_has_to_pks_nom_2_res')
				,('unit_tests', 'build_if_has_to_pks_nom_3')
				,('unit_tests', 'build_if_has_to_pks_nom_3_res')
				,('unit_tests', 'build_if_has_to_pks_nom_4')
				,('unit_tests', 'build_if_has_to_pks_nom_4_res')
				,('unit_tests', 'build_if_has_to_pks_nom_5')
				,('unit_tests', 'build_if_has_to_pks_nom_5_res')
				,('unit_tests', 'build_if_has_to_pks_nom_6')
				,('unit_tests', 'build_if_has_to_pks_nom_6_res')
				,('unit_tests', 'build_if_has_to_roles_err_1')
				,('unit_tests', 'build_if_has_to_roles_err_1_res')
				,('unit_tests', 'build_if_has_to_roles_err_2')
				,('unit_tests', 'build_if_has_to_roles_err_2_res')
				,('unit_tests', 'build_if_has_to_roles_nom_1')
				,('unit_tests', 'build_if_has_to_roles_nom_1_res')
				,('unit_tests', 'build_if_has_to_roles_nom_2')
				,('unit_tests', 'build_if_has_to_roles_nom_2_res')
				,('unit_tests', 'build_if_has_to_roles_nom_3')
				,('unit_tests', 'build_if_has_to_roles_nom_3_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_1')
				,('unit_tests', 'build_if_has_to_sqs_nom_1_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_2')
				,('unit_tests', 'build_if_has_to_sqs_nom_2_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_3')
				,('unit_tests', 'build_if_has_to_sqs_nom_3_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_4')
				,('unit_tests', 'build_if_has_to_sqs_nom_4_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_5')
				,('unit_tests', 'build_if_has_to_sqs_nom_5_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_6_res')
				,('unit_tests', 'build_if_has_to_sqs_nom_6')
				,('unit_tests', 'build_if_has_to_sqs_nom_7')
				,('unit_tests', 'build_if_has_to_sqs_nom_7_res')
				,('unit_tests', 'build_if_has_to_tables_nom_1')
				,('unit_tests', 'build_if_has_to_tables_nom_1_res')
				,('unit_tests', 'build_if_has_to_tables_nom_2')
				,('unit_tests', 'build_if_has_to_tables_nom_2_res')
				,('unit_tests', 'check_column_presence_err_1')
				,('unit_tests', 'check_column_presence_nom_1')
				,('unit_tests', 'check_data_purge_retentioninterval_err_1')
				,('unit_tests', 'check_data_purge_retentioninterval_nom_1')
				,('unit_tests', 'check_table_presence_err_1')
				,('unit_tests', 'check_table_presence_nom_1')
				,('unit_tests', 'clean_all_clients')
				,('unit_tests', 'constraint_naming_control_err_1')
				,('unit_tests', 'constraint_naming_control_err_1_res')
				,('unit_tests', 'constraint_naming_control_err_2')
				,('unit_tests', 'constraint_naming_control_err_2_res')
				,('unit_tests', 'constraint_naming_control_nom_1')
				,('unit_tests', 'constraint_naming_control_nom_1_res')
				,('unit_tests', 'constraint_naming_control_nom_2')
				,('unit_tests', 'constraint_naming_control_nom_2_res')
				,('unit_tests', 'constraint_naming_control_nom_3')
				,('unit_tests', 'constraint_naming_control_nom_3_res')
				,('unit_tests', 'constraint_naming_control_nom_4')
				,('unit_tests', 'constraint_naming_control_nom_4_res')
				,('unit_tests', 'create_new_client_err_1')
				,('unit_tests', 'create_new_client_nom_1')
				,('unit_tests', 'create_new_client_nom_1_res')
				,('unit_tests', 'data_purge_err_1')
				,('unit_tests', 'data_purge_err_2')
				,('unit_tests', 'data_purge_err_3')
				,('unit_tests', 'data_purge_err_4')
				,('unit_tests', 'data_purge_err_5')
				,('unit_tests', 'data_purge_nom_1')
				,('unit_tests', 'data_purge_nom_1_res')
				,('unit_tests', 'data_purge_nom_2')
				,('unit_tests', 'data_purge_nom_2_res')
				,('unit_tests', 'deblog')
				,('unit_tests', 'deblog_nom_1')
				,('unit_tests', 'deblog_nom_1_res')
				,('unit_tests', 'delete_indexes_on_cascade_nom_1')
				,('unit_tests', 'delete_indexes_on_cascade_nom_1_res')
				,('unit_tests', 'delete_indexes_on_cascade_nom_2')
				,('unit_tests', 'delete_indexes_on_cascade_nom_2_res')
				,('unit_tests', 'delete_indexes_on_cascade_nom_3')
				,('unit_tests', 'delete_indexes_on_cascade_nom_3_res')
				,('unit_tests', 'drop_cascade_pks_nom_1')
				,('unit_tests', 'drop_cascade_pks_nom_1_res')
				,('unit_tests', 'drop_cascade_pks_nom_2')
				,('unit_tests', 'drop_cascade_pks_nom_2_res')
				,('unit_tests', 'drop_cascade_pks_nom_3')
				,('unit_tests', 'drop_cascade_pks_nom_3_res')
				,('unit_tests', 'drop_cascade_pks_nom_4')
				,('unit_tests', 'drop_cascade_pks_nom_4_res')
				,('unit_tests', 'drop_cascade_roles_nom_1')
				,('unit_tests', 'drop_cascade_roles_nom_1_res')
				,('unit_tests', 'drop_client_err_1')
				,('unit_tests', 'drop_client_err_1_res')
				,('unit_tests', 'drop_client_nom_1')
				,('unit_tests', 'drop_client_nom_1_res')
				,('unit_tests', 'init_between_tests')
				,('unit_tests', 'sys_index_diag_nom_1')
				,('unit_tests', 'sys_index_diag_nom_1_res')
				,('unit_tests', 'sys_index_diag_nom_2')
				,('unit_tests', 'sys_index_diag_nom_2_res')
				,('unit_tests', 'sys_vacuum_diag_nom_1')
				,('unit_tests', 'sys_vacuum_diag_nom_1_res')
				,('unit_tests', 'presencer')
			) as t (schema_name, routine_name)
	)
	, cte_table_list as
	(
		select *
		from 
			(values
				('unit_tests', 'test_category')
				,('unit_tests', 'test_part')
				,('unit_tests', 'test')
				,('unit_tests', 'detail_report_table')
				,('common', 'purge_tool_conf')
				,('common', 'vacuum_script_results')
				,('common', 'debugger')
				,('common', 'index_script_results')
				,('common', 'dwh_dm_client')
				,('unit_tests', 'presence_table')
			) as t(schema_name, table_name)
	)
	, cte_evt_trg_list as
	(
		select *
		from 
			(values
				('ddl_trigger_create_table')
				,('ddl_trigger_create_idx')
				,('ddl_trigger_drop_table')
				,('ddl_trigger_drop_idx')
				,('ddl_trigger_alter_table')
			) as t(event_trigger_name)
	)
	insert into unit_tests.presence_table
	select 
		r.specific_schema as schema
		, r.routine_name as name
		, 'FUNCTION OR PROCEDURE' as type
		, 'Cet élément est en base mais n''est pas référencé comme testé.' as comment
	from information_schema."routines" r
	where 
		(
			specific_schema = 'common'
			or specific_schema = 'master'
			or specific_schema = 'unit_tests'
		)
		and (r.specific_schema, r.routine_name)
			not in (
				select cte.schema_name, cte.routine_name
				from cte_func_list cte)
	union	
	select 
		table_schema as schema
		, table_name as name
		, 'TABLE' as type
		, 'Cet élément est en base mais n''est pas référencé comme testé.' as comment
	from information_schema."tables"
	where 
		(
			table_schema = 'common'
			or table_schema = 'unit_tests'
		)
		and (table_schema, table_name)
			not in (
			select cte.schema_name, cte.table_name
			from cte_table_list cte)
	union
	select 
		'NA' as schema
		, evtname as name
		, 'EVENT TRIGGER' as type
		, 'Cet élément est en base mais n''est pas référencé comme testé.' as comment
	from pg_catalog.pg_event_trigger
	where evtname not in (
		select cte.event_trigger_name
		from cte_evt_trg_list cte);
		
	-- Renvoyer le résultat
	RETURN (SELECT count(*) FROM unit_tests.presence_table);
END;
$function$;