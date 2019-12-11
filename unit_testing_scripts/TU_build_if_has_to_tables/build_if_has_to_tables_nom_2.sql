create or replace procedure unit_tests.build_if_has_to_tables_nom_2()
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
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			10/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	-- NA
	
	-- Action
	CREATE TABLE master.test_2 (test_id int primary key, value varchar(50));
	
	CALL unit_tests.deblog('build_if_has_to_tables_nom_2', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_tables_nom_2', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;