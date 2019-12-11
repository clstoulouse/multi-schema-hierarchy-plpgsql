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