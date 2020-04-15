create or replace procedure common.build_if_has_to_tables()
language plpgsql
as $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procedure est de permettre la création d'une nouvelle table.
-- Origines : PostgreSQL v11 | 15/02/2019
-- Limitation :
--			Les tables du schéma 'master' sont estimées comme devant toutes être dans tous les clients
--			Tous les schémas en dehors de : 'pg_catalog', 'information_schema', 'master', 'common', 'pg_toast%'
--			et 'pg_temp%' sont des schémas de client.
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/02/2019		Création
--  JPI			04/04/2019		Ajout de la discrimination du schéma de test unitaire
--
---------------------------------------------------------------------------------------------------------------
declare
	query character varying;
	query_grant character varying;
begin
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
	, cte_have_to_create_tables as
	(
		-- Toutes les tables qui devraient être ajoutées dans le schéma
		select 
			c.schema_name
			, m.table_name
		from cte_all_master_tables m
			cross join cte_all_clients c 	-- Toutes les tables qui devraient être présentes
		where m.table_name not in 			-- Qui ne sont pas dans
			(
				select cls.table_name 		-- La liste des tables actuellement dans les schémas clients
				from cte_all_clients_tables cls 
				where cls.schema_name = c.schema_name
			)
	)
	select 
		string_agg(
		'grant select on all tables in schema '||nt.schema_name||' to writer_'||nt.schema_name||', reader_'||nt.schema_name||', reader_all, writer_all, dashboard;'||chr(10)
		||'grant insert('||column_list||'), update('||column_list||') on '||nt.schema_name||'.'||nt.table_name||' to writer_'||nt.schema_name||', writer_all;'||chr(10)
		||'grant delete on '||nt.schema_name||'.'||nt.table_name||' to writer_'||nt.schema_name||', writer_all;', chr(10)
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
		SELECT string_agg(column_name, ', ') as column_list , table_name
		FROM information_schema.columns
		WHERE table_schema = 'master'
			and (column_name, table_name) not in (select column_name, table_name from cte_pk_seq)
			and (column_name, table_name) not in (select column_name, table_name from cte_pk_uni_int)
		group by table_name		
	) as t_final
		inner join cte_have_to_create_tables nt
		on nt.table_name = t_final.table_name;
		
	-- Contruire les nouvelles tables
	with cte_all_master_tables as
	(
		-- Liste de toutes les tables du schéma 'master'
		SELECT table_name
		FROM information_schema.tables 
		WHERE table_schema = 'master'
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
		-- Liste de toutes les tables clientes par schéma
		SELECT table_name, table_schema as schema_name
		FROM information_schema.tables 
		WHERE table_schema in (select schema_name from cte_all_clients)
	)
	select string_agg('CREATE TABLE '||c.schema_name||'.'||m.table_name||' () INHERITS (master.'||m.table_name||');', chr(10)) into query
	from cte_all_master_tables m
		cross join cte_all_clients c
	where m.table_name not in 
		(
			select cls.table_name 
			from cte_all_clients_tables cls 
			where cls.schema_name = c.schema_name
		);
	
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('build_if_has_to_tables' as varchar), CAST(query as text), cast(1 as bit));
		
		if query_grant is not null 
		then 
			EXECUTE query_grant;
		CALL common.deblog(CAST('build_if_has_to_tables' as varchar), CAST(query_grant as text), cast(1 as bit));
		end if;
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('build_if_has_to_tables' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			raise '%', chr(10)||'error in ''common.build_if_has_to_tables'' consequently to : '||sqlerrm;
end;
$$;