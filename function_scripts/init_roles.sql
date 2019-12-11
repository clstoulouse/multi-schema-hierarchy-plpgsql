do language plpgsql $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de ce script est d'initialiser les rôles généraux à la création de la base multiclient.
-- Origines : PostgreSQL v11 | 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			26/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
declare
	query_grant varchar;
begin
	if exists
		(
			select 1
			from pg_roles rol
			where rol.rolname = 'dashboard'
		)
	then
		DROP OWNED BY dashboard CASCADE;
		DROP ROLE IF EXISTS dashboard;
	end if;

	CREATE ROLE dashboard LOGIN PASSWORD 'dashboard'; 
	GRANT USAGE ON SCHEMA master to dashboard; 
	GRANT SELECT ON ALL TABLES IN SCHEMA master TO dashboard;

	if exists
		(
			select 1
			from pg_roles rol
			where rol.rolname = 'reader_all'
		)
	then
		DROP OWNED BY reader_all CASCADE;
		DROP ROLE IF EXISTS reader_all;
	end if;
	CREATE ROLE reader_all LOGIN PASSWORD 'reader_all';

	if exists
		(
			select 1
			from pg_roles rol
			where rol.rolname = 'writer_all'
		)
	then
		DROP OWNED BY writer_all CASCADE;
		DROP ROLE IF EXISTS writer_all;
	end if;
	CREATE ROLE writer_all LOGIN PASSWORD 'writer_all';
	
	-- Donner les droits aux clients existants (blindage)
	-- Construire les nouveaux droits
	with cte_all_master_tables as
	(
		-- Toutes les tables du schéma 'master'
		SELECT table_name
		FROM information_schema.tables 
		WHERE table_schema = 'master'
			AND table_type = 'BASE TABLE'
	)
	, cte_all_clients as
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
	, cte_all_clients_tables as
	(
		-- Toutes les tables actuelles de tous les clients
		SELECT table_name, table_schema as schema_name
		FROM information_schema.tables 
		WHERE table_schema in (select schema_name from cte_all_clients)
			and table_name <> 'query'
	)
	select 
		string_agg(
		'grant usage on schema '||t_final.schema_name||' to reader_all, writer_all, dashboard;'||chr(10)
		||'grant select on all tables in schema '||t_final.schema_name||' to  reader_all, writer_all, dashboard;'||chr(10)
		||'grant insert('||column_list||'), update('||column_list||') on '||t_final.schema_name||'.'||t_final.table_name||' to writer_all;'||chr(10)
		||'grant delete on '||t_final.schema_name||'.'||t_final.table_name||' to writer_all;', chr(10)
		) into query_grant
	from
	(
		-- Lister les colonnes par table qui ne sont pas des clé primaires séquencées ou unicolonne et type type int
		with cte_pk_seq as
		(
			select 
				c.column_name
				, c.table_name
			from
				information_schema.columns c
				inner join information_schema.table_constraints tc
					on tc.table_name = c.table_name
					and c.table_schema = tc.table_schema
				inner join information_schema.key_column_usage kc
					on kc.constraint_name = tc.constraint_name
					and kc.table_name = tc.table_name
					and kc.table_schema = tc.table_schema
					and kc.column_name = c.column_name
				inner join information_schema.sequences s
					on c.column_default like '%'||s.sequence_name||'''::%'
					and s.sequence_schema = 'master'
			where c.table_schema = 'master'
				and tc.constraint_type = 'PRIMARY KEY'		-- Clé primaire
				and (c.column_default like '%nextval%')		-- Séquencée
		)	
		, cte_pk_uni_int as
		(
			select 
				column_name
				, table_name
			from
			(
				SELECT               
					a.attname as column_name, 
					c.relname as table_name,
					COUNT(c.relname) over (partition by c.relname) as nbr_col
				FROM pg_index idx
					inner join pg_class c
						on idx.indrelid = c.oid
					inner join pg_attribute a
						on a.attrelid = c.oid 
						AND a.attnum = any(idx.indkey)
					inner join pg_namespace ns
						on c.relnamespace = ns.oid
					inner join pg_type t					-- type int
						on t.oid = a.atttypid
						and typcategory = 'N'
						and typname like 'int%'
				WHERE nspname = 'master' 
					AND idx.indisprimary
					group by a.attname, c.relname
			) as t
			where t.nbr_col < 2								-- uni colonne
		)
		SELECT string_agg(column_name, ', ') as column_list , table_name, table_schema as schema_name
		FROM information_schema.columns
		WHERE table_schema in (select schema_name from cte_all_clients)
			and (column_name, table_name) not in (select column_name, table_name from cte_pk_seq)
			and (column_name, table_name) not in (select column_name, table_name from cte_pk_uni_int)
		group by table_name, table_schema
	) as t_final;
	
	if query_grant is not null 
	then 
		EXECUTE query_grant;
		CALL common.deblog(CAST('init_roles' as varchar), CAST(query_grant as text), cast(1 as bit));
	end if;
	
	with cte_current_roles as
	(
		SELECT grantee, object_name as sq_name
		FROM information_schema.role_usage_grants r
		where grantee like 'reader_%' or grantee like 'writer_%'
			and object_type = 'SEQUENCE'
	)
	, cte_client_list as 
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
	, cte_wanted_roles as
	(
		select s.sequence_name, c.schema_name
		from information_schema."sequences" s
			cross join cte_client_list c
		where s.sequence_name like 'sq_pk_%'
	)
	select 
		string_agg('GRANT USAGE ON master.'||sequence_name||' TO writer_all;', chr(10)) into query_grant
	from cte_wanted_roles c;
	
	if query_grant is not null 
	then 
		EXECUTE query_grant;
		CALL common.deblog(CAST('init_roles' as varchar), CAST(query_grant as text), cast(1 as bit));
	end if;
end;
$$;