create or replace procedure common.build_if_has_to_pks()
 language plpgsql
as $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de propager les clés primaires nouvellement créées.
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
	with cte_master_pks as
	(
		-- Lister toutes les clés primaires du schéma master
		SELECT
			rel.relname as table_name
			, ccu.table_name as ref_table_name
			, pg_get_constraintdef(con.oid) as con_def						-- Contient la défintion DDL de la contrainte. Need to add the alter table by and though.
			, string_agg(ccu.column_name, ' ,' order by ccu.column_name) as ref_columns
			, con.conname
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN information_schema.constraint_column_usage AS ccu
			  ON ccu.constraint_name = con.conname
			  AND ccu.table_schema = nsp.nspname
		WHERE nsp.nspname = 'master'
			and con.contype = 'p'
		GROUP BY con.contype, nsp.nspname, rel.relname, ccu.table_name, con.conname, con.oid
	)
	, cte_all_client_list as
	(
		-- Tous les clients
		select schema_name, cl.client_id
		from information_schema.schemata s
			left outer join common.dwh_dm_client cl
			on s.schema_name = cl.client_waste_nom
		where schema_name <> 'information_schema' 
			and schema_name <> 'common'
			and schema_name <> 'pg_catalog'
			and schema_name <> 'master'
			and schema_name <> 'unit_tests'
			and schema_name not like 'pg_toast%'
			and schema_name not like 'pg_temp%'
	)
	, cte_clients_pks as
	(
		-- Lister toutes les clés primaires des clients
		SELECT
			rel.relname as table_name
			, ccu.table_name as ref_table_name
			, string_agg(ccu.column_name, ' ,' order by ccu.column_name) as ref_columns
			, pg_get_constraintdef(con.oid) as con_def
			, nsp.nspname as schema_name
			, con.conname
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN information_schema.constraint_column_usage AS ccu
			  ON ccu.constraint_name = con.conname
			  AND ccu.table_schema = nsp.nspname
		WHERE con.contype = 'p'
			and exists (select 1 from cte_all_client_list where schema_name = nsp.nspname)
		GROUP BY con.contype, nsp.nspname, rel.relname, ccu.table_name, con.oid, con.conname
	)
	select 
		string_agg(
		'ALTER TABLE '||c.schema_name||'.'||m.table_name||'
		ADD CONSTRAINT '||m.conname||'_'||LPAD(c.client_id::text, 5, '0')||' '||
			case when position('REFERENCES master.' in m.con_def) > 0 
				then replace (m.con_def, 'master', c.schema_name)
				else replace(m.con_def, 'REFERENCES ', 'REFERENCES ' || c.schema_name || '.')
			end
		||';'||chr(10)||		
		'COMMENT ON CONSTRAINT '||conname||'_'||LPAD(c.client_id::text, 5, '0')||' ON '||c.schema_name||'.'||table_name||' IS '''||
			'Contrainte de type PRIMARY KEY sur la table '||c.schema_name||'.'||m.table_name
			||''';', chr(13)) into query
	from cte_all_client_list c
		cross join cte_master_pks m
	where not exists 
		(
			select 1 
			from cte_clients_pks cf 
			where cf.schema_name = c.schema_name 
				and cf.table_name = m.table_name 
				and cf.conname like m.conname||'%'
		);
		
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('build_if_has_to_pks' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('build_if_has_to_pks' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			ROLLBACK;
end;
$$