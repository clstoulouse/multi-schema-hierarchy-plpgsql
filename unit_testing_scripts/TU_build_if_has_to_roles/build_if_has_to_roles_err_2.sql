create or replace procedure unit_tests.build_if_has_to_roles_err_2()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas d'erreur 2 de la procédure 'build_if_has_to_roles'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas erreur 1 : OK
	
	Action :
	Définir le rôle de session comme étant celui de writer_client_1.
	Afficher les données de la table client_2.test;
	
	Résultat attendu : 
	Échec de la consultation par manque de droits.
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
	SELECT * FROM client_2.test;
	
	CALL unit_tests.deblog('build_if_has_to_roles_err_2', cast(0 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_roles_err_2', cast(1 as bit), CAST(SQLERRM as text));
end;
$procedure$;