create or replace procedure common.constraint_naming_control()
language plpgsql
as $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est renommer les contraintes s'il y a lieu.
--			Si n clés portent sur les mêmes tables elles seront suffixées par "_||'n'"
-- Origines : PostgreSQL v11 | 15/02/2019
-- Limitation : Clés étrangères et clés primaires uniquement pour le moment.
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/02/2019		Création
--	JPI			10/04/2019		Bug : Rollback a placer avant le log final
--  JPI			11/04/2019		BUG : Si le nom de contrainte est déjà utilisé.
--	JPI			31/07/2019		Correction pour le nouveau nom de la contrainte (plus générique)
--	JPI			08/08/2019		Ajout du COMMENT ON
--
---------------------------------------------------------------------------------------------------------------
declare
	query character varying;
begin
	with cte_referential as
	(
		-- Inventorier les clés présentent
		SELECT
			rel.relname as table_name
			, ccu.table_name as ref_table_name
			, string_agg(ccu.column_name, ' ,') as ref_columns
			, con.conname		-- nom tel qu'il est
			, con.contype	-- nom tel qu'il devrait être (préparation)
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN information_schema.constraint_column_usage AS ccu
			  ON ccu.constraint_name = con.conname
			  AND ccu.table_schema = nsp.nspname
		WHERE nsp.nspname = 'master'
			AND rel.relname IN 
			(
				SELECT table_name
				FROM information_schema.tables
				WHERE table_schema = 'master'
			)
		group by rel.relname, ccu.table_name, con.conname, con.contype
		order by conname
	)
	, cte_query as
	(
		-- Bâti des requêtes
		select 
			'COMMENT ON CONSTRAINT '||conname||' ON master.'||table_name||' IS '''||
			'Contrainte de '||case when contype = 'p' then 'PRIMARY KEY' else 'FOREIGN KEY' end||' de master.'||table_name||' vers master.'||ref_table_name||''
			||''';'||chr(10)||
			'ALTER TABLE master.'||table_name||' RENAME CONSTRAINT '||conname||' TO '||case 
				when contype = 'p'
					then 'pk_'||LPAD(nextval('master.sq_master_pks_id')::text, 5, '0')
				when contype = 'f'
					then 'fk_'||LPAD(nextval('master.sq_master_fks_id')::text, 5, '0')
			end||';' as queriable
		from cte_referential
		where (
				char_length(conname) <> 8
				or common.isnumeric(substring(conname, 4, 8)) is false
				or (substring(conname, 1 ,3) <> 'pk_' and substring(conname, 1 ,3) <> 'fk_')
			)
			and contype in ('f', 'p')
	)
	select string_agg(queriable, chr(10)) into query
	from cte_query
	where queriable is not null;
	
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('constraint_naming_control' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			ROLLBACK;
			CALL common.deblog(CAST('constraint_naming_control' as varchar), CAST(SQLERRM as text), cast(0 as bit));
end;
$$