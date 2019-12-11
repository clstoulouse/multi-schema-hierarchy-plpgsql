create or replace procedure unit_tests.constraint_naming_control_nom_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'constraint_naming_control'
--		Ce test a pour but de :
/*
	Pré-requis :
	NA
	
	Action :
	Créer une table 'test' (test_id int primary key, value varchar(50))	
	
	Résultat attendu :	
	La table master.test a pour clé primaire 'pk_00001'
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
			and rel.relname = 'test'
			and ccu.column_name = 'test_id'
			and con.conname = 'pk_00001'
	)
	then
		raise exception 'La contrainte n''est pas nommée correctement ou non-présente.';
	end if;
	
	CALL unit_tests.deblog('constraint_naming_control_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('constraint_naming_control_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;