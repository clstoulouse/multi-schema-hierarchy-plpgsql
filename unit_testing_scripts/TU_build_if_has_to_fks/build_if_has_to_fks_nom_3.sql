create or replace procedure unit_tests.build_if_has_to_fks_nom_3()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 3 de la procédure 'build_if_has_to_fks'
--		Ce test a pour but de :
/*
	Pré-requis : 
	Cas nominal 2 OK
	
	Action :
	Un client nouveau est créé.
	
	Résultats attendus:
	Un nouveau schéma est créé 'client_2'.
	Ce nouveau schéma comporte les trois tables : test_1, test_2 et test_3.
	La clé étrangère fk_00002_00002 est présente sur client_2.test_3 et référence client_2.test_2.id_test_2
*/
-- PARTIE PREREQUIS	
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			05/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisit 
	-- NA

	-- Action	
	CALL common.create_new_client('client_2');
			
	
	CALL unit_tests.deblog('build_if_has_to_fks_nom_3', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_fks_nom_3', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;