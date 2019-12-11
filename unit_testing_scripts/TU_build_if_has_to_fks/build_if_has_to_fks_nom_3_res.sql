create or replace procedure unit_tests.build_if_has_to_fks_nom_3_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 3 de la procédure 'build_if_has_to_fks'
--		Ce test a pour but de :
/*
	Pré-requis : 
	Cas nominal 2 OK
	
	Action :
	Un client nouveau est créé.
	
	Résultats attendus:
	Un nouveau schéma est créé 'client_2'.
	Ce nouveau schéma comporte les trois tables : test_1, test_2 et test_3.
	La clé étrangère fk_00002_00002 est présente sur client_2.test_3 et référence client_2.test_2.id_test_2
*/
-- PARTIE result	
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			05/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin		
	-- Restult test script
	if not exists (
		select 1
		from information_schema.schemata
		where schema_name = 'client_2'
			and schema_name not like 'pg_toast%'
			and schema_name not like 'pg_temp%')
	then 
		raise exception 'Le nouveau schéma n''a pas été créé.';
	end if;
	
	if not exists (
		SELECT 1 
		FROM common.dwh_dm_client 
		WHERE client_waste_nom = 'client_2')
	then 
		raise exception 'Le nouveau client n''a pas son nom dans la table de configuration common.dwh_dm_client';
	end if;
	
	if not exists (select 1 FROM information_schema.tables where table_name = 'test_1' and table_schema = 'client_2')
		and not exists (select 1 FROM information_schema.tables	where table_name = 'test_2' and table_schema = 'client_2')
		and not exists (select 1 FROM information_schema.tables	where table_name = 'test_3' and table_schema = 'client_2')
	then
		raise exception 'Une des tables devant normalement être présente ne l''est pas.';
	end if;
	
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
		where con.conname = 'fk_00002_00002'
			and t.table_name = 'test_3'
			and t.table_schema = 'client_2')
	then
		raise exception 'La clé étrangère ''fk_00002_00002'' n''est pas défini correctement.';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_fks_nom_3_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_fks_nom_3_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;