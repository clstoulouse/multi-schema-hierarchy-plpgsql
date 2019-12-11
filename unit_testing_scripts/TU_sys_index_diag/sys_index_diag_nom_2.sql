create or replace procedure unit_tests.sys_index_diag_nom_2()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 2 de la procédure 'sys_index_diag'
--		Ce test a pour but de :
/*
	Pré-requis :
	Insérer 1 000 000 lignes de valeurs aléatoires dans la table client_1.test	
	Créer une table test_2 (value varchar (100));
	Insérer 1 000 000 lignes de valeurs aléatoires dans la table client_1.test_2
	Reindexer client_1.test_2
	Insérer 10 000 lignes de valeurs aléatoires dans la table client_1.test_2
		
	Action :
	Lancer la procédure de sys_diag_index
	
	Résultat attendu :	
	Une ligne dans le résultat précise que l'index client_1.idx_test_client_1 a été REINDEXED
	Plus aucun index dans le schéma client_1 n'a d'index fragmenté à plus de 30%
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
	create index idx_test_2 on master.test_2 using btree (value);

	insert into client_1.test (value)
	select md5(random()::text) from generate_series(1, 1000000) s;

	insert into client_1.test_2 (value)
	select md5(random()::text) from generate_series(1, 1000000) s;
	reindex index client_1.idx_00001_00001;
	insert into client_1.test_2 (value)
	select md5(random()::text) from generate_series(1, 10000) s;

	-- Script action :
	select * into debug
	from common.sys_index_diag('client_1');
	
	CALL unit_tests.deblog('sys_index_diag_nom_2', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('sys_index_diag_nom_2', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;