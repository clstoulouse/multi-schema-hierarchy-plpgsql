CREATE OR REPLACE FUNCTION common.sys_index_diag(in_schema_name varchar)
RETURNS TABLE
	(
		schemaname character varying
		, tablename character varying
		, indexname character varying
		, statusf character varying
	)
language plpgsql
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de rebâtir les index lorsque nécesaire (fragmentation des feuilles de plus de 30%)
-- Origines : PostgreSQL v11 | 26/02/2019
-- Limitation :
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			26/02/2019		Création
--	JPI			16/04/2019		La table de résultat doit être persistante
--
---------------------------------------------------------------------------------------------------------------
DECLARE
	query character varying;
	rec RECORD;
	id_before_insert int := 0;
BEGIN
	CREATE EXTENSION IF NOT EXISTS pgstattuple WITH SCHEMA master; -- Ajouter l'extension de statistiques complémentaires si nécessaire
	CREATE TABLE IF NOT EXISTS common.index_script_results
	(
		id serial primary key
		, date_sys_diag_index timestamp
		, schema_name character varying
		, table_name character varying
		, index_name character varying
		, status character varying
	);
	
	SELECT MAX(id) INTO id_before_insert							-- Reprendre le dernier identifiant connu avant nouvelle insertion
	FROM common.index_script_results; 
	
	INSERT INTO common.index_script_results
	(
		date_sys_diag_index
		, schema_name
		, table_name
		, index_name
		, status
	)
	SELECT 
		now(),
		s.schemaname,
		s.relname AS tablename,
		s.indexrelname AS indexname,
		'HAS TO BE DELETED ?'
	FROM pg_catalog.pg_stat_user_indexes s
	   JOIN pg_catalog.pg_index i ON s.indexrelid = i.indexrelid
	WHERE s.idx_scan = 0      										-- jamais utilisé
		AND 0 <> ALL (i.indkey) 									-- n'est pas une expression
		AND NOT i.indisunique   									-- n'est pas un index unique
		AND NOT EXISTS          									-- n'est pas utilisé comme contrainte
			(SELECT 1 
			FROM pg_catalog.pg_constraint c
			WHERE c.conindid = s.indexrelid)
		AND s.schemaname = in_schema_name
	ORDER BY pg_relation_size(s.indexrelid) DESC;
	
	-- lancement d'un curseur (pas tellement le choix ici : les locks seront trop importants et incontrolables si tout est lancé en parallèle)
	FOR rec IN
		SELECT 
			nspname as schema_name
			, t.relname as table_name
			, c.relname as index_name
		FROM pg_class C
			INNER JOIN pg_namespace N ON (N.oid = C.relnamespace) 
			INNER JOIN pg_index i ON i.indexrelid = c.oid
			INNER JOIN pg_class t on t.oid = i.indrelid
			,master.PGSTATINDEX(c.oid) AS r
		WHERE 
			nspname NOT IN ('pg_catalog', 'information_schema') 
			AND nspname !~ '^pg_toast' 
			AND C.relkind IN ('i')
			AND i.indisprimary = false
			AND leaf_fragmentation > 30								-- Fragmentation supérieure à 30%
			AND leaf_fragmentation <> 'NaN'
			AND nspname = in_schema_name
	LOOP
		query := 'REINDEX INDEX '||rec.schema_name||'.'||rec.index_name||';';
		EXECUTE query;
		INSERT INTO common.index_script_results
		(
			date_sys_diag_index
			, schema_name
			, table_name
			, index_name
			, status
		)
		VALUES 
		(
			now()
			, rec.schema_name
			, rec.table_name
			, rec.index_name
			, 'REINDEXED'
		);
	END LOOP;
	
	FOR rec IN
		SELECT DISTINCT temp_i.schema_name, temp_i.table_name
		FROM common.index_script_results temp_i
		WHERE id > id_before_insert
	LOOP
		query := 'ANALYZE '||rec.schema_name||'.'||rec.table_name||';';
		EXECUTE query;
	END LOOP;
	
	RETURN QUERY 
		SELECT 
			schema_name
			, table_name
			, index_name
			, status
		FROM common.index_script_results 
		WHERE id > id_before_insert;	
END;
$$;