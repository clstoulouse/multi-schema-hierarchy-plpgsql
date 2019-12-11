create or replace procedure unit_tests.drop_client_err_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas d'erreur 1 de la procédure 'drop_client'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 1 : ok
		
	Action :
	Supprimer le client_66
	
	Résultat attendu :	
	Erreur : Le client spécifié n'existe pas
*/
-- PARTIE PREREQUIS	
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			16/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisit 
	-- NA

	-- Action	
	CALL common.drop_client('client_66');
			
	
	CALL unit_tests.deblog('drop_client_err_1', cast(0 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_client_err_1', cast(1 as bit), CAST(SQLERRM as text));
end;
$procedure$;