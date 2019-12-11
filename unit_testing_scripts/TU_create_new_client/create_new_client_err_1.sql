create or replace procedure unit_tests.create_new_client_err_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas d'erreur 1 de la procédure 'create_new_client'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 1 : OK
	
	Action :
	Créer un client portant le même nom que le précédemment créé.
	
	Résultat attendu :
	Erreur : This client alreday exist
*/
-- PARTIE PREREQUIS	
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			12/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisit 
	-- NA

	-- Action	
	CALL common.create_new_client('client_1');				
	
	CALL unit_tests.deblog('create_new_client_err_1', cast(0 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('create_new_client_err_1', cast(1 as bit), CAST(SQLERRM as text));
end;
$procedure$;