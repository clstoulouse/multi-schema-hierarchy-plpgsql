create or replace procedure common.index_naming_control_first()
language plpgsql
as $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de renommer les indexes s'il y a lieu sur le schéma master.
-- Origines : PostgreSQL v11 | 01/08/2019
-- Limitation : 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			01/08/2019		Création
--
---------------------------------------------------------------------------------------------------------------
declare
	query character varying;
begin
	with cte_referential as
	(
		SELECT
			i.relname as idx_name
			, t.relname as table_name
			, idx.indisunique
			, am.amname as index_type
			, string_agg(a.attname, ', ') as liste_colonne
		FROM pg_index AS idx
			INNER JOIN pg_class AS i
				ON i.oid = idx.indexrelid
			INNER JOIN pg_namespace AS ns
				ON ns.oid = i.relnamespace
			INNER JOIN pg_class AS t
				ON t.oid = idx.indrelid
				AND t.relkind = 'r'			
			INNER JOIN pg_am am ON am.oid=i.relam			
			INNER JOIN pg_attribute a on a.attrelid = t.oid
					and a.attnum = ANY(idx.indkey)
		WHERE ns.nspname = 'master'
			AND t.relname IN 
			(
				SELECT table_name
				FROM information_schema.tables
				WHERE table_schema = 'master'
			)
			AND idx.indisprimary = false
		GROUP BY i.relname, t.relname, idx.indisunique, am.amname
	)
	, cte_final as
	(
		select idx_name
			, indisunique
			, index_type
			, table_name
			, liste_colonne
			, case 
				when indisunique
					then 'idxu_'||LPAD(nextval('master.sq_master_idxus_id')::text, 5, '0')
					else 'idx_'||LPAD(nextval('master.sq_master_idxs_id')::text, 5, '0')
			end as new_name
		from cte_referential
		where 
			(
				(substring(idx_name, 1, 4) <> 'idx_' or char_length(idx_name) <> 9 or common.isnumeric(substring(idx_name, 5, 9)) is false)
				and (substring(idx_name, 1, 5) <> 'idxu_' or char_length(idx_name) <> 10 or common.isnumeric(substring(idx_name, 6, 10)) is false)
			)
		limit 1
	)
	select 		
		'ALTER INDEX master.'||idx_name||' RENAME TO '||new_name||';'
		||chr(10)||
		'COMMENT ON INDEX master.'||new_name||' IS ''Index de type '||index_type||' sur les colonnes '||liste_colonne||' sur la table master.'||table_name||' '||case when indisunique then '(UNIQUE)'';' else ''';' end	
		into query
	from cte_final;
	
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('index_naming_control_first' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('index_naming_control_first' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			ROLLBACK;
end;
$$