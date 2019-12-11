create or replace procedure unit_tests.create_new_client_nom_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'create_new_client'
--		Ce test a pour but de :
/*
	Pré-requis :
	NA
	
	Action :
	Créer un nouveau client
	
	Résultat attendu :
	Une ligne supplémentaire est créé dans la table 'common.dwh_dm_client'
	Le schéma est créé
	Le rôle reader associé existe
	Le rôle writer associé existe	
	Les deux rôles ont le droit USAGE sur le schéma créé
	Les deux rôles ont search_path le nom du nouveau schéma
*/
-- PARTIE RESULTAT
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			12/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	if not exists (
		SELECT 1
		FROM common.dwh_dm_client
		WHERE client_waste_nom = 'client_1'
	)
	then 
		raise exception 'Le client n''a pas été créé dans la table common.dwh_dm_client.';
	end if;
	
	if not exists (
		select 1
		from information_schema.schemata
		where schema_name = 'client_1'
	)
	then 
		raise exception 'Le schéma client_1 n''a pas été créé.';
	end if;
	
	if not exists (
		select 1
		from pg_catalog.pg_roles
		where rolname = 'writer_client_1'
	)
	then 
		raise exception 'Le rôle writer du client_1 n''existe pas.';
	end if;
	
	if not exists (
		select 1
		from pg_catalog.pg_roles
		where rolname = 'reader_client_1'		
	)
	then 
		raise exception 'Le rôle reader du client_1 n''existe pas.';
	end if;
	
	if not exists (
		select 1
		from pg_catalog.pg_roles
		where rolname = 'writer_all'
	)
	then 
		raise exception 'Le rôle writer général n''existe pas.';
	end if;
	
	if not exists (
		select 1
		from pg_catalog.pg_roles
		where rolname = 'reader_all'		
	)
	then 
		raise exception 'Le rôle reader général n''existe pas.';
	end if;
	
	if not exists (
		select 1
		from
		(
			select
				nspname as schema_name
				, r.rolname as role_name
				, pg_catalog.has_schema_privilege(r.rolname, nspname, 'CREATE') as create_grant
				, pg_catalog.has_schema_privilege(r.rolname, nspname, 'USAGE') as usage_grant
			from pg_namespace pn,pg_catalog.pg_roles r
			where array_to_string(nspacl,',') like '%'||r.rolname||'%' 
				and nspowner > 1 
		) T
		where schema_name = 'client_1'
			and role_name = 'writer_client_1' 
			and usage_grant = true
	)
	then 
		raise exception 'The writer_client_1 has no USAGE grant on the schema client_1.';
	end if;
	
	if not exists (
		select 1
		from
		(
			select
				nspname as schema_name
				, r.rolname as role_name
				, pg_catalog.has_schema_privilege(r.rolname, nspname, 'CREATE') as create_grant
				, pg_catalog.has_schema_privilege(r.rolname, nspname, 'USAGE') as usage_grant
			from pg_namespace pn,pg_catalog.pg_roles r
			where array_to_string(nspacl,',') like '%'||r.rolname||'%' 
				and nspowner > 1 
		) T
		where schema_name = 'client_1'
			and role_name = 'writer_all' 
			and usage_grant = true
	)
	then 
		raise exception 'The writer_all has no USAGE grant on the schema client_1.';
	end if;
	
	if not exists (
		select 1
		from
		(
			select
				nspname as schema_name
				, r.rolname as role_name
				, pg_catalog.has_schema_privilege(r.rolname, nspname, 'CREATE') as create_grant
				, pg_catalog.has_schema_privilege(r.rolname, nspname, 'USAGE') as usage_grant
			from pg_namespace pn,pg_catalog.pg_roles r
			where array_to_string(nspacl,',') like '%'||r.rolname||'%' 
				and nspowner > 1 
		) T
		where schema_name = 'client_1'
			and role_name = 'reader_client_1' 
			and usage_grant = true
	)
	then 
		raise exception 'The reader_client_1 has no USAGE grant on the schema client_1.';
	end if;
	
	if not exists (
		select 1
		from
		(
			select
				nspname as schema_name
				, r.rolname as role_name
				, pg_catalog.has_schema_privilege(r.rolname, nspname, 'CREATE') as create_grant
				, pg_catalog.has_schema_privilege(r.rolname, nspname, 'USAGE') as usage_grant
			from pg_namespace pn,pg_catalog.pg_roles r
			where array_to_string(nspacl,',') like '%'||r.rolname||'%' 
				and nspowner > 1 
		) T
		where schema_name = 'client_1'
			and role_name = 'reader_all' 
			and usage_grant = true
	)
	then 
		raise exception 'The reader_all has no USAGE grant on the schema client_1.';
	end if;
	
	if not exists (
		with cte as
		(
			select 
				role_name
				, database_name
				, case 
					when position('search_path=' in config) > 0
					then substring(config from char_length('search_path=') +1 for (char_length(config) - char_length('search_path=')))
				end as search_path
			from 
			(
				select
					r.rolname as role_name
					, d.datname as database_name
					, unnest(rs.setconfig) as config
				from pg_catalog.pg_db_role_setting rs
					LEFT outer JOIN pg_roles      r ON r.oid = rs.setrole
					left outer JOIN pg_database   d ON d.oid = rs.setdatabase
			) T
			where database_name = current_database()
		)
		select 1
		from cte
		where role_name = 'writer_client_1'
			and search_path = 'client_1'
	)
	then 
		raise exception 'La configuration du search_path de writer_client_1 n''est pas le schéma client_1.';
	end if;
	
	if not exists (
		with cte as
		(
			select 
				role_name
				, database_name
				, case 
					when position('search_path=' in config) > 0
					then substring(config from char_length('search_path=') +1 for (char_length(config) - char_length('search_path=')))
				end as search_path
			from 
			(
				select
					r.rolname as role_name
					, d.datname as database_name
					, unnest(rs.setconfig) as config
				from pg_catalog.pg_db_role_setting rs
					LEFT outer JOIN pg_roles      r ON r.oid = rs.setrole
					left outer JOIN pg_database   d ON d.oid = rs.setdatabase
			) T
			where database_name = current_database()
		)
		select 1
		from cte
		where role_name = 'reader_client_1'
			and search_path = 'client_1'
	)
	then 
		raise exception 'La configuration du search_path de reader_client_1 n''est pas le schéma client_1.';
	end if;
	
	CALL unit_tests.deblog('create_new_client_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('create_new_client_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;