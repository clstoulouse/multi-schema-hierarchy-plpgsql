create or replace procedure unit_tests.constraint_naming_control_nom_3()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 3 de la procédure 'constraint_naming_control'
--		Ce test a pour but de :
/*
	Pré-requis :
	Créer une table 'test_3' (test_3_id int primary key, test_id_1 int, test_id_1_2 int)
	
	Action :
	Créer les clés étrangères  test_id_1 -> test.test_id et test_id_1_2 -> test.test_id	
	
	Résultat attendu :	
	Les clés étrangères suivantes sont créées sur la table test_3:
	- fk_00002
	- fk_00003
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			10/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	CREATE TABLE master.test_3 (test_3_id int primary key, test_id_1 int, test_id_1_2 int); 
	
	-- Action
	ALTER TABLE master.test_3
	ADD CONSTRAINT fk_ttt FOREIGN KEY (test_id_1) REFERENCES master.test (test_id);
	ALTER TABLE master.test_3
	ADD CONSTRAINT fk_qqq FOREIGN KEY (test_id_1_2) REFERENCES master.test (test_id);
	
	CALL unit_tests.deblog('constraint_naming_control_nom_3', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('constraint_naming_control_nom_3', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;