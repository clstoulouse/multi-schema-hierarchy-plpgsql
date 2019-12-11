create or replace procedure unit_tests.build_if_has_to_idxs_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_idxs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Une table est présente dans le schéma 'master'.
	Un client est présent.
	
	Action :
	Bâtir un index non unique sur la colonne master.test.value.
	
	Résultat attendu :
	L'index idx_00001 est présent sur la table master.test
	L'index idx_00001_00001 est présent sur le table client_1.test
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			05/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	CALL common.create_new_client('client_1');
	CREATE TABLE master.test (id_test_1 int primary key, value varchar(50), code varchar(5));
	
	-- Action
	CREATE INDEX idx_ttt ON master.test (value);
	
	CALL unit_tests.deblog('build_if_has_to_idxs_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_idxs_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;