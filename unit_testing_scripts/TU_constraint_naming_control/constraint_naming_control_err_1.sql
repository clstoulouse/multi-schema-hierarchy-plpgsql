create or replace procedure unit_tests.constraint_naming_control_err_1()
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
	CREATE TABLE test_4 (test_id_4 int, value varchar(50), test_id int);	
	
	-- Script action :
	ALTER TABLE master.test_4
	ADD CONSTRAINT pk_ttt PRIMARY KEY (test_4_id);
			
	
	CALL unit_tests.deblog('constraint_naming_control_err_1', cast(0 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('constraint_naming_control_err_1', cast(1 as bit), CAST(SQLERRM as text));
end;
$procedure$;