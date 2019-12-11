create or replace procedure unit_tests.build_if_has_to_pks_nom_5_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 5 de la procédure 'build_if_has_to_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 4 OK
		
	Action :
	Ajouter un nouveau client.
	
	Résultat attendu :
	La clé multicolonne est répercutée sur le nouveau client dans la table client_2.test_3.
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
				AND rel.relname IN 
				(
					SELECT table_name
					FROM information_schema.tables
					WHERE table_schema = 'master'
				)
			GROUP BY nsp.nspname, rel.relname, con.conname
		) as t 
		where nspname = 'client_2'
			and table_name = 'test_3'
			and ref_columns = 'test_code ,test_id'
			and conname = 'pk_00003_00002'
	)
	then
		raise exception 'La clé primaire n''est pas créée sur le schéma ''client_2'' ou bien est mal nommée.';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_pks_nom_5_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_pks_nom_5_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;