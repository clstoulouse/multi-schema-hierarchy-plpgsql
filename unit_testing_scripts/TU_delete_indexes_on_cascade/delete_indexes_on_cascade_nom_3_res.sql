create or replace procedure unit_tests.delete_indexes_on_cascade_nom_3_res()
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
-- PARTIE RESULTAT
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	if exists (
		SELECT 1
		FROM pg_index AS idx
			INNER JOIN pg_class AS i
				ON i.oid = idx.indexrelid
			INNER JOIN pg_namespace AS ns
				ON ns.oid = i.relnamespace
			INNER JOIN pg_class AS t
				ON t.oid = idx.indrelid
				AND t.relkind = 'r'
		WHERE ns.nspname = 'master'
			AND idx.indisprimary = false
			AND i.relname = 'idx_00003')
	then 
		raise exception 'L''index est toujours présent dans la table master.test.';
	end if;
	
	if exists (
		SELECT 1
		FROM pg_index AS idx
			INNER JOIN pg_class AS i
				ON i.oid = idx.indexrelid
			INNER JOIN pg_namespace AS ns
				ON ns.oid = i.relnamespace
			INNER JOIN pg_class AS t
				ON t.oid = idx.indrelid
				AND t.relkind = 'r'
		WHERE ns.nspname = 'client_1'
			AND idx.indisprimary = false
			AND i.relname = 'idx_00003_00002')
	then 
		raise exception 'L''index est toujours présent dans la table client_1.test.';
	end if;
	
	if exists (
		SELECT 1
		FROM pg_index AS idx
			INNER JOIN pg_class AS i
				ON i.oid = idx.indexrelid
			INNER JOIN pg_namespace AS ns
				ON ns.oid = i.relnamespace
			INNER JOIN pg_class AS t
				ON t.oid = idx.indrelid
				AND t.relkind = 'r'
		WHERE ns.nspname = 'client_1'
			AND idx.indisprimary = false
			AND i.relname = 'idx_test_value')
	then 
		raise exception 'L''index est toujours présent dans la table client_2.test.';
	end if;
	
	CALL unit_tests.deblog('delete_indexes_on_cascade_nom_3_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('delete_indexes_on_cascade_nom_3_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;