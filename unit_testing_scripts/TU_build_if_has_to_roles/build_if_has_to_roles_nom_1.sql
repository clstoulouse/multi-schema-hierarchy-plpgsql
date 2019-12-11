create or replace procedure unit_tests.build_if_has_to_roles_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_roles'
--		Ce test a pour but de :
/*
	Pré-requis :
	Une table dans le schéma master
	
	Action :
	Créer un nouveau client 'client_1'
	
	Résultat attendu :
	Deux nouveau rôles sont créés : reader_client_1 et writer_client_1
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			08/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	CREATE TABLE master.test (value varchar(25));
	
	-- Action
	CALL common.create_new_client('client_1');
	
	CALL unit_tests.deblog('build_if_has_to_roles_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_roles_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;