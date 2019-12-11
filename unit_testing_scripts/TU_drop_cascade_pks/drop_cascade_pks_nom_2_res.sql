create or replace procedure unit_tests.drop_cascade_pks_nom_2_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 2 de la procédure 'drop_cascade_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 1 : ok
	Créer les nouveaux clients client_1 et client_2
	Créer une table test_2 (test_id int primary key, value varchar (50));
	Mettre des données selon la description suivante :
	client_1			client_2
	test_id	value		test_id	value
	1		'test'		5		'test'
	2		'test'		6		'test'
	3		'test'		7		'test'
	4		'test'			
	
	Action :
	Supprimer la clé primaire sur master.test.
	
	Résultat attendu :
	La clé primaire est supprimée sur master.
	La clé primaire est supprimée sur client_1.	
	La clé primaire est supprimée sur client_2.
	La séquence sq_pk_test est supprimée
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
			and con.conname = 'pk_00002'
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
			and con.conname = 'pk_00002_00001'
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
			and con.conname = 'pk_00002_00002'
	)
	then 
		raise exception 'La clé primaire existe toujours dans le schéma client_2.';
	end if;
		
	if exists (
		select 1
		from information_schema."sequences"
		where sequence_schema = 'master'
			and sequence_name = 'sq_pk_00002'
	)
	then 
		raise exception 'La séquence de l''ancienne clé primaire existe toujours.';
	end if;
	
	CALL unit_tests.deblog('drop_cascade_pks_nom_2_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_cascade_pks_nom_2_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;