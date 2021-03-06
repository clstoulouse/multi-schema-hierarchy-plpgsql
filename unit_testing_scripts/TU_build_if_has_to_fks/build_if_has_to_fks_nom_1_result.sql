create or replace procedure unit_tests.build_if_has_to_fks_nom_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_fks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Deux tables sont présentes dans le schéma 'master'.
	Un client est présent.
	
	Action :
	Une des tables est référencée par une clé étrangère dans l'autre table.
	
	Résultat attendu :
	La clé étrangère dans le schéma master porte le nom suivant : 'fk_00001'.
	Une clé étrangère est présente dans la table client_1.test_2. Cette clé étrangère porte le nom : 
	fk_00001_00001
*/
-- PARTIE RESULTAT
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			04/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Restult test script
	-- La clé étrangère dans le schéma master sur la table test_2 porte le nom suivant : 'fk_00001'.
	if not exists (
		select 1
		FROM pg_catalog.pg_constraint con
			inner join pg_catalog.pg_class rel
				on rel.oid = con.conrelid
			inner join pg_catalog.pg_namespace nsp							
				ON nsp.oid = con.connamespace
			inner join information_schema.tables t
				on t.table_schema = nsp.nspname
				and t.table_name = rel.relname
		where con.conname = 'fk_00001'
			and t.table_name = 'test_2'
			and t.table_schema = 'master')
	then 
		raise exception 'La clé étrangère ne porte pas le bon nom sur le schéma master.';
	end if;
		
	-- Une clé étrangère est présente dans la table client_1.test_2. Cette clé étrangère porte le nom : 'fk_00001_00001'
	if not exists (
		select 1
		FROM pg_catalog.pg_constraint con
			inner join pg_catalog.pg_class rel
				on rel.oid = con.conrelid
			inner join pg_catalog.pg_namespace nsp							
				ON nsp.oid = con.connamespace
			inner join information_schema.tables t
				on t.table_schema = nsp.nspname
				and t.table_name = rel.relname
		where con.conname = 'fk_00001_00001'
			and t.table_name = 'test_2'
			and t.table_schema = 'client_1')
	then 
		raise exception 'La clé étrangère ne porte pas le bon nom sur le schéma client.';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_fks_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_fks_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;