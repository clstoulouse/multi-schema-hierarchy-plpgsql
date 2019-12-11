insert into unit_tests.test_category (id, category_name) values (1, 'nominal'), (2, 'exception');
insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	1
	, 'build_if_has_to_fks'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	2
	, 'build_if_has_to_idxs'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	3
	, 'build_if_has_to_pks'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	4
	, 'build_if_has_to_roles'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	5
	, 'build_if_has_to_sqs'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	6
	, 'build_if_has_to_tables'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	7
	, 'check_column_presence'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	8
	, 'check_data_purge_retentioninterval'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	9
	, 'check_table_presence'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	10
	, 'constraint_naming_control'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	11
	, 'create_new_client'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	12
	, 'data_purge'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	13
	, 'deblog'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	14
	, 'delete_indexes_on_cascade'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	15
	, 'drop_cascade_pks'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	16
	, 'drop_cascade_roles'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	17
	, 'drop_client'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	18
	, 'sys_index_diag'
);

insert into unit_tests.test
(
	id
	, tested_function_name
)
values
(
	19
	, 'sys_vacuum_diag'
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	1
	, 'build_if_has_to_fks_nom_1'
	, 1
	, 1
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	2
	, 'build_if_has_to_fks_nom_1_res'
	, 1
	, 1
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	3
	, 'build_if_has_to_fks_nom_2'
	, 1
	, 1
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	4
	, 'build_if_has_to_fks_nom_2_res'
	, 1
	, 1
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	5
	, 'build_if_has_to_fks_nom_3'
	, 1
	, 1
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	6
	, 'build_if_has_to_fks_nom_3_res'
	, 1
	, 1
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	7
	, 'build_if_has_to_fks_err_1'
	, 2
	, 1
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	8
	, 'build_if_has_to_fks_err_1_res'
	, 2
	, 1
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	9
	, 'build_if_has_to_idxs_nom_1'
	, 1
	, 2
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	10
	, 'build_if_has_to_idxs_nom_1_res'
	, 1
	, 2
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	11
	, 'build_if_has_to_idxs_nom_2'
	, 1
	, 2
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	12
	, 'build_if_has_to_idxs_nom_2_res'
	, 1
	, 2
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	13
	, 'build_if_has_to_idxs_nom_3'
	, 1
	, 2
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	14
	, 'build_if_has_to_idxs_nom_3_res'
	, 1
	, 2
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	15
	, 'build_if_has_to_idxs_err_1'
	, 2
	, 2
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	16
	, 'build_if_has_to_idxs_err_1_res'
	, 2
	, 2
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	17
	, 'build_if_has_to_pks_nom_1'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	18
	, 'build_if_has_to_pks_nom_1_res'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	19
	, 'build_if_has_to_pks_nom_2'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	20
	, 'build_if_has_to_pks_nom_2_res'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	21
	, 'build_if_has_to_pks_nom_3'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	22
	, 'build_if_has_to_pks_nom_3_res'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	23
	, 'build_if_has_to_pks_nom_4'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	24
	, 'build_if_has_to_pks_nom_4_res'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	25
	, 'build_if_has_to_pks_nom_5'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	26
	, 'build_if_has_to_pks_nom_5_res'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	27
	, 'build_if_has_to_pks_nom_6'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	28
	, 'build_if_has_to_pks_nom_6_res'
	, 1
	, 3
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	29
	, 'build_if_has_to_roles_nom_1'
	, 1
	, 4
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	30
	, 'build_if_has_to_roles_nom_1_res'
	, 1
	, 4
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	31
	, 'build_if_has_to_roles_nom_2'
	, 1
	, 4
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	32
	, 'build_if_has_to_roles_nom_2_res'
	, 1
	, 4
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	33
	, 'build_if_has_to_roles_nom_3'
	, 1
	, 4
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	34
	, 'build_if_has_to_roles_nom_3_res'
	, 1
	, 4
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	35
	, 'build_if_has_to_roles_err_1'
	, 2
	, 4
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	36
	, 'build_if_has_to_roles_err_1_res'
	, 2
	, 4
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	37
	, 'build_if_has_to_roles_err_2'
	, 2
	, 4
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	38
	, 'build_if_has_to_roles_err_2_res'
	, 2
	, 4
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	39
	, 'build_if_has_to_sqs_nom_1'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	40
	, 'build_if_has_to_sqs_nom_1_res'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	41
	, 'build_if_has_to_sqs_nom_2'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	42
	, 'build_if_has_to_sqs_nom_2_res'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	43
	, 'build_if_has_to_sqs_nom_3'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	44
	, 'build_if_has_to_sqs_nom_3_res'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	45
	, 'build_if_has_to_sqs_nom_4'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	46
	, 'build_if_has_to_sqs_nom_4_res'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	47
	, 'build_if_has_to_sqs_nom_5'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	48
	, 'build_if_has_to_sqs_nom_5_res'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	49
	, 'build_if_has_to_sqs_nom_6'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	50
	, 'build_if_has_to_sqs_nom_6_res'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	51
	, 'build_if_has_to_sqs_nom_7'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	52
	, 'build_if_has_to_sqs_nom_7_res'
	, 1
	, 5
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	53
	, 'build_if_has_to_tables_nom_1'
	, 1
	, 6
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	54
	, 'build_if_has_to_tables_nom_1_res'
	, 1
	, 6
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	55
	, 'build_if_has_to_tables_nom_2'
	, 1
	, 6
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	56
	, 'build_if_has_to_tables_nom_2_res'
	, 1
	, 6
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	57
	, 'check_column_presence_err_1'
	, 2
	, 7
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	58
	, 'check_column_presence_nom_1'
	, 1
	, 7
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	59
	, 'check_data_purge_retentioninterval_err_1'
	, 2
	, 8
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	60
	, 'check_data_purge_retentioninterval_nom_1'
	, 1
	, 8
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	61
	, 'check_table_presence_err_1'
	, 2
	, 9
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	62
	, 'check_table_presence_nom_1'
	, 1
	, 9
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	63
	, 'constraint_naming_control_nom_1'
	, 1
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	64
	, 'constraint_naming_control_nom_1_res'
	, 1
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	65
	, 'constraint_naming_control_nom_2'
	, 1
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	66
	, 'constraint_naming_control_nom_2_res'
	, 1
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	67
	, 'constraint_naming_control_nom_3'
	, 1
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	68
	, 'constraint_naming_control_nom_3_res'
	, 1
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	69
	, 'constraint_naming_control_nom_4'
	, 1
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	70
	, 'constraint_naming_control_nom_4_res'
	, 1
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	71
	, 'constraint_naming_control_err_1'
	, 2
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	72
	, 'constraint_naming_control_err_1_res'
	, 2
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	73
	, 'constraint_naming_control_err_2'
	, 2
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	74
	, 'constraint_naming_control_err_2_res'
	, 2
	, 10
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	75
	, 'create_new_client_nom_1'
	, 1
	, 11
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	76
	, 'create_new_client_nom_1_res'
	, 1
	, 11
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	77
	, 'create_new_client_err_1'
	, 2
	, 11
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	78
	, 'data_purge_err_1'
	, 2
	, 12
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	79
	, 'data_purge_err_2'
	, 2
	, 12
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	80
	, 'data_purge_err_3'
	, 2
	, 12
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	81
	, 'data_purge_err_4'
	, 2
	, 12
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	82
	, 'data_purge_err_5'
	, 2
	, 12
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	83
	, 'data_purge_nom_1'
	, 1
	, 12
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	84
	, 'data_purge_nom_1_res'
	, 1
	, 12
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	85
	, 'deblog_nom_1'
	, 1
	, 13
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	86
	, 'deblog_nom_1_res'
	, 1
	, 13
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	87
	, 'delete_indexes_on_cascade_nom_1'
	, 1
	, 14
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	88
	, 'delete_indexes_on_cascade_nom_1_res'
	, 1
	, 14
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	89
	, 'delete_indexes_on_cascade_nom_2'
	, 1
	, 14
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	90
	, 'delete_indexes_on_cascade_nom_2_res'
	, 1
	, 14
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	91
	, 'delete_indexes_on_cascade_nom_3'
	, 1
	, 14
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	92
	, 'delete_indexes_on_cascade_nom_3_res'
	, 1
	, 14
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	93
	, 'drop_cascade_pks_nom_1'
	, 1
	, 15
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	94
	, 'drop_cascade_pks_nom_1_res'
	, 1
	, 15
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	95
	, 'drop_cascade_pks_nom_2'
	, 1
	, 15
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	96
	, 'drop_cascade_pks_nom_2_res'
	, 1
	, 15
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	97
	, 'drop_cascade_pks_nom_3'
	, 1
	, 15
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	98
	, 'drop_cascade_pks_nom_3_res'
	, 1
	, 15
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	99
	, 'drop_cascade_pks_nom_4'
	, 1
	, 15
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	100
	, 'drop_cascade_pks_nom_4_res'
	, 1
	, 15
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	101
	, 'drop_cascade_roles_nom_1'
	, 1
	, 16
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	102
	, 'drop_cascade_roles_nom_1_res'
	, 1
	, 16
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	103
	, 'drop_client_nom_1'
	, 1
	, 17
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	104
	, 'drop_client_nom_1_res'
	, 1
	, 17
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	105
	, 'drop_client_err_1'
	, 2
	, 17
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	106
	, 'drop_client_err_1_res'
	, 2
	, 17
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	107
	, 'sys_index_diag_nom_1'
	, 1
	, 18
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	108
	, 'sys_index_diag_nom_1_res'
	, 1
	, 18
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	109
	, 'sys_index_diag_nom_2'
	, 1
	, 18
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	110
	, 'sys_index_diag_nom_2_res'
	, 1
	, 18
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	111
	, 'sys_vacuum_diag_nom_1'
	, 1
	, 19
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	112
	, 'sys_vacuum_diag_nom_1_res'
	, 1
	, 19
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	113
	, 'sys_vacuum_diag_nom_2'
	, 1
	, 19
);

insert into unit_tests.test_part
(	
	id
	, testing_method_name
	, category_id
	, test_id
)
values
(
	114
	, 'sys_vacuum_diag_nom_2_res'
	, 1
	, 19
);