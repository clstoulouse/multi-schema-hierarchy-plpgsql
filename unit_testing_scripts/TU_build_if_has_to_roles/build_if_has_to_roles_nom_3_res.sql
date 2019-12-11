create or replace procedure unit_tests.build_if_has_to_roles_nom_3_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 2 de la procédure 'build_if_has_to_roles'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 2 : OK
		
	Action :
	Créer une table test_2 avec deux champs {test_id int; value varchar(50)}
	
	Résultat attendu :
	Seuls existes le droit de SELECT pour le profil writer_client_1 pour la colonne test_id.
	Seuls existes le droit de SELECT pour le profil reader_client_1 pour la colonne test_id.
	Le profil writer_client_1 bénéficie des droits SELECT, INSERT et UPDATE sur la colonne client_1.
*/
-- Partie results		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			08/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin

	if not exists (
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_client_1')
			and privilege_type = 'SELECT'
			and table_name = 'test'
			and column_name = 'test_id'
	)
	then
		raise exception 'Le rôle writer n''a pas le droit de selection sur la colonne pk.';
	end if;
	
	if not exists (
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_all')
			and privilege_type = 'SELECT'
			and table_name = 'test'
			and column_name = 'test_id'
	)
	then
		raise exception 'Le rôle writer général n''a pas le droit de selection sur la colonne pk.';
	end if;

	if exists (
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_client_1')
			and (privilege_type = 'INSERT' OR privilege_type = 'UPDATE')
			and table_name = 'test'
			and column_name = 'test_id'
	)
	then
		raise exception 'Le rôle writer a des droits de modification sur la colonne d''identifiant alors que celle-ci est séquencée.';
	end if;

	if exists (
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_all')
			and (privilege_type = 'INSERT' OR privilege_type = 'UPDATE')
			and table_name = 'test'
			and column_name = 'test_id'
	)
	then
		raise exception 'Le rôle writer général a des droits de modification sur la colonne d''identifiant alors que celle-ci est séquencée.';
	end if;
	
	if not exists (
		select 1
		from
		(
			select string_agg(privilege_type, ', ' order by privilege_type) as rights
			from information_schema.role_column_grants r
			where table_schema = 'client_1'
				and (grantee = 'writer_client_1')
				and (privilege_type = 'INSERT' OR privilege_type = 'UPDATE' OR privilege_type = 'SELECT')
				and table_name = 'test'
				and column_name = 'value'
		) as t 
		where rights = 'INSERT, SELECT, UPDATE'
	)
	then
		raise exception 'Le rôle writer n''a pas les droits sur la colonne value.';
	end if;
	
	if not exists (
		select 1
		from
		(
			select string_agg(privilege_type, ', ' order by privilege_type) as rights
			from information_schema.role_column_grants r
			where table_schema = 'client_1'
				and (grantee = 'writer_all')
				and (privilege_type = 'INSERT' OR privilege_type = 'UPDATE' OR privilege_type = 'SELECT')
				and table_name = 'test'
				and column_name = 'value'
		) as t 
		where rights = 'INSERT, SELECT, UPDATE'
	)
	then
		raise exception 'Le rôle writer général n''a pas les droits sur la colonne value.';
	end if;

	if exists (
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'reader_client_1')
			and (privilege_type = 'INSERT' OR privilege_type = 'UPDATE')
			and table_name = 'test'
			and (column_name = 'value' OR column_name = 'test_id')
	)
	then
		raise exception 'Le rôle reader a des droits de modification';
	end if;

	if exists (
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'reader_all')
			and (privilege_type = 'INSERT' OR privilege_type = 'UPDATE')
			and table_name = 'test'
			and (column_name = 'value' OR column_name = 'test_id')
	)
	then
		raise exception 'Le rôle reader général a des droits de modification';
	end if;

	if not exists (
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'reader_client_1')
			and (privilege_type = 'SELECT')
			and table_name = 'test'
			and column_name = 'value'
	)
	then
		raise exception 'Le rôle reader n''a pas les droits en lecture sur la colonne value';
	end if;

	if not exists (
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'reader_all')
			and (privilege_type = 'SELECT')
			and table_name = 'test'
			and column_name = 'value'
	)
	then
		raise exception 'Le rôle reader général n''a pas les droits en lecture sur la colonne value';
	end if;
	
	if not exists (
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'reader_client_1')
			and (privilege_type = 'SELECT')
			and table_name = 'test'
			and column_name = 'test_id'
	)
	then
		raise exception 'Le rôle reader n''a pas les droits en lecture sur la colonne test_id';
	end if;
	
	if not exists (
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'reader_all')
			and (privilege_type = 'SELECT')
			and table_name = 'test'
			and column_name = 'test_id'
	)
	then
		raise exception 'Le rôle reader général n''a pas les droits en lecture sur la colonne test_id';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_roles_nom_3_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_roles_nom_3_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;