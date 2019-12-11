create or replace procedure unit_tests.build_if_has_to_sqs_nom_6()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 6 de la procédure 'build_if_has_to_sqs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 5 : OK
		
	Action :
	Supprimer la contrainte de clé primaire pk_test sur master.test
	
	Résultat attendu :
	La clé primaire a été supprimée sur les tables :
	- master.test
	- client_1.test
	- client_2.test
	La séquence sq_pk_test a été supprimée
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
	ALTER TABLE master.test
	DROP CONSTRAINT pk_00001 CASCADE;
	
	CALL unit_tests.deblog('build_if_has_to_sqs_nom_6', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_sqs_nom_6', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;