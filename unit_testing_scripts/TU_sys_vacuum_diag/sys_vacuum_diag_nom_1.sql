create or replace procedure unit_tests.sys_vacuum_diag_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'sys_vacuum_diag'
--		Ce test a pour but de :
/*
	Pré-requis :
	Créer un nouveau client.
	Créer un nouvelle table test (id serial primary key, value varchar (100))
	Insérer des données aléatoires dans la colonne value jusqu'à hauteur de 260M de données
	Supprimer un tiers des données de la table
		
	Action :
	Appeler la procédure de vacuum sur le client_1
	
	Résultat attendu :	
	Une nouvelle ligne est présente dans common.vacuum_script_results et indique un VACUUM ANALYZE sur la table client_1.test
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			16/04/2019		Création 
--
---------------------------------------------------------------------------------------------------------------
declare 
	debug record;
begin	
	-- Script pré-requis :	
	call common.create_new_client('client_1');

	create table master.test (id serial primary key, value varchar (100));
	ALTER TABLE client_1.test SET (
	  autovacuum_enabled = false, toast.autovacuum_enabled = false
	);

	create table master.test_2 (id serial primary key, value varchar (100));
	ALTER TABLE client_1.test_2 SET (
	  autovacuum_enabled = false, toast.autovacuum_enabled = false
	);

	insert into client_1.test (value)
	select md5(random()::text) from generate_series(1, 3000000) s;

	insert into client_1.test_2 (value)
	select md5(random()::text) from generate_series(1, 3000000) s;

	delete from client_1.test 
	where id > 1300000;


	delete from client_1.test_2
	where id > 1300000;

	-- Script action :
	if not exists 
	(
		select 1
		from 
		(
			select regexp_replace(sys_vacuum_diag, E'[\\b\\f\\t\\n\\r\\u0020]+', '', 'g' ) as field
			from common.sys_vacuum_diag('client_1')
		) T
		where field = 'VACUUMANALYZEclient_1.test;INSERTINTOcommon.vacuum_script_results(date_sys_vacuum_diag,schema_name,table_name,analyze_status,vacuum_status,commentaries)VALUES(now(),''client_1'',''test'',true,true,null);VACUUMANALYZEclient_1.test_2;INSERTINTOcommon.vacuum_script_results(date_sys_vacuum_diag,schema_name,table_name,analyze_status,vacuum_status,commentaries)VALUES(now(),''client_1'',''test_2'',true,true,null);'
	)
	then
		raise exception 'le résultat n''est pas celui attendu.';
	end if;
	
	
	CALL unit_tests.deblog('sys_vacuum_diag_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('sys_vacuum_diag_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;