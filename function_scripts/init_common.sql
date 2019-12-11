CREATE TABLE IF NOT EXISTS common.dwh_dm_client (
		client_id serial NOT NULL,
		client_waste_id int4 NULL,
		client_waste_nom varchar(50) NULL,
		client_waste_mdp varchar(50) NULL,
		client_novacom_id int4 NULL,
		client_novacom_nom varchar(50) NULL,
		super_client_novacom_id int4 NULL,
		super_client_novacom_nom varchar(50) NULL,
		application_novacom_id int4 NULL,
		CONSTRAINT pk_dwh_dm_client PRIMARY KEY (client_id)
	);

CREATE table if not EXISTS common.purge_tool_conf (
	table_name varchar(100) NULL,
	column_name varchar(200) NULL,
	retentioninterval varchar(20) NULL,
	CONSTRAINT purge_tool_conf_check CHECK (common.check_column_presence(table_name, column_name)),
	CONSTRAINT purge_tool_conf_retentioninterval_check CHECK (common.check_data_purge_retentioninterval(retentioninterval)),
	CONSTRAINT purge_tool_conf_table_name_check CHECK (common.check_table_presence(table_name))
);

CREATE TABLE if not exists common.vacuum_script_results (
	id serial NOT NULL,
	date_sys_vacuum_diag timestamp NULL,
	schema_name varchar NULL,
	table_name varchar NULL,
	analyze_status bool NULL,
	vacuum_status bool NULL,
	commentaries varchar NULL,
	CONSTRAINT vacuum_script_results_pkey PRIMARY KEY (id)
);

create sequence if not exists master.sq_master_pks_id;
create sequence if not exists master.sq_master_fks_id;
create sequence if not exists master.sq_master_idxs_id;
create sequence if not exists master.sq_master_idxus_id;
