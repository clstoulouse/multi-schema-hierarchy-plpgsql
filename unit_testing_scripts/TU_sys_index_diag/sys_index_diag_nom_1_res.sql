create or replace procedure unit_tests.sys_index_diag_nom_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'sys_index_diag'
--		Ce test a pour but de :
/*
	Pré-requis :
	Créer un client client_66
	Créer une table test (value varchar (100));
	Créer un index BTREE sur la colonne client_1.test.value
		
	Action :
	Lancer la procédure de sys_diag_index	
	
	Résultat attendu :	
	L'index client_1.idx_test_client_1 est annoncé comme pouvant être probablement supprimé.
*/
-- PARTIE RESULTAT
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			16/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Restult test script
	if not exists (
		select 1
		FROM common.index_script_results
		where schema_name = 'client_1'
			and table_name = 'test'
			and index_name = 'idx_00001_00001'
			and status = 'HAS TO BE DELETED ?')
	then 
		raise exception 'Un index supposé vide n''est pas indiqué comme supprimable. (idx_test_client_1)';
	end if;
	
	CALL unit_tests.deblog('sys_index_diag_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('sys_index_diag_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;