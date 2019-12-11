create or replace procedure common.drop_cascade_fks ()
 language plpgsql
as $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de propager la destruction des clé étrangères.
-- Origines : PostgreSQL v11 | 15/02/2019
-- Limitation :
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/02/2019		Création
--  JPI			04/04/2019		Ajout de la discrimination du schéma de test unitaire
--
---------------------------------------------------------------------------------------------------------------
declare
	query character varying;
begin
	with cte_master_fks as
	(
		-- Trouver toutes les clés étrangères étant dans le schéma master
		SELECT
			rel.relname as table_name
			, ccu.table_name as ref_table_name
			, pg_get_constraintdef(con.oid) as con_def						
			, con.conname as cons_name
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN information_schema.constraint_column_usage AS ccu
			  ON ccu.constraint_name = con.conname
			  AND ccu.table_schema = nsp.nspname
		WHERE nsp.nspname = 'master'
			and con.contype = 'f'
			AND rel.relname IN 
			(
				SELECT table_name
				FROM information_schema.tables
				WHERE table_schema = 'master'
			)
		GROUP BY con.contype, nsp.nspname, rel.relname, ccu.table_name, con.oid, con.conname
	)
	, cte_all_client_list as
	(
		-- Tous les clients
		select schema_name
		from information_schema.schemata
		where schema_name <> 'information_schema' 
			and schema_name <> 'common'
			and schema_name <> 'pg_catalog'
			and schema_name <> 'master'
			and schema_name <> 'unit_tests'
			and schema_name not like 'pg_toast%'
			and schema_name not like 'pg_temp%'
	)
	, cte_all_client_fks as
	(
		-- Lister toutes les contraintes de clé étrangère des clients
		SELECT
			rel.relname as table_name
			, ccu.table_name as ref_table_name
			, pg_get_constraintdef(con.oid) as con_def
			, nsp.nspname as schema_name
			, con.conname as cons_name
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN information_schema.constraint_column_usage AS ccu
			  ON ccu.constraint_name = con.conname
			  AND ccu.table_schema = nsp.nspname
		WHERE con.contype = 'f'			
			and exists (select 1 from cte_all_client_list where schema_name = nsp.nspname)
		GROUP BY con.contype, nsp.nspname, rel.relname, ccu.table_name, con.oid, con.conname
	)
	select 
		-- Agrégation de toutes les commandes de destruction nécessaire des clés étrangères.
		string_agg('ALTER TABLE '||c.schema_name||'.'||c.table_name||' DROP CONSTRAINT '||c.cons_name||';', chr(10)) into query
	from cte_all_client_fks c
	where 
		not exists 
		(
			select 1
			from cte_master_fks cf
			where cf.con_def = replace(c.con_def, c.schema_name, 'master')
				and c.table_name = cf.table_name
		);
	
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('drop_cascade_fks' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('drop_cascade_fks' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			ROLLBACK;
end;
$$