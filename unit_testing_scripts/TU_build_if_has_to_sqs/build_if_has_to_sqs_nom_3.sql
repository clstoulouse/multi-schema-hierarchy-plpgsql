create or replace procedure unit_tests.build_if_has_to_sqs_nom_3()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 3 de la procédure 'build_if_has_to_sqs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 2 : ok
	
	Action :
	Insérer une donnée dans client_1.test
	Insérer une donnée dans client_2.test
	Insérer une donnée dans client_2.test
	Insérer une donnée dans client_1.test
	
	Résultat attendu :
	client_1.test
	test_id		value
	1			'test'
	4			'test'
	
	client_2.test
	test_id		value
	2			'test'
	3			'test'
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
	INSERT INTO client_1.test (value) VALUES ('test');
	INSERT INTO client_2.test (value) VALUES ('test'), ('test');
	INSERT INTO client_1.test (value) VALUES ('test');
	
	CALL unit_tests.deblog('build_if_has_to_sqs_nom_3', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_sqs_nom_3', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;