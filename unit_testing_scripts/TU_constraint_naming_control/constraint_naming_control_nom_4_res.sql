create or replace procedure unit_tests.constraint_naming_control_nom_4_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 4 de la procédure 'constraint_naming_control'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 3 : Ok
	
	Action :
	Créer un nouveau client
	
	Résultat attendu :	
	Les clés étrangères suivantes sont créées sur la table client_1.test_3:
	- fk_00002_00001
	- fk_00003_00001
*/
-- Partie results		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			11/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	if not exists (
		select 1
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN information_schema.constraint_column_usage AS ccu
			  ON ccu.constraint_name = con.conname
			  AND ccu.table_schema = nsp.nspname
		WHERE nsp.nspname = 'client_1'
			and rel.relname = 'test_3'
			and conname = 'fk_00002_00001'
	)
	then
		raise exception 'La contrainte est incorrecte. Pas sur la table ou mal nommée.';
	end if;
	
	if not exists (
		select 1
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN information_schema.constraint_column_usage AS ccu
			  ON ccu.constraint_name = con.conname
			  AND ccu.table_schema = nsp.nspname
		WHERE nsp.nspname = 'client_1'
			and rel.relname = 'test_3'
			and conname = 'fk_00003_00001'
	)
	then
		raise exception 'La contrainte est incorrecte. Pas sur la table ou mal nommée.';
	end if;
	
	CALL unit_tests.deblog('constraint_naming_control_nom_4_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('constraint_naming_control_nom_4_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;