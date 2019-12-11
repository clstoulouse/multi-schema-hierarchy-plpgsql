-- General test sequence
-- build_if_has_to_fks
truncate table common.debugger;
truncate table unit_tests.detail_report_table;
truncate table common.purge_tool_conf;
truncate table common.index_script_results;
truncate table common.index_script_results;
truncate table common.vacuum_script_results;
call unit_tests.init_between_tests();

call unit_tests.build_if_has_to_fks_nom_1();
call unit_tests.build_if_has_to_fks_nom_1_res();

call unit_tests.build_if_has_to_fks_nom_2();
call unit_tests.build_if_has_to_fks_nom_2_res();

call unit_tests.build_if_has_to_fks_nom_3();
call unit_tests.build_if_has_to_fks_nom_3_res();

call unit_tests.build_if_has_to_fks_err_1();
call unit_tests.build_if_has_to_fks_err_1_res();

-- build_if_has_to_idxs
call unit_tests.init_between_tests();

call unit_tests.build_if_has_to_idxs_nom_1();
call unit_tests.build_if_has_to_idxs_nom_1_res();

call unit_tests.build_if_has_to_idxs_nom_2();
call unit_tests.build_if_has_to_idxs_nom_2_res();

call unit_tests.build_if_has_to_idxs_nom_3();
call unit_tests.build_if_has_to_idxs_nom_3_res();

call unit_tests.build_if_has_to_idxs_err_1();
call unit_tests.build_if_has_to_idxs_err_1_res();

-- build_if_has_to_pks
call unit_tests.init_between_tests();

call unit_tests.build_if_has_to_pks_nom_1();
call unit_tests.build_if_has_to_pks_nom_1_res();

call unit_tests.build_if_has_to_pks_nom_2();
call unit_tests.build_if_has_to_pks_nom_2_res();

call unit_tests.build_if_has_to_pks_nom_3();
call unit_tests.build_if_has_to_pks_nom_3_res();

call unit_tests.build_if_has_to_pks_nom_4();
call unit_tests.build_if_has_to_pks_nom_4_res();

call unit_tests.build_if_has_to_pks_nom_5();
call unit_tests.build_if_has_to_pks_nom_5_res();

call unit_tests.build_if_has_to_pks_nom_6();
call unit_tests.build_if_has_to_pks_nom_6_res();


-- build_role_if_has_to
call unit_tests.init_between_tests();

call unit_tests.build_if_has_to_roles_nom_1();
call unit_tests.build_if_has_to_roles_nom_1_res();

call unit_tests.build_if_has_to_roles_nom_2();
call unit_tests.build_if_has_to_roles_nom_2_res();

call unit_tests.build_if_has_to_roles_nom_3();
call unit_tests.build_if_has_to_roles_nom_3_res();

call unit_tests.build_if_has_to_roles_err_1();
call unit_tests.build_if_has_to_roles_err_1_res();

call unit_tests.build_if_has_to_roles_err_2();
call unit_tests.build_if_has_to_roles_err_2_res();

-- build_if_has_to_sqs
call unit_tests.init_between_tests();

call unit_tests.build_if_has_to_sqs_nom_1();
call unit_tests.build_if_has_to_sqs_nom_1_res();

call unit_tests.build_if_has_to_sqs_nom_2();
call unit_tests.build_if_has_to_sqs_nom_2_res();

call unit_tests.build_if_has_to_sqs_nom_3();
call unit_tests.build_if_has_to_sqs_nom_3_res();

call unit_tests.build_if_has_to_sqs_nom_4();
call unit_tests.build_if_has_to_sqs_nom_4_res();

call unit_tests.build_if_has_to_sqs_nom_5();
call unit_tests.build_if_has_to_sqs_nom_5_res();

call unit_tests.build_if_has_to_sqs_nom_6();
call unit_tests.build_if_has_to_sqs_nom_6_res();

call unit_tests.build_if_has_to_sqs_nom_7();
call unit_tests.build_if_has_to_sqs_nom_7_res();

-- build_if_has_to_tables
call unit_tests.init_between_tests();

call unit_tests.build_if_has_to_tables_nom_1();
call unit_tests.build_if_has_to_tables_nom_1_res();

call unit_tests.build_if_has_to_tables_nom_2();
call unit_tests.build_if_has_to_tables_nom_2_res();

-- check_column_presence
call unit_tests.init_between_tests();

call unit_tests.check_column_presence_nom_1();
call unit_tests.check_column_presence_err_1();

-- check_data_purge_retentioninterval
call unit_tests.init_between_tests();

call unit_tests.check_data_purge_retentioninterval_nom_1();
call unit_tests.check_data_purge_retentioninterval_err_1();

-- check_table_presence
call unit_tests.init_between_tests();

call unit_tests.check_table_presence_nom_1();
call unit_tests.check_table_presence_err_1();

-- constraint_naming_control
call unit_tests.init_between_tests();

call unit_tests.constraint_naming_control_nom_1();
call unit_tests.constraint_naming_control_nom_1_res();

call unit_tests.constraint_naming_control_nom_2();
call unit_tests.constraint_naming_control_nom_2_res();

call unit_tests.constraint_naming_control_nom_3();
call unit_tests.constraint_naming_control_nom_3_res();

call unit_tests.constraint_naming_control_nom_4();
call unit_tests.constraint_naming_control_nom_4_res();

call unit_tests.constraint_naming_control_err_1();
call unit_tests.constraint_naming_control_err_1_res();

call unit_tests.constraint_naming_control_err_2();
call unit_tests.constraint_naming_control_err_2_res();

-- create_new_client
call unit_tests.init_between_tests();

call unit_tests.create_new_client_nom_1();
call unit_tests.create_new_client_nom_1_res();

call unit_tests.create_new_client_err_1();

-- data_purge
call unit_tests.init_between_tests();

call  unit_tests.data_purge_err_1();
call  unit_tests.data_purge_err_2();
call  unit_tests.data_purge_err_3();
call  unit_tests.data_purge_err_4();
call  unit_tests.data_purge_err_5();
call  unit_tests.data_purge_nom_1();
call  unit_tests.data_purge_nom_1_res();

-- deblog
call unit_tests.init_between_tests();

call unit_tests.deblog_nom_1();
call unit_tests.deblog_nom_1_res();

-- delete_indexes_on_cascade
call unit_tests.init_between_tests();

call unit_tests.delete_indexes_on_cascade_nom_1();
call unit_tests.delete_indexes_on_cascade_nom_1_res();

call unit_tests.delete_indexes_on_cascade_nom_2();
call unit_tests.delete_indexes_on_cascade_nom_2_res();

call unit_tests.delete_indexes_on_cascade_nom_3();
call unit_tests.delete_indexes_on_cascade_nom_3_res();

-- drop_cascade_pks
call unit_tests.init_between_tests();

call unit_tests.drop_cascade_pks_nom_1();
call unit_tests.drop_cascade_pks_nom_1_res();

call unit_tests.drop_cascade_pks_nom_2();
call unit_tests.drop_cascade_pks_nom_2_res();

call unit_tests.drop_cascade_pks_nom_3();
call unit_tests.drop_cascade_pks_nom_3_res();

call unit_tests.drop_cascade_pks_nom_4();
call unit_tests.drop_cascade_pks_nom_4_res();

-- drop_cascade_roles
call unit_tests.init_between_tests();

call unit_tests.drop_cascade_roles_nom_1();
call unit_tests.drop_cascade_roles_nom_1_res();

-- sys_index_diag
call unit_tests.init_between_tests();

call unit_tests.sys_index_diag_nom_1();
call unit_tests.sys_index_diag_nom_1_res();

call unit_tests.sys_index_diag_nom_2();
call unit_tests.sys_index_diag_nom_2_res();

-- sys_vacuum_diag -- A VERIFIER A LA MAIN CAR DOIT ÊTRE DANS DEUX TRANSACTIONS DISTINCTES
-- call unit_tests.init_between_tests();

-- call unit_tests.sys_vacuum_diag_nom_1();
-- call unit_tests.sys_vacuum_diag_nom_1_res();

-- synthesis
select *
from unit_tests.detail_report_table;