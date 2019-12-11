create or replace procedure unit_tests.delete_indexes_on_cascade_nom_3()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 3 de la procédure 'delete_indexes_on_cascade'
--		Ce test a pour but de :
/*
	Pré-requis :
	Créer un nouveau client : 'client_1'
	Créer un nouveau client : 'client_2'
	Créer un index sur la colonne master.test.value	
	
	Action :
	Supprimer l'index master.test.value
	
	Résultat attendu :
	L'index est bien supprimé dans la table master.test
	L'index est bien supprimé dans la table client_1.test
	L'index est bien supprimé dans la table client_2.test
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin		
	-- Script pré-requis :	
	CALL common.create_new_client('client_2');
	CREATE INDEX idx_test_value ON master.test USING BTREE (value);
	
	-- Script action :
	DROP INDEX master.idx_00003 CASCADE;
	
	CALL unit_tests.deblog('delete_indexes_on_cascade_nom_3', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('delete_indexes_on_cascade_nom_3', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;