CREATE OR REPLACE PROCEDURE common.build_if_has_to_idxs()
language plpgsql
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de propager les index du schéma 'master' vers ceux des clients
-- Origines : PostgreSQL v11 | 15/02/2019
-- Limitation :
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/02/2019		Création
--  JPI			04/04/2019		Ajout de la discrimination du schéma de test unitaire
--
---------------------------------------------------------------------------------------------------------------
DECLARE
	query character varying;
BEGIN
	WITH cte_idx_master AS
	(
		-- Lister tous les indexes non-clé primaire dans le schéma 'master'
		SELECT 
			replace(pg_get_indexdef(idx.indexrelid), 'INDEX', 'INDEX IF NOT EXISTS') as idxs			-- Fonction permettant d'obtenir le script DDL de l'index
			, i.relname as idx_name
			, t.relname as table_name
			, idx.indisunique
			, am.amname as index_type
			, string_agg(a.attname, ', ') as liste_colonne
		FROM pg_index AS idx								-- Table système concernant les index
			INNER JOIN pg_class AS i						-- Table système concernant toute entité dans postgresql : ici l'index
				ON i.oid = idx.indexrelid
			INNER JOIN pg_namespace AS ns					-- Table système concernant les schémas dans postgresql
				ON ns.oid = i.relnamespace
			INNER JOIN pg_class AS t						-- Table système concernant toute entité dans postgresql : ici la table
				ON t.oid = idx.indrelid
				AND t.relkind = 'r'	
			INNER JOIN pg_am am ON am.oid=i.relam			
			INNER JOIN pg_attribute a on a.attrelid = t.oid
					and a.attnum = ANY(idx.indkey)
		WHERE ns.nspname = 'master'
			AND idx.indisprimary = false
		GROUP BY idx.indexrelid, i.relname, idx.indisunique, t.relname, am.amname
	)
	, cte_all_client_list as
	(
		-- Tous les clients
		SELECT schema_name, cl.client_id
		from information_schema.schemata s
			left outer join common.dwh_dm_client cl
			on s.schema_name = cl.client_waste_nom
		WHERE schema_name <> 'information_schema' 			-- Schema d'information de la base
			AND schema_name <> 'common'
			AND schema_name <> 'pg_catalog'					-- Schema système renfermant '42'
			AND schema_name <> 'master'
			AND schema_name <> 'unit_tests'
			AND schema_name NOT LIKE 'pg_toast%'			-- Le toaster permettant une meilleure gestion des IOs
			AND schema_name NOT LIKE 'pg_temp%'				-- Table pour les objets temporaires
	)
	, cte_all_clients_idx_list AS
	(
		-- Trouver tous les index qui sont déjà au sein des schémas client.
		SELECT 
			i.relname AS idx_name
			, t.relname AS table_name
			, ns.nspname AS schema_name
		FROM pg_index idx
			INNER JOIN pg_class i
				ON idx.indexrelid = i.oid
			INNER JOIN pg_class t
				ON t.oid = idx.indrelid
				AND t.relkind = 'r'
			INNER JOIN pg_namespace AS ns
				ON ns.oid = t.relnamespace
		WHERE EXISTS (SELECT 1 FROM cte_all_client_list WHERE schema_name = ns.nspname)
			AND idx.indisprimary = false
	)
	SELECT 
		-- Aggregate all the instructions
		string_agg(
			case when position('ON master.' in idxs) > 0 
				then replace(replace(idxs, m.idx_name, m.idx_name||'_'||LPAD(c.client_id::text, 5, '0')), 'master', c.schema_name)
				else replace(replace(idxs, m.idx_name, m.idx_name||'_'||LPAD(c.client_id::text, 5, '0')), 'ON ', 'ON ' || c.schema_name || '.')
			end
			||';'||chr(10)||
			'COMMENT ON INDEX '||schema_name||'.'||m.idx_name||'_'||LPAD(c.client_id::text, 5, '0')||' IS ''Index de type '||index_type||' sur les colonnes '||liste_colonne||' sur la table '||schema_name||'.'||table_name||' '||case when indisunique then '(UNIQUE)'';' else ''';' end, chr(10)
		) into query
	FROM cte_all_client_list c
		CROSS JOIN cte_idx_master m								-- Créer le référentiel idéal : tous les index présents dans le 'master' sont dans tous les clients.
	WHERE not exists 
		(
			select 1
			from cte_all_clients_idx_list cf
			where cf.idx_name like m.idx_name||'%'
				and m.table_name = cf.table_name
				and c.schema_name = cf.schema_name
		);
		
	IF query IS NOT NULL 
	THEN 
		EXECUTE query;
		CALL common.deblog(CAST('build_if_has_to_idxs' as varchar), CAST(query as text), CAST(1 as bit));
	END IF;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('build_if_has_to_idxs' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			raise '%', chr(10)||'error in ''common.build_if_has_to_idxs'' consequently to : '||sqlerrm;
END;
$$