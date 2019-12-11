create or replace procedure unit_tests.drop_cascade_pks_nom_2()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 2 de la procédure 'drop_cascade_pks'
--		Ce test a pour but de :
/*	
	Pré-requis :
	Cas nominal 1 : ok
	Créer les nouveaux clients client_1 et client_2
	Créer une table test_2 (test_id int primary key, value varchar (50));
	Mettre des données selon la description suivante :
	client_1			client_2
	test_id	value		test_id	value
	1		'test'		5		'test'
	2		'test'		6		'test'
	3		'test'		7		'test'
	4		'test'			
	
	Action :
	Supprimer la clé primaire sur master.test.
	
	Résultat attendu :
	La clé primaire est supprimée sur master.
	La clé primaire est supprimée sur client_1.	
	La clé primaire est supprimée sur client_2.
	La séquence sq_pk_test est supprimée
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
	CALL common.create_new_client('client_1');
	CALL common.create_new_client('client_2');
	CREATE TABLE master.test_2 (test_id int primary key, value varchar (50));
	INSERT INTO client_1.test_2 (value) VALUES ('test'), ('test'), ('test'), ('test');
	INSERT INTO client_2.test_2 (value) VALUES ('test'), ('test'), ('test');
	
	-- Script action :
	ALTER TABLE master.test_2
	DROP CONSTRAINT pk_00002 CASCADE;
	
	CALL unit_tests.deblog('drop_cascade_pks_nom_2', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_cascade_pks_nom_2', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;