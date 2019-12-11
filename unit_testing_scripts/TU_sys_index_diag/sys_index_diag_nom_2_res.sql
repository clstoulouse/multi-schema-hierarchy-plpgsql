create or replace procedure unit_tests.sys_index_diag_nom_2_res()
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
			and table_name = 'test_2'
			and index_name = 'idx_00002_00001'
			and status = 'REINDEXED')
	then 
		raise exception 'Aucun index n''a été réindexé.';
	end if;
	
	if exists (
		SELECT 1
		FROM pg_class C
			INNER JOIN pg_namespace N ON (N.oid = C.relnamespace) 
			INNER JOIN pg_index i ON i.indexrelid = c.oid
			INNER JOIN pg_class t on t.oid = i.indrelid
			,master.PGSTATINDEX(c.oid) AS r
		WHERE 
			nspname NOT IN ('pg_catalog', 'information_schema') 
			AND nspname !~ '^pg_toast' 
			AND C.relkind IN ('i')
			AND i.indisprimary = false
			AND leaf_fragmentation > 30
			AND leaf_fragmentation <> 'NaN')
	then 
		raise exception 'Un index reste à réindexer.';
	end if;
	
	CALL unit_tests.deblog('sys_index_diag_nom_2_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('sys_index_diag_nom_2_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;