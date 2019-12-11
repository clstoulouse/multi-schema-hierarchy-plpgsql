create or replace procedure unit_tests.drop_client_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'drop_client'
--		Ce test a pour but de :
/*
	Pré-requis :
	Créer un schéma client : 'client_66'
		
	Action :
	Supprimer le client_66
	
	Résultat attendu :	
	Le schéma client_66 n'existe plus
	Le client n'est plus dans la table common.dwh_dm_client
	Le rôle writer_client_66 n'existe plus
	Le rôle reader_client_66 n'existe plus
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			16/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin	
	-- Script pré-requis :	
	CALL common.create_new_client('client_66');
	
	-- Script action :
	CALL common.drop_client('client_66');
	
	CALL unit_tests.deblog('drop_client_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_client_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;