create or replace procedure unit_tests.build_if_has_to_sqs_nom_2()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 2 de la procédure 'build_if_has_to_sqs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 1 : ok
	Création de la table 'test_2' {test_2_id int, value varchar (50)}
	
	Action :
	Création de la clé primaire sur la colonne master.test_2.test_id
	
	Résultat attendu :
	Une séquence 'sq_pk_test_2' a été crée sur master.
	La colonne client_1.test_2.test_2_id suit la séquence 'sq_test_2_id'.
	La colonne client_2.test_2.test_2_id suit la séquence 'sq_test_2_id'.
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
	CREATE TABLE master.test_2 (test_2_id int, value varchar(50));
	
	-- Action
	ALTER TABLE master.test_2
	ADD CONSTRAINT pk_ttt PRIMARY KEY (test_2_id);
	
	CALL unit_tests.deblog('build_if_has_to_sqs_nom_2', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_sqs_nom_2', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;