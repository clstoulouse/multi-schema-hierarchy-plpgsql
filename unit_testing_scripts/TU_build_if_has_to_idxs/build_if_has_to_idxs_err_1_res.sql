create or replace procedure unit_tests.build_if_has_to_idxs_err_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas d'erreur 1 de la procédure 'build_if_has_to_idxs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 3 OK
	Obtenir les jeux de données suivants dans client_1
	test
	id		value		code
	1		'test'		'AAA'
	2		'test'		'BBB'
	3		'test'		'CCC'
	4		'test'		'CCC'
	
	Action :
	Ajouter un index unique sur la colonne master.test.code
	
	Résultat attendu :
	L'index n'est pas créé sur la table master.test
	Lindex n'est pas créé sur la table client_1.test
*/
-- PARTIE Result	
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			05/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	if exists (
		select 1
		FROM pg_index AS idx
			INNER JOIN pg_class AS i
				ON i.oid = idx.indexrelid
			INNER JOIN pg_namespace AS ns
				ON ns.oid = i.relnamespace
			INNER JOIN pg_class AS t
				ON t.oid = idx.indrelid
				AND t.relkind = 'r'
		WHERE ns.nspname = 'master'
			AND t.relname = 'test'
			and i.relname = 'idxu_ttt'
			AND idx.indisprimary = false
	)
	then
		raise exception 'L''index est présent sur le schéma ''master''';
	end if;
	
	if exists (
		select 1
		FROM pg_index AS idx
			INNER JOIN pg_class AS i
				ON i.oid = idx.indexrelid
			INNER JOIN pg_namespace AS ns
				ON ns.oid = i.relnamespace
			INNER JOIN pg_class AS t
				ON t.oid = idx.indrelid
				AND t.relkind = 'r'
		WHERE ns.nspname = 'client_1'
			AND t.relname = 'test'
			and i.relname = 'idxu_ttt'
			AND idx.indisprimary = false
	)
	then
		raise exception 'L''index est présent sur le schéma ''client_1''';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_idxs_err_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_idxs_err_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;