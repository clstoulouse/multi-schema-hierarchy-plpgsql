create or replace procedure unit_tests.data_purge_err_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas erreur 1 de la procédure 'data_purge'
--		Ce test a pour but de :
/*
	Pré-requis :
	NA
	
	Action :
	Appeler la fonction de purge
	
	Résultat attendu :
	La table common.purge_tool_conf est créée.
	Erreur : 'Aucune table n'est configurée comme purgeable dans la table de purge.'
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			12/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	-- NA
	
	-- Action
	CALL common.data_purge();
	
	CALL unit_tests.deblog('data_purge_err_1', cast(0 as bit));	
		
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('data_purge_err_1', cast(1 as bit), CAST(SQLERRM as text));
end;
$procedure$;