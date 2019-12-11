create or replace procedure unit_tests.constraint_naming_control_nom_1()
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
	-- NA
	
	-- Action
	CREATE TABLE master.test (test_id int primary key, value varchar(50));
	
	CALL unit_tests.deblog('constraint_naming_control_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('constraint_naming_control_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;