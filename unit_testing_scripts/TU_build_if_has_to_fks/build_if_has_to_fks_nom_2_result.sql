create or replace procedure unit_tests.build_if_has_to_fks_nom_2_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 2 de la procédure 'build_if_has_to_fks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 1 OK
	Une table est ajoutée dans le schéma 'master'.
	
	Action :
	La clé étrangère du cas nominal 1 est supprimée.
	Une nouvelle clé étrangère est créée entre la nouvelle table et une ancienne table.
	
	Résultats attendus :
	La clé étrangère fk_00001 n'existe plus sur le schéma master.
	La clé étrangère fk_00001_00001 n'existe plus.
	La clé étrangère fk_00002 a été créée sur master.test_3.
	La clé étrangère fk_00002_00001 a été créée sur client_1.test_3.
*/
-- PARTIE result	
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
	-- La clé étrangère dans le schéma master sur la table test_2 portant le nom suivant : 'fk_00001' n'existe plus
	if exists (
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
		raise exception 'La clé étrangère n''a pas été supprimée du schéma ''master''';
	end if;
		
	-- La clé étrangère dans le schéma client_1 sur la table test_2 portant le nom suivant : 'fk_00001_00001' n'existe plus
	if exists (
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
		raise exception 'La clé étrangère n''a pas été supprimée du schéma ''client_1''';
	end if;
	
	-- Une clé étrangère est présente dans la table master.test_3. Cette clé étrangère porte le nom : fk_00002
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
		where con.conname = 'fk_00002'
			and t.table_name = 'test_3'
			and t.table_schema = 'master')
	then 
		raise exception 'La clé étrangère n''existe pas ou ne porte pas le bon nom sur le schéma master.';
	end if;

	-- Une clé étrangère est présente dans la table client_1.test_3. Cette clé étrangère porte le nom : fk_00002_00001
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
		where con.conname = 'fk_00002_00001'
			and t.table_name = 'test_3'
			and t.table_schema = 'client_1')
	then 
		raise exception 'La clé étrangère n''existe pas ou ne porte pas le bon nom sur le schéma client.';
	end if;			
	
	CALL unit_tests.deblog('build_if_has_to_fks_nom_2_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_fks_nom_2_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;