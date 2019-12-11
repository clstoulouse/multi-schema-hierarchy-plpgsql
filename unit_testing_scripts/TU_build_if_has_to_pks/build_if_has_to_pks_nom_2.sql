create or replace procedure unit_tests.build_if_has_to_pks_nom_2()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 2 de la procédure 'build_if_has_to_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 1 OK	
	
	Action :
	Un nouveau client est créé 'client_1'
	
	Résultat attendu :
	La table client_1.test a pour clé primaire : pk_00001_00001.
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
	CALL common.create_new_client('client_1');
	
	CALL unit_tests.deblog('build_if_has_to_pks_nom_2', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_pks_nom_2', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;