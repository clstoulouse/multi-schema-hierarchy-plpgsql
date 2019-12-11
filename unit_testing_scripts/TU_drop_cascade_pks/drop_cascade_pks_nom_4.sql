create or replace procedure unit_tests.drop_cascade_pks_nom_4()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 4 de la procédure 'drop_cascade_pks'
--		Ce test a pour but de :
/*	
	Pré-requis :
	Cas nominal 3 : ok
	Créer une table test_4 (test_id varchar(5) primary key, value varchar (50)); 
	Mettre des données selon la description suivante :
	client_1			client_2
	test_id	value		test_id	value
	'a'		'test'		'e'		'test'
	'b'		'test'		'f'		'test'
	'c'		'test'		'g'		'test'
	'd'		'test'		
	
	Action :
	Supprimer la clé primaire sur master.test.
	
	Résultat attendu :
	La clé primaire est supprimée sur master.
	La clé primaire est supprimée sur client_1.	
	La clé primaire est supprimée sur client_2.
	Aucune séquence n'est présente sur 'master'
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
	CREATE TABLE master.test_4 (test_id varchar(5) primary key, value varchar (50));
	INSERT INTO client_1.test_4 VALUES ('a', 'test'), ('b', 'test'), ('c', 'test'), ('d', 'test');
	INSERT INTO client_2.test_4 VALUES ('e', 'test'), ('f', 'test'), ('g', 'test');
	
	-- Script action :
	ALTER TABLE master.test_4
	DROP CONSTRAINT pk_00004 CASCADE;
	
	CALL unit_tests.deblog('drop_cascade_pks_nom_4', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_cascade_pks_nom_4', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;