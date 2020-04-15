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
	
	EXCEPTION
		WHEN others THEN
			raise '%', sqlerrm;
			ROLLBACK;
END;
$$;

CREATE EVENT TRIGGER ddl_trigger_drop_idx ON sql_drop WHEN TAG IN ('DROP INDEX')
   EXECUTE FUNCTION master.ddl_trigger_drop_idx_fct();