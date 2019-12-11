create or replace procedure unit_tests.constraint_naming_control_err_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas d'erreur 1 de la procédure 'constraint_naming_control'
--		Ce test a pour but de :
/*
	Pré-requis : 
	Créer une table test_4 (test_id_4 int, value varchar(50), test_id int)
	
	Action :
	Créer une contrainte de clé primaire sur la colonne master.test_4.test_id_4 portant le nom pk_ttt
	
	Résultat attendu :	
	La clé primaire ne porte pas ce nom.
*/
-- PARTIE Result	
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			11/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
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
		where con.conname = 'pk_ttt'
			and t.table_name = 'test_4'
			and t.table_schema = 'master')
	then
		raise exception 'La contrainte a été créée sur le schéma master sans être renommée. Erreur.';
	end if;
	
	CALL unit_tests.deblog('constraint_naming_control_err_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('constraint_naming_control_err_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;