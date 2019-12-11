CREATE OR REPLACE PROCEDURE common.data_purge()
 LANGUAGE plpgsql
AS $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette fonction est de purger tous les clients en s'aidant de la table common.purge_tool_conf
-- Origines : PostgreSQL v11 | 06/03/2019
-- Limitation : 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			06/03/2019		CrÃ©ation
--  JPI			02/04/2019		Correction de bugs mineurs
--
---------------------------------------------------------------------------------------------------------------
DECLARE 
	query character varying;
	missingIndexes character varying;
BEGIN
	CREATE TABLE IF NOT EXISTS common.purge_tool_conf
	(
		table_name varchar(100) CHECK (common.check_table_presence(table_name))
		, column_name varchar(200) CHECK (common.check_column_presence(table_name, column_name))
		, retentionInterval varchar(20) CHECK (common.check_data_purge_retentionInterval(retentionInterval))
	);
	
	IF (SELECT COUNT(*) FROM common.purge_tool_conf) = 0
	THEN 
		RAISE EXCEPTION 'Aucune table n''est configurÃ©e comme ''purgeable'' dans la table de purge : ''common.purge_tool_conf''.';
	ELSE
		-- MÃ©canisme de prÃ©vention d'oubli d'index sur la colonne prÃ©cisÃ©e
		SELECT 
			string_agg('CREATE INDEX idx_'||C.table_name||'_'||C.column_name||' ON master.'||C.table_name||' USING btree ('||C.column_name||');',chr(10)) INTO missingIndexes
		FROM common.purge_tool_conf C
			LEFT OUTER JOIN pg_class T
				ON T.relname = C.table_name
				AND T.relkind = 'r'	
			LEFT OUTER JOIN pg_index idx 
				ON T.oid = idx.indrelid
				AND pg_get_indexdef(idx.indexrelid) LIKE 'CREATE INDEX % ON master.'||C.table_name||' USING btree ('||C.column_name||')'
			LEFT OUTER JOIN pg_class I
				ON I.oid = idx.indexrelid
			LEFT OUTER JOIN pg_namespace AS ns
				ON ns.oid = T.relnamespace
		WHERE ns.nspname = 'master'
			AND I.relname IS NULL;
		
		IF missingIndexes IS NOT NULL
		THEN
			RAISE EXCEPTION 'Les indexes suivant sont manquants et obligatoire avant le lancement de la purge : %', missingIndexes;
		END IF;
		
		-- Pour toutes les tables du mÃ©canisme de purge, sur tous les clients, supprimer les donnÃ©es antÃ©rieur Ã  now() - interval retentionInterval
		WITH cte_all_clients as 
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
		SELECT string_agg(distinct('DELETE FROM '||C.schema_name||'.'||CF.table_name||' WHERE '||CF.column_name||' < now() - interval '''||CF.retentionInterval||''';'), chr(10)) into query
		from cte_all_clients C
			cross join common.purge_tool_conf CF;
		
		RAISE NOTICE '%', query;
		EXECUTE query;
	END IF;
END;
$procedure$
;


