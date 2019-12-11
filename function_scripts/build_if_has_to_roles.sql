CREATE OR REPLACE PROCEDURE common.build_if_has_to_roles()
 language plpgsql
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de créer de nouveaux droits writer si manquants )
-- Origines : PostgreSQL v11 | 15/02/2019
-- Limitation : Droits seulement en lecture pour les colonnes pk séquentielles (automatique à la création de la colonne)
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/02/2019		Création
--  JPI			04/04/2019		Ajout de la discrimination du schéma de test unitaire
--
---------------------------------------------------------------------------------------------------------------
DECLARE 
	query character varying;
BEGIN
	-- grant update et insert au writer pour toutes les colonnes sauf les pk qui ont une séquence
	with cte_all_clients as
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
	, cte_all_current_grant as
	(
		-- Tous les droits des clients
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema in (select schema_name from cte_all_clients)
			and grantee = 'writer_'||r.table_schema
	)
	, cte_possible_privileges as
	(
		-- Tous les droits dont ont doit se préoccuper
		select *
		from unnest(string_to_array('UPDATE, INSERT', ', ')) as t
	)
	, cte_all_pk_seq as
	(
		-- Toutes les colonnes clé primaires séquentielles
		select 
			c.table_name as table_name
			, c.column_name
			, c.table_schema as schema_name
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
				on c.column_default like '%'||s.sequence_name||'''::%' --séquence
				and s.sequence_schema = 'master'
		where c.table_schema = 'master'
			and tc.constraint_type = 'PRIMARY KEY'	-- Clé primaire
			and (c.column_default like '%nextval%') -- séquence
	)
	, cte_all_wished_grant as
	(
		-- Tous les droits 
		select 
			cl.table_schema as schema_name
			, cl.table_name
			, string_agg(cl.column_name, ',' order by cl.column_name) as ref_columns
			, r.t
		from cte_all_clients c
			inner join information_schema.columns cl
				on cl.table_schema = c.schema_name
			cross join cte_possible_privileges r
		where (cl.table_schema, cl.table_name, cl.column_name) not in (select cte.schema_name, cte.table_name, cte.column_name from cte_all_pk_seq cte)	
		and not exists 		-- Pas dans les colonnes clé primaires séquencées
		(
			select 1 
			from cte_all_pk_seq cte
			where  'master' = cte.schema_name
				and cl.table_name = cte.table_name
				and cl.column_name = cte.column_name
		)	
		group by cl.table_schema, cl.table_name, r.t
	)
	select
		string_agg('GRANT '||t||' ('||ref_columns||') ON '||schema_name||'.'||table_name||' TO writer_'||schema_name||', writer_all;', chr(10)) into query
	from cte_all_wished_grant r;
	
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('build_if_has_to_roles' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			ROLLBACK;
			CALL common.deblog(CAST('build_if_has_to_roles' as varchar), CAST(SQLERRM as text), cast(0 as bit));
END;
$$