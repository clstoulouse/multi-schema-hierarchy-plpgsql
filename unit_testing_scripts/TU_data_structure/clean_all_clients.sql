create or replace procedure unit_tests.clean_all_clients()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de vider la base de ses clients et des rôles attenants.
-- 
-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			04/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
declare
	query text;
begin
	if exists (select 1 from information_schema.tables where table_schema  = 'unit_tests')
	then
		select string_agg('CALL common.drop_client('''||schema_name||''');', chr(10)) into query
		from information_schema.schemata
		where schema_name <> 'information_schema' 
			and schema_name <> 'common'
			and schema_name <> 'pg_catalog'
			and schema_name <> 'master'
			and schema_name <> 'unit_tests'
			and schema_name not like 'pg_toast%'
			and schema_name not like 'pg_temp%';
		
		IF query IS NOT NULL 
		THEN 
			EXECUTE query; 
			CALL common.deblog(CAST('clean_all_clients' as varchar), CAST(query as text), cast(1 as bit));
		ELSE
			CALL common.deblog(CAST('clean_all_clients' as varchar), CAST('no client registered' as text), cast(1 as bit));
		END IF;		
	end if;
	
	
	EXCEPTION
		WHEN others THEN
			ROLLBACK;
			CALL common.deblog(CAST('clean_all_clients' as varchar), CAST(SQLERRM as text), cast(0 as bit));
end;
$procedure$;