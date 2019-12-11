create or replace procedure unit_tests.build_if_has_to_tables_nom_2_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 2 de la procédure 'build_if_has_to_tables'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 1 : OK
	
	Action :
	Créer une table test_2 {test_id int primary key, value varchar(50)}
	
	Résultat attendu :	
	Le rôle writer_client_1 n'a pas les droits UPDATE et INSERT sur la colonne client_1.test.test_id
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
	if exists (
		select 1
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_client_1')
			and (privilege_type = 'UPDATE' OR privilege_type = 'INSERT' )
			and table_name = 'test_2'
			and column_name = 'test_id'
	)
	then
		raise exception 'Le rôle writer a le droit d''insertion ou de modification sur la colonne test_id alors que celle-ci est automatisée.';
	end if;
	
	if exists (
		select 1
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_all')
			and (privilege_type = 'UPDATE' OR privilege_type = 'INSERT' )
			and table_name = 'test_2'
			and column_name = 'test_id'
	)
	then
		raise exception 'Le rôle writer général a le droit d''insertion ou de modification sur la colonne test_id alors que celle-ci est automatisée.';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_tables_nom_2_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_tables_nom_2_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;