create or replace procedure common.delete_indexes_on_cascade()
language plpgsql
as $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de propager la suppression des index du schéma 'master' vers ceux des clients
-- Origines : PostgreSQL v11 | 15/02/2019
-- Limitation : Ne supprime pas les indexes sur les clés primaires
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/02/2019		Création
--  JPI			04/04/2019		Ajout de la discrimination du schéma de test unitaire
--
---------------------------------------------------------------------------------------------------------------
declare 
	query character varying;
begin
	with cte_master_indexes as
	(
		-- Lister tous les index présent sur le schéma master (n'étant pas des indexs portant sur des clés primaires)
		SELECT
			i.relname as idx_name
			, t.relname as table_name
		FROM pg_index AS idx
			INNER JOIN pg_class AS i
				ON i.oid = idx.indexrelid
			INNER JOIN pg_namespace AS ns
				ON ns.oid = i.relnamespace
			INNER JOIN pg_class AS t
				ON t.oid = idx.indrelid
				AND t.relkind = 'r'
		WHERE ns.nspname = 'master'
			AND t.relname IN 
			(
				SELECT table_name
				FROM information_schema.tables
				WHERE table_schema = 'master'
			)
			AND idx.indisprimary = false
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
	, cte_all_client_indexes as
	(
		-- Tous les indexes déjà présents des clients
		select 
			i.relname as idx_name
			, t.relname as table_name
			, ns.nspname as schema_name
		FROM pg_index AS idx
			INNER JOIN pg_class AS i
				ON i.oid = idx.indexrelid
			INNER JOIN pg_namespace AS ns
				ON ns.oid = i.relnamespace
			INNER JOIN pg_class AS t
				ON t.oid = idx.indrelid
				AND t.relkind = 'r'
		WHERE exists (select 1 from cte_all_client_list where schema_name = ns.nspname)			
			AND idx.indisprimary = false
	)
	-- On agrège les commande de destruction nécessaire des indexes.
	select string_agg('DROP INDEX '||c.schema_name||'.'||c.idx_name||';', chr(10)) into query
	from cte_all_client_indexes c
	where not exists (select 1 from cte_master_indexes m where m.table_name = c.table_name and c.idx_name like m.idx_name||'%');
	
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('delete_indexes_on_cascade' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('delete_indexes_on_cascade' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			raise '%', chr(10)||'error in ''common.delete_indexes_on_cascade'' consequently to : '||sqlerrm;
end;
$$