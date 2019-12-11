create or replace procedure unit_tests.build_if_has_to_tables_nom_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_tables'
--		Ce test a pour but de :
/*
	Pré-requis :
	Créer un client 'client_1'
	
	Action :
	Créer une table 'test' {test_id varchar(5) primary key, value varchar (50)}
	
	Résultat attendu :	
	Une table a été créée dans le schéma 'client_1'
	Le rôle writer_client_1 a été créé.
	Le rôle reader_client_1 a été créé.
	Le rôle writer_client_1 dispose des droits SELECT sur la table client_1.test
	Le rôle reader_client_1 dispose des droits SELECT sur la table client_1.test
	Le rôle writer_client_1 dispose des droits DELETE sur la table client_1.test
	Le rôle writer_client_1 dispose des droits UPDATE et INSERT sur toutes les colonnes de la table client_1.test
*/
-- Partie results		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			10/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	if not exists (
		select 1
		from information_schema.tables
		where table_schema = 'client_1'
			and table_name = 'test'
	)
	then
		raise exception 'La table n''a pas été créée sur le schéma client_1.';
	end if;
	
	if not exists (
		select 1
		from pg_roles
		where rolname = 'writer_client_1'
	)
	then 
		raise exception 'Le rôle writer_client_1 n''existe pas';
	end if;
	
	if not exists (
		select 1
		from pg_roles
		where rolname = 'reader_client_1'
	)
	then 
		raise exception 'Le rôle reader_client_1 n''existe pas';
	end if;
	
	if not exists (
		select 1
		from information_schema.role_table_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_client_1')
			and privilege_type = 'SELECT'
			and table_name = 'test'
	)
	then
		raise exception 'Le rôle writer n''a pas le droit de selection sur la table test';
	end if;
	
	if not exists (
		select 1
		from information_schema.role_table_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_all')
			and privilege_type = 'SELECT'
			and table_name = 'test'
	)
	then
		raise exception 'Le rôle writer général n''a pas le droit de selection sur la table test';
	end if;
	
	if not exists (
		select 1
		from pg_roles
		where rolname = 'reader_client_1'
	)
	then 
		raise exception 'Le rôle reader_client_1 n''existe pas';
	end if;
	
	if not exists (
		select 1
		from information_schema.role_table_grants r
		where table_schema = 'client_1'
			and (grantee = 'reader_client_1')
			and privilege_type = 'SELECT'
			and table_name = 'test'
	)
	then
		raise exception 'Le rôle reader n''a pas le droit de selection sur la table test';
	end if;
	
	if not exists (
		select 1
		from information_schema.role_table_grants r
		where table_schema = 'client_1'
			and (grantee = 'reader_all')
			and privilege_type = 'SELECT'
			and table_name = 'test'
	)
	then
		raise exception 'Le rôle reader général n''a pas le droit de selection sur la table test';
	end if;
	
	if not exists (
		select 1
		from information_schema.role_table_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_client_1')
			and privilege_type = 'DELETE'
			and table_name = 'test'
	)
	then
		raise exception 'Le rôle writer n''a pas le droit de suppression sur la table test';
	end if;
	
	if not exists (
		select 1
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_client_1')
			and (privilege_type = 'UPDATE' OR privilege_type = 'INSERT' )
			and table_name = 'test'
			and column_name = 'value'
	)
	then
		raise exception 'Le rôle writer n''a pas le droit d''insertion ou de modification sur la colonne value.';
	end if;
	
	if not exists (
		select 1
		from information_schema.role_table_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_all')
			and privilege_type = 'DELETE'
			and table_name = 'test'
	)
	then
		raise exception 'Le rôle writer général n''a pas le droit de suppression sur la table test';
	end if;
	
	if not exists (
		select 1
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_all')
			and (privilege_type = 'UPDATE' OR privilege_type = 'INSERT' )
			and table_name = 'test'
			and column_name = 'test_id'
	)
	then
		raise exception 'Le rôle writer général n''a pas le droit d''insertion ou de modification sur la colonne test_id.';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_tables_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_tables_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;