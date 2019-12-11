create or replace procedure unit_tests.drop_cascade_pks_nom_3_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 3 de la procédure 'drop_cascade_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 2 : ok
	Créer une table test_3 (test_id int, test_id_2 varchar(5), value varchar (50)); 
	Créer une clé primaire composée sur master.test pourvu de test_id et test_id_2.
	Mettre des données selon la description suivante :
	client_1					client_2
	test_id	test_id_2	value	test_id	test_id_2	value
	1		'A'			'test'	5		'A'			'test'
	2		'A'			'test'	6		'B'			'test'
	3		'A'			'test'	7		'B'			'test'
	4		'B'			'test'		
	
	Action :
	Supprimer la clé primaire sur master.test.
	
	Résultat attendu :
	La clé primaire est supprimée sur master.
	La clé primaire est supprimée sur client_1.	
	La clé primaire est supprimée sur client_2.
	Aucune séquence n'est présente sur le schéma 'master'
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
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN information_schema.constraint_column_usage AS ccu
			  ON ccu.constraint_name = con.conname
			  AND ccu.table_schema = nsp.nspname
		WHERE nsp.nspname = 'master'
			and con.contype = 'p'
			and con.conname = 'pk_00003'
	)
	then 
		raise exception 'La clé primaire existe toujours dans le schéma master.';
	end if;
	
	if exists (	
		SELECT 1
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN information_schema.constraint_column_usage AS ccu
			  ON ccu.constraint_name = con.conname
			  AND ccu.table_schema = nsp.nspname
		WHERE nsp.nspname = 'client_1'
			and con.contype = 'p'
			and con.conname = 'pk_00003_00001'
	)
	then 
		raise exception 'La clé primaire existe toujours dans le schéma client_1.';
	end if;
	
	if exists (	
		SELECT 1
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN information_schema.constraint_column_usage AS ccu
			  ON ccu.constraint_name = con.conname
			  AND ccu.table_schema = nsp.nspname
		WHERE nsp.nspname = 'client_2'
			and con.contype = 'p'
			and con.conname = 'pk_00003_00002'
	)
	then 
		raise exception 'La clé primaire existe toujours dans le schéma client_2.';
	end if;
		
	if exists (
		select 1
		from information_schema."sequences"
		where sequence_schema = 'master'
			and sequence_name not in 
				('sq_master_pks_id'
				, 'sq_master_fks_id'
				, 'sq_master_idxs_id'
				, 'sq_master_idxus_id')
	)
	then 
		raise exception 'La séquence de l''ancienne clé primaire existe toujours.';
	end if;
	
	CALL unit_tests.deblog('drop_cascade_pks_nom_3_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_cascade_pks_nom_3_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;