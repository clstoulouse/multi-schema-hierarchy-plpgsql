create or replace procedure unit_tests.build_if_has_to_pks_nom_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Une table est présente dans le schéma 'master' sans clé primaire.
	
	Action :
	Ajout d'une colonne de type 'int' ayant pour nom 'id_test'.
	Ajout d'une clé primaire sur la colonne créée portant pour nom : 'pk_ttt'
	
	Résultat attendu :
	Une clé primaire est bien référencée sur la colonne crée.
	Cette clé primaire porte le nom 'pk_00001'.
*/
-- Partie results		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			08/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	if not exists (
		select 1
		from
		(
			select
				con.conname
				, nsp.nspname
				, rel.relname as table_name
				, string_agg(ccu.column_name, ' ,' order by ccu.column_name) as ref_columns
			FROM pg_catalog.pg_constraint con
				INNER JOIN pg_catalog.pg_class rel
					ON rel.oid = con.conrelid
				INNER JOIN pg_catalog.pg_namespace nsp
					ON nsp.oid = connamespace
				INNER JOIN information_schema.constraint_column_usage AS ccu
				  ON ccu.constraint_name = con.conname
				  AND ccu.table_schema = nsp.nspname
			WHERE con.contype = 'p'
			GROUP BY nsp.nspname, rel.relname, con.conname
		) as t 
		where nspname = 'master'
			and table_name = 'test'
			and ref_columns = 'id_test'
			and conname = 'pk_00001'
	)
	then
		raise exception 'La clé primaire n''est pas créée sur le schéma ''master''';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_pks_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_pks_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;