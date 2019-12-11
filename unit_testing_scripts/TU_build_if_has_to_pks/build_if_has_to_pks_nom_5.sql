create or replace procedure unit_tests.build_if_has_to_pks_nom_5()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 5 de la procédure 'build_if_has_to_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 4 OK
		
	Action :
	Ajouter un nouveau client.
	
	Résultat attendu :
	La clé multicolonne est répercutée sur le nouveau client dans la table client_2.test_3.
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			08/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	-- NA
	
	-- Action
	CALL common.create_new_client('client_2');
	
	CALL unit_tests.deblog('build_if_has_to_pks_nom_5', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_pks_nom_5', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;