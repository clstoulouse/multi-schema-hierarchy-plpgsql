create or replace procedure unit_tests.constraint_naming_control_err_2()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas d'erreur 2 de la procédure 'constraint_naming_control'
--		Ce test a pour but de :
/*
	Pré-requis :
	NA
	
	Action :
	Créer une contrainte de clé étrangère portant le nom 'kkkjjj' référant test_id à test (test_id)
	
	Résultat attendu :	
	La contrainte ne porte pas le nom voulu.
*/
-- PARTIE PREREQUIS	
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			11/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	
	-- Script pré-requis :	
	-- NA
	
	-- Script action :
	ALTER TABLE test_4
	ADD CONSTRAINT kkkjjj FOREIGN KEY (test_id) REFERENCES test (test_id);
			
	
	CALL unit_tests.deblog('constraint_naming_control_err_2', cast(0 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('constraint_naming_control_err_2', cast(1 as bit), CAST(SQLERRM as text));
end;
$procedure$;