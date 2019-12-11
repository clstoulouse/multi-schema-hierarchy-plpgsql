create or replace procedure unit_tests.build_if_has_to_sqs_nom_4()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 4 de la procédure 'build_if_has_to_sqs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 3 : OK
	
	Action :
	Supprimer la colonne master.test_2.test_2_id
	
	Résultat attendu :
	La colonne est supprimée sur les tables :
	- master.test_2
	- client_1.test_2
	- client_2.test_2
	La séquence 'sq_pk_test_2' est supprimée.
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			09/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	-- NA
	
	-- Action	
	ALTER TABLE master.test_2
	DROP COLUMN test_2_id CASCADE;
	
	CALL unit_tests.deblog('build_if_has_to_sqs_nom_4', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_sqs_nom_4', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;