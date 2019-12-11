create or replace procedure unit_tests.sys_index_diag_nom_1()
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
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			16/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
declare 
	debug record;
begin	
	-- Script pré-requis :	
	call common.create_new_client('client_1');
	create table master.test (value varchar (100));
	create table master.test_2 (value varchar (100));
	create index idx_test on master.test using btree (value);
	
	-- Script action :
	select * into debug
	from common.sys_index_diag('client_1');
	
	CALL unit_tests.deblog('sys_index_diag_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('sys_index_diag_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;