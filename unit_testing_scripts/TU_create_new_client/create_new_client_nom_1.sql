create or replace procedure unit_tests.create_new_client_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'create_new_client_nom_1'
--		Ce test a pour but de :
/*
	Pré-requis :
	NA
	
	Action :
	Créer un nouveau client
	
	Résultat attendu :
	Une ligne supplémentaire est créé dans la table 'common.dwh_dm_client'
	Le schéma est créé
	Le rôle reader associé existe
	Le rôle writer associé existe	
	Les deux rôles ont le droit USAGE sur le schéma créé
	Les deux rôles ont search_path le nom du nouveau schéma
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
	-- Prerequisit 
	-- NA

	-- Action
	CALL common.create_new_client('client_1');
	
	CALL unit_tests.deblog('create_new_client_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('create_new_client_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;