create or replace procedure unit_tests.drop_cascade_pks_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'drop_cascade_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Créer une table test (test_id int primary key, value varchar (50));
	
	Action :
	Supprimer la clé primaire.
	
	Résultat attendu :
	La clé primaire est supprimée.
	La séquence est supprimée.
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin	
	-- Script pré-requis :	
	CREATE TABLE master.test (test_id int primary key, value varchar (50));
	
	-- Script action :
	ALTER TABLE master.test
	DROP CONSTRAINT pk_00001 CASCADE;
	
	CALL unit_tests.deblog('drop_cascade_pks_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_cascade_pks_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;