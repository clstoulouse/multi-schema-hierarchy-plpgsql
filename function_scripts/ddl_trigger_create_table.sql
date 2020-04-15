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
			if substring(r.object_identity, 8) like '%.%'
				or substring(r.object_identity, 8) like '%master%'
				then raise exception 'Do not use ''.'' character or ''master'' string in the table name.';
			end if;
			
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
		call common.shielder();
		
		RAISE NOTICE 'launch procedures trigger CREATE';
		call common.build_if_has_to_tables();	
		call common.constraint_naming_control_first();	
		call common.build_if_has_to_sqs();
		call common.build_if_has_to_pks();
		call common.build_if_has_to_fks();
	end if;
	
	EXCEPTION
		WHEN others THEN
			raise '%', sqlerrm;
			ROLLBACK;
END;
$$;

CREATE EVENT TRIGGER ddl_trigger_create_table ON ddl_command_end WHEN TAG IN ('CREATE TABLE')
   EXECUTE FUNCTION master.ddl_trigger_create_table_fct();