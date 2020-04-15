CREATE OR REPLACE PROCEDURE common.drop_cascade_roles()
 LANGUAGE plpgsql
AS $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de supprimer les rôles surnuméraires.
--		Le rôle writer peut avoir des droits en trop sur une colonne séquencée : UPDATE et INSERT.
--		Si une colonne est transformée en clé primaire séquencée, alors le rôle writer doit se voir révoquer 
--		les droits INSERT et UPDATE.
-- Origines : PostgreSQL v11 
-- Limitation : 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			09/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
DECLARE 
	query character varying;
BEGIN
	-- grant update et insert au writer pour toutes les colonnes sauf les pk qui ont une sÃ©quence
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
		-- Tous les droits dont ont doit se prÃ©occuper
		select *
		from unnest(string_to_array('UPDATE, INSERT', ', ')) as t
	)
	, cte_all_pk_seq as
	(
		-- Toutes les colonnes clÃ© primaires sÃ©quentielles
		select 
			c.table_name as table_name
			, c.column_name
			, c.table_schema as schema_name
		from information_schema.columns c
			inner join information_schema.table_constraints tc				-- Table renfermant les contraintes imposées par les colonnes sur les tables
				on tc.table_name = c.table_name
				and c.table_schema = tc.table_schema
			inner join information_schema.sequences s
				on c.column_default like '%'||s.sequence_name||'''::%' --sÃ©quence
				and s.sequence_schema = 'master'
		where c.table_schema = 'master'
			and tc.constraint_type = 'PRIMARY KEY'	-- ClÃ© primaire
			and (c.column_default like '%nextval%') -- sÃ©quence
	)
	, cte_all_unwished_grant as
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
		and exists 		-- Concernant des colonnes clÃ© primaires sÃ©quencÃ©es où le writer a des droits INSERT OU UPDATE
		(
			select 1 
			from cte_all_pk_seq cte
				inner join information_schema.role_column_grants r
					on cte.schema_name = r.table_schema
					and cte.table_name = r.table_name
					and cte.column_name = r.column_name
			where  'master' = cte.schema_name
				and cl.table_name = cte.table_name
				and cl.column_name = cte.column_name
				and privilege_type IN ('INSERT', 'UPDATE')
		)	
		group by cl.table_schema, cl.table_name, r.t
	)
	select
		-- agrégation de toutes les commandes pour révoquer les droits voulus
		string_agg('REVOKE '||t||' ('||ref_columns||') ON '||schema_name||'.'||table_name||' FROM writer_'||schema_name||', writer_all;', chr(10)) into query
	from cte_all_unwished_grant r;
	
	
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('drop_cascade_roles' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('drop_cascade_roles' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			raise '%', chr(10)||'error in ''common.drop_cascade_roles'' consequently to : '||sqlerrm;
END;
$procedure$
;
