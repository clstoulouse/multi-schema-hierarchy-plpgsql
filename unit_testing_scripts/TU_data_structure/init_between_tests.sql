create or replace procedure unit_tests.init_between_tests()
 LANGUAGE plpgsql
AS $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est d'initialiser le master dans le cadre des tests unitaires
--
-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			05/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
BEGIN
	CALL unit_tests.clean_all_clients();
	TRUNCATE TABLE common.dwh_dm_client RESTART IDENTITY;
	DROP SCHEMA master CASCADE;
	CREATE SCHEMA master;
	
	CREATE OR REPLACE FUNCTION master.ddl_trigger_create_table_fct()
	  RETURNS event_trigger
	 LANGUAGE plpgsql
	  AS $$
	DECLARE
		all_variables character varying;
		r RECORD;
		schema_name varchar (250);
		command_tag varchar (100);
	BEGIN
		FOR r IN SELECT * FROM pg_event_trigger_ddl_commands() LOOP
			if r.schema_name = 'master' and r.command_tag = 'CREATE TABLE'
			then
				schema_name := r.schema_name;
				command_tag := r.command_tag;
				RAISE NOTICE 'caught % event on %', r.command_tag, r.object_identity;
				all_variables := concat(
					'classid: ', r.classid, chr(10)
					, 'objid: ', r.objid, chr(10)
					, 'objsubid: ', r.objsubid, chr(10)
					, 'command_tag: ', r.command_tag, chr(10)
					, 'object_type: ', r.object_type, chr(10)
					, 'schema_name: ', r.schema_name, chr(10)
					, 'object_identity: ', r.object_identity, chr(10)
					, 'in_extension: ', r.in_extension);
				
				RAISE NOTICE '%', all_variables;
			end if;
		END LOOP;
		
		RAISE NOTICE 'schema : %', schema_name;
		RAISE NOTICE 'command_tag : %', command_tag;
		
		if schema_name = 'master' and command_tag = 'CREATE TABLE'
		then
			RAISE NOTICE 'launch procedures trigger CREATE';
			call common.build_if_has_to_tables();	
			call common.constraint_naming_control_first();	
			call common.build_if_has_to_sqs();
			call common.build_if_has_to_pks();
			call common.build_if_has_to_fks();
		end if;
	END;
	$$;

	CREATE EVENT TRIGGER ddl_trigger_create_table ON ddl_command_end WHEN TAG IN ('CREATE TABLE')
	   EXECUTE FUNCTION master.ddl_trigger_create_table_fct();

	CREATE OR REPLACE FUNCTION master.ddl_trigger_create_idx_fct()
	  RETURNS event_trigger
	 LANGUAGE plpgsql
	  AS $$
	DECLARE
		all_variables character varying;
		r RECORD;
		schema_name varchar (250);
		command_tag varchar (100);
	BEGIN
		FOR r IN SELECT * FROM pg_event_trigger_ddl_commands() LOOP
			if r.schema_name = 'master' and r.command_tag = 'CREATE INDEX'
			then
				schema_name := r.schema_name;
				command_tag := r.command_tag;
				RAISE NOTICE 'caught % event on %', r.command_tag, r.object_identity;
				all_variables := concat(
					'classid: ', r.classid, chr(10)
					, 'objid: ', r.objid, chr(10)
					, 'objsubid: ', r.objsubid, chr(10)
					, 'command_tag: ', r.command_tag, chr(10)
					, 'object_type: ', r.object_type, chr(10)
					, 'schema_name: ', r.schema_name, chr(10)
					, 'object_identity: ', r.object_identity, chr(10)
					, 'in_extension: ', r.in_extension);
				
				RAISE NOTICE '%', all_variables;
			end if;
		END LOOP;
		
		RAISE NOTICE 'schema : %', schema_name;
		RAISE NOTICE 'command_tag : %', command_tag;
		
		if schema_name = 'master' and command_tag = 'CREATE INDEX'
		then
			RAISE NOTICE 'launch procedures trigger CREATE INDEX';
			call common.index_naming_control_first();
			call common.build_if_has_to_idxs();	
		end if;
	END;
	$$;

	CREATE EVENT TRIGGER ddl_trigger_create_idx ON ddl_command_end WHEN TAG IN ('CREATE INDEX')
	   EXECUTE FUNCTION master.ddl_trigger_create_idx_fct();

	CREATE OR REPLACE FUNCTION master.ddl_trigger_drop_table_fct()
	  RETURNS event_trigger
	 LANGUAGE plpgsql
	  AS $$
	DECLARE
		all_variables character varying;
		r RECORD;
		schema_name varchar (250);
		object_type varchar (100);
	BEGIN
		FOR r IN SELECT * FROM pg_event_trigger_dropped_objects () LOOP
			if r.schema_name = 'master' and r.object_type = 'table'
			then
				schema_name := r.schema_name;
				object_type := r.object_type;
				all_variables := concat(
					'classid: ', r.classid, chr(10)
					, 'objid: ', r.objid, chr(10)
					, 'objsubid: ', r.objsubid, chr(10)
					, 'original: ', r.original, chr(10)
					, 'normal: ', r.normal, chr(10)
					, 'is_temporary: ', r.is_temporary, chr(10)
					, 'object_type: ', r.object_type, chr(10)
					, 'schema_name: ', r.schema_name, chr(10)
					, 'object_name: ', r.object_name, chr(10)
					, 'object_identity: ', r.object_identity, chr(10)
					, 'address_names: ', r.schema_name, chr(10)
					, 'address_args: ', r.address_args);
				
				RAISE NOTICE '%', all_variables;
			end if;
		END LOOP;
		
		RAISE NOTICE 'schema : %', schema_name;
		RAISE NOTICE 'object_type : %', object_type;
		
		if schema_name = 'master' and object_type = 'table'
		then
			RAISE NOTICE 'launch procedures DROP TABLE';
			call common.build_if_has_to_sqs();
		end if;
	END;
	$$;

	CREATE EVENT TRIGGER ddl_trigger_drop_table ON sql_drop WHEN TAG IN ('DROP TABLE')
	   EXECUTE FUNCTION master.ddl_trigger_drop_table_fct();

	CREATE OR REPLACE FUNCTION master.ddl_trigger_drop_idx_fct()
	  RETURNS event_trigger
	 LANGUAGE plpgsql
	  AS $$
	DECLARE
		all_variables character varying;
		r RECORD;
		schema_name varchar (250);
		object_type varchar (100);
	BEGIN
		FOR r IN SELECT * FROM pg_event_trigger_dropped_objects () LOOP
			if r.schema_name = 'master' and r.object_type = 'index'
			then
				schema_name := r.schema_name;
				object_type := r.object_type;
				all_variables := concat(
					'classid: ', r.classid, chr(10)
					, 'objid: ', r.objid, chr(10)
					, 'objsubid: ', r.objsubid, chr(10)
					, 'original: ', r.original, chr(10)
					, 'normal: ', r.normal, chr(10)
					, 'is_temporary: ', r.is_temporary, chr(10)
					, 'object_type: ', r.object_type, chr(10)
					, 'schema_name: ', r.schema_name, chr(10)
					, 'object_name: ', r.object_name, chr(10)
					, 'object_identity: ', r.object_identity, chr(10)
					, 'address_names: ', r.schema_name, chr(10)
					, 'address_args: ', r.address_args);
				
				RAISE NOTICE '%', all_variables;
			end if;
		END LOOP;
		
		RAISE NOTICE 'schema : %', schema_name;
		RAISE NOTICE 'object_type : %', object_type;
		
		if schema_name = 'master' and object_type = 'index'
		then
			RAISE NOTICE 'launch procedures DROP INDEX';
			call common.delete_indexes_on_cascade();
		end if;
	END;
	$$;

	CREATE EVENT TRIGGER ddl_trigger_drop_idx ON sql_drop WHEN TAG IN ('DROP INDEX')
	   EXECUTE FUNCTION master.ddl_trigger_drop_idx_fct();

	CREATE OR REPLACE FUNCTION master.ddl_trigger_alter_table_fct()
	  RETURNS event_trigger
	 LANGUAGE plpgsql
	  AS $$
	DECLARE
		all_variables character varying;
		r RECORD;
		schema_name varchar (250);
		command_tag varchar (100);
		object_type varchar (250);
		constraint_naming_limiter int := 0;
	BEGIN
		FOR r IN SELECT * FROM pg_event_trigger_ddl_commands() LOOP
			if r.schema_name = 'master' and r.command_tag = 'ALTER TABLE'
			then
				schema_name := r.schema_name;
				command_tag := r.command_tag;
				object_type := r.object_type;
				RAISE NOTICE 'caught % event on %', r.command_tag, r.object_identity;
				all_variables := concat(
					'classid: ', r.classid, chr(10)
					, 'objid: ', r.objid, chr(10)
					, 'objsubid: ', r.objsubid, chr(10)
					, 'command_tag: ', r.command_tag, chr(10)
					, 'object_type: ', r.object_type, chr(10)
					, 'schema_name: ', r.schema_name, chr(10)
					, 'object_identity: ', r.object_identity, chr(10)
					, 'in_extension: ', r.in_extension);
				
				RAISE NOTICE '%', all_variables;
			end if;
		END LOOP;
		
		if schema_name = 'master' and command_tag = 'ALTER TABLE' and object_type <> 'index' 
		then	
			RAISE NOTICE 'launch procedures ALTER TABLE';
			RAISE NOTICE 'schema : %', schema_name;
			RAISE NOTICE 'command_tag : %', command_tag;
			RAISE NOTICE 'object_type : %', object_type;
			
			select common.constraint_naming_control_limiter()::int into constraint_naming_limiter;
			
			if
				constraint_naming_limiter > 0
			then
				-- Cet appel est récurcif. La modification de nom de la contrainte déclenche le trigger ALTER TABLE
				raise notice 'nombre de nommage à faire : %', (select common.constraint_naming_control_limiter());
				raise notice 'procédure de nommage unitaire';
				call common.constraint_naming_control_first();
			else
				raise notice 'nombre de nommage à faire : %', (select common.constraint_naming_control_limiter());
				CALL common.deblog('ddl_trigger_alter_table_fct', 'entrée dans le trigger', cast(0 as bit));
				call common.build_if_has_to_pks();
				call common.build_if_has_to_fks();
				call common.build_if_has_to_roles();
				call common.build_if_has_to_sqs();
				call common.drop_cascade_roles();
				call common.drop_cascade_fks();
				call common.drop_cascade_pks();
			end if;
		end if;
	END;
	$$;

	CREATE EVENT TRIGGER ddl_trigger_alter_table ON ddl_command_end WHEN TAG IN ('ALTER TABLE')
	   EXECUTE FUNCTION master.ddl_trigger_alter_table_fct();
	   
	CREATE OR REPLACE FUNCTION master.ddl_trigger_alter_idx_fct()
	  RETURNS event_trigger
	 LANGUAGE plpgsql
	  AS $$
	DECLARE
		all_variables character varying;
		r RECORD;
		schema_name varchar (250);
		object_type varchar (250);
		command_tag varchar (100);
		index_naming_limiter int := 0;
	BEGIN
		FOR r IN SELECT * FROM pg_event_trigger_ddl_commands() LOOP
			if r.schema_name = 'master' and r.command_tag = 'ALTER INDEX'
			then
				schema_name := r.schema_name;
				command_tag := r.command_tag;
				object_type := r.object_type;
				RAISE NOTICE 'caught % event on %', r.command_tag, r.object_identity;
				all_variables := concat(
					'classid: ', r.classid, chr(10)
					, 'objid: ', r.objid, chr(10)
					, 'objsubid: ', r.objsubid, chr(10)
					, 'command_tag: ', r.command_tag, chr(10)
					, 'object_type: ', r.object_type, chr(10)
					, 'schema_name: ', r.schema_name, chr(10)
					, 'object_identity: ', r.object_identity, chr(10)
					, 'in_extension: ', r.in_extension);
				
				RAISE NOTICE '%', all_variables;
			end if;
		END LOOP;
		
		
		if schema_name = 'master' and command_tag = 'ALTER INDEX' and object_type = 'index'
		then
			RAISE NOTICE 'launch procedures trigger ALTER INDEX';
			RAISE NOTICE 'schema : %', schema_name;
			RAISE NOTICE 'command_tag : %', command_tag;
			
			select common.index_naming_control_limiter()::int into index_naming_limiter;
			
			if index_naming_limiter > 0
			then
				-- Cet appel est récurcif. La modification de nom de la contrainte déclenche le trigger ALTER TABLE
				raise notice 'ITER : nombre de nommage à faire : %', (select common.index_naming_control_limiter());
				raise notice 'procédure de nommage unitaire';
				call common.index_naming_control_first();
			else
				raise notice 'nombre de nommage à faire : %', (select common.constraint_naming_control_limiter());
				CALL common.deblog('ddl_trigger_alter_table_fct', 'entrée dans le trigger', cast(0 as bit));			
				call common.build_if_has_to_idxs();	
			end if;
		end if;
	END;
	$$;

	CREATE EVENT TRIGGER ddl_trigger_alter_idx ON ddl_command_end WHEN TAG IN ('ALTER INDEX')
	   EXECUTE FUNCTION master.ddl_trigger_alter_idx_fct();
	   
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

	
	CALL common.deblog(CAST('init_between_tests' as varchar), CAST('nicely done' as text), cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			ROLLBACK;
			CALL common.deblog(CAST('init_between_tests' as varchar), CAST(SQLERRM as text), cast(0 as bit));			
END;
$procedure$;