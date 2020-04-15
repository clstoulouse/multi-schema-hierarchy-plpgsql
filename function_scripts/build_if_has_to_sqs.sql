create or replace procedure common.build_if_has_to_sqs()
language plpgsql
as $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de :
--			* créer automatiquement des séquences
--			* supprimer automatiquement des séquences
--			* renommer automatiquement des séquences
-- Origines : PostgreSQL v11 | 15/02/2019
-- Limitation :
--			Cela ne concerne que les clés primaires des différentes tables.
--			Ne prends en compte que les clés primaires uni-colonne.
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/02/2019		Création
--  JPI			04/04/2019		Ajout de la discrimination du schéma de test unitaire
--
---------------------------------------------------------------------------------------------------------------
declare
	query character varying;
begin
	-- Suppression des séquences pour clé primaire ne servant plus
	with cte_all_due_seq as
	(
		-- Liste de toutes les séquences concernant des clés primaires
		select distinct
			s.sequence_name
		from information_schema.columns c
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
		and tc.constraint_type = 'PRIMARY KEY'
	)
	select string_agg('DROP SEQUENCE master.'||s.sequence_name||' CASCADE;', chr(10)) into query
	from information_schema."sequences" s
	where s.sequence_name not in (select sequence_name from cte_all_due_seq)
		and s.sequence_schema = 'master'
		and s.sequence_name like 'sq_pk_%'
		and s.sequence_name <> 'sq_master_pks_id'
		and s.sequence_name <> 'sq_master_fks_id'
		and s.sequence_name <> 'sq_master_idxs_id';
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('build_if_has_to_sqs' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	-- Créer les séquences manquantes
	-- Mettre cette nouvelle séquence en valeur par défault sur la table 'master'
	with cte_eligible_pk as
	(
		-- Liste des colonnes représentant des pks sur plus de une colonne
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
				inner join pg_type t
					on t.oid = a.atttypid
					and typcategory = 'N'
					and typname like 'int%'
			WHERE nspname = 'master' 
				AND idx.indisprimary
			group by a.attname, c.relname
		) as t
		where t.nbr_col < 2
	)
	select distinct 
		string_agg('CREATE SEQUENCE master.sq_pk_'||c.table_name||' start 1;
		alter table master.'||c.table_name||'
		alter column '||c.column_name||' set default nextval(''master.sq_pk_'||c.table_name||''');', chr(10)) into query
	from information_schema.columns c
	where c.table_schema = 'master'
		and (c.table_name, c.column_name) in (select table_name, column_name from cte_eligible_pk)
		and (c.column_default is null or c.column_default not like '%nextval%');
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('build_if_has_to_sqs' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	-- Normalisation des noms de séquences pour clé primaire
	-- Norme à respecter : 'sq_pk_'||nom_table_porteuse
	select distinct 
		string_agg('ALTER SEQUENCE master.'||s.sequence_name||' RENAME TO sq_pk_'||c.table_name||';', chr(10)) into query
	from information_schema.columns c
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
		and tc.constraint_type = 'PRIMARY KEY'
		and (c.column_default like '%nextval%')
		and (c.column_default not like '%nextval(''sq_pk_'||c.table_name||'''%')
		and s.sequence_name <> 'sq_pk_'||c.table_name;
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('build_if_has_to_sqs' as varchar), CAST(query as text), cast(1 as bit));
	end if;
		
	-- Grant the writers
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
		where s.sequence_schema = 'master'
			and s.sequence_name like 'sq_pk_%'
			and s.sequence_name <> 'sq_master_fks_id'
	)
	select 
		string_agg('GRANT USAGE ON master.'||sequence_name||' TO writer_'||schema_name||', writer_all;', chr(10)) into query
	from cte_wanted_roles c
	where ('writer_'||schema_name, sequence_name, schema_name) not in 
		(
			select r.grantee, r.sq_name, c2.schema_name 
			from cte_client_list c2
				cross join cte_current_roles r
			where c2.schema_name = c.schema_name
				and r.grantee like 'writer_%'
		);
		
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('build_if_has_to_sqs' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('build_if_has_to_sqs' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			raise '%', chr(10)||'error in ''common.build_if_has_to_sqs'' consequently to : '||sqlerrm;
end;
$$