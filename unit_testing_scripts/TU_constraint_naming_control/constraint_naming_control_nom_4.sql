create or replace procedure unit_tests.constraint_naming_control_nom_4()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 4 de la procédure 'constraint_naming_control'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 3 : Ok
	
	Action :
	Créer un nouveau client
	
	Résultat attendu :	
	Les clés étrangères suivantes sont créées sur la table client_1.test_3:
	- fk_00002_00001
	- fk_00003_00001
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			11/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	-- NA
	
	-- Action
	CALL common.create_new_client('client_1');
	
	CALL unit_tests.deblog('constraint_naming_control_nom_4', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('constraint_naming_control_nom_4', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;