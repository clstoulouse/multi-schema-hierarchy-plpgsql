create or replace procedure unit_tests.drop_cascade_pks_nom_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'drop_cascade_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Créer une table test (test_id int primary key, value varchar (50));
	
	Action :
	Supprimer la clé primaire.
	
	Résultat attendu :
	La clé primaire est supprimée.
	La séquence est supprimée.
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
			and con.conname = 'pk_00001'
	)
	then 
		raise exception 'La clé primaire existe toujours dans le schéma master.';
	end if;
		
	if exists (
		select 1
		from information_schema."sequences"
		where sequence_schema = 'master'
			and sequence_name = 'sq_pk_00001'

	)
	then 
		raise exception 'La séquence de l''ancienne clé primaire existe toujours.';
	end if;
	
	CALL unit_tests.deblog('drop_cascade_pks_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_cascade_pks_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;