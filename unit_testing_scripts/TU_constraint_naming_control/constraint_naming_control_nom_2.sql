create or replace procedure unit_tests.constraint_naming_control_nom_2()
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
	CREATE TABLE master.test_2 (test_2_id int primary key, value varchar (50), test_id int);
	
	-- Action
	alter table master.test_2 
	add constraint fk_ttt foreign key (test_id) references master.test (test_id);
	
	CALL unit_tests.deblog('constraint_naming_control_nom_2', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('constraint_naming_control_nom_2', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;