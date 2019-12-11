create or replace procedure unit_tests.build_if_has_to_sqs_nom_7()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 7 de la procédure 'build_if_has_to_sqs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 6 : OK
		
	Action :
	Créer une nouvelle table pourvue d'une clé primaire int 'test_3' {test_id int primary key, value varchar(50)}
	
	Résultat attendu :
	La nouvelle table est créée dans client_1 et client_2
	Les rôles writer_client_1 et writer_client_2 ont les droits USAGE sur la séquence 'sq_pk_test_3'
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
	CREATE TABLE master.test_3 (test_id int primary key, value varchar(50));
	
	CALL unit_tests.deblog('build_if_has_to_sqs_nom_7', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_sqs_nom_7', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;