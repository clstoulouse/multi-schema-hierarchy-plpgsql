create or replace procedure unit_tests.build_if_has_to_sqs_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_sqs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Le système possède deux clients 'client_1' et 'client_2'
	
	Action :
	Création d'une table 'test' {test_id int primary key, value varchar(50)}
	
	Résultat attendu :
	Une séquence a été créée sur le schéma master et porte le nom 'sq_pk_test'.
	La colonne client_1.test.test_id suit la séquence 'sq_pk_test'.
	La colonne client_2.test.test_id suit la séquence 'sq_pk_test'.
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
	CALL common.create_new_client('client_1');
	CALL common.create_new_client('client_2');
	
	-- Action
	CREATE TABLE master.test (test_id int primary key, value varchar (50));
	
	CALL unit_tests.deblog('build_if_has_to_sqs_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_sqs_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;