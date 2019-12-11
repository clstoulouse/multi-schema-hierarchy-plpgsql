create or replace procedure unit_tests.build_if_has_to_roles_err_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas d'erreur 1 de la procédure 'build_if_has_to_roles'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 3 : OK
	Créer un nouveau client 'client_2'
	Avoir en base les données suivantes sur la table client_2.test :
	test_id		value
	1			'test'
	2			'test'
	3			'test'
	
	Action :
	Définir le rôle de session comme étant celui de writer_client_1.
	Modifier la ligne ayant pour client_2.test.test_id 3.
	
	Résultat attendu : 
	Échec de la modification par manque de droits.
*/
-- PARTIE PREREQUIS	
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			09/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisit 
	-- NA

	-- Action	
	SET ROLE writer_client_1;
	UPDATE client_2.test SET value = 'test_zzz' where test_id = 3;			
	
	CALL unit_tests.deblog('build_if_has_to_roles_err_1', cast(0 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_roles_err_1', cast(1 as bit), CAST(SQLERRM as text));
end;
$procedure$;