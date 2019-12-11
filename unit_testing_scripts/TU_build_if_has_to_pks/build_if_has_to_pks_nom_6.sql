create or replace procedure unit_tests.build_if_has_to_pks_nom_6()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 6 de la procédure 'build_if_has_to_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 5 OK
		
	Action :
	Ajouter une ligne dans client_1.test
	Ajouter une ligne dans client_2.test
	Ajouter une ligne dans client_1.test
	
	Résultat attendu :
	La colonne id_test de client_1.test comporte une valeur : 1.
	La colonne id_test de client_2.test comporte une valeur : 2.
	La colonne id_test de client_1.test comporte deux valeurs : 1 et 3.
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			08/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	-- NA
	
	-- Action
	INSERT INTO client_1.test (value) VALUES ('test');
	INSERT INTO client_2.test (value) VALUES ('test');
	INSERT INTO client_1.test (value) VALUES ('test');
	
	CALL unit_tests.deblog('build_if_has_to_pks_nom_6', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_pks_nom_6', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;