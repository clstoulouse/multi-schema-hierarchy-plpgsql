create or replace procedure unit_tests.constraint_naming_control_nom_2_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 2 de la procédure 'constraint_naming_control'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 1 : ok
	
	Action :
	Créer une table 'test_2 (test_2_id int primary key, value varchar (50), test_id references test (test_id))
	
	Résultat attendu :	
	Une nouvelle clé étrangère est présente sur la table master.test_2 et porte le nom fk_00001
*/
-- Partie results		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			10/04/2019		Création
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
		WHERE nsp.nspname = 'master'
			and rel.relname = 'test_2'
			and conname = 'fk_00001'
	)
	then
		raise exception 'La contrainte est incorrecte. Pas sur la table ou mal nommée.';
	end if;
	
	CALL unit_tests.deblog('constraint_naming_control_nom_2_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('constraint_naming_control_nom_2_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;