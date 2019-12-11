create or replace procedure unit_tests.drop_cascade_pks_nom_3()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 3 de la procédure 'drop_cascade_pks'
--		Ce test a pour but de :
/*	
	Pré-requis :
	Cas nominal 2 : ok
	Créer une table test_3 (test_id int, test_id_2 varchar(5), value varchar (50)); 
	Créer une clé primaire composée sur master.test pourvu de test_id et test_id_2.
	Mettre des données selon la description suivante :
	client_1					client_2
	test_id	test_id_2	value	test_id	test_id_2	value
	1		'A'			'test'	5		'A'			'test'
	2		'A'			'test'	6		'B'			'test'
	3		'A'			'test'	7		'B'			'test'
	4		'B'			'test'		
	
	Action :
	Supprimer la clé primaire sur master.test.
	
	Résultat attendu :
	La clé primaire est supprimée sur master.
	La clé primaire est supprimée sur client_1.	
	La clé primaire est supprimée sur client_2.
	Aucune séquence n'est présente sur le schéma 'master'
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
	CREATE TABLE master.test_3 (test_id int, test_id_2 varchar(5), value varchar (50));
	ALTER TABLE master.test_3 
	ADD CONSTRAINT pk_ttt PRIMARY KEY (test_id, test_id_2);
	INSERT INTO client_1.test_3 (test_id, test_id_2, value) VALUES (1, 'A', 'test'), (2, 'A', 'test'), (3, 'A', 'test'), (4, 'B', 'test');
	INSERT INTO client_2.test_3 (test_id, test_id_2, value) VALUES (5, 'A', 'test'), (6, 'B', 'test'), (7, 'B', 'test');
	
	-- Script action :
	ALTER TABLE master.test_3
	DROP CONSTRAINT pk_00003 CASCADE;
	
	CALL unit_tests.deblog('drop_cascade_pks_nom_3', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_cascade_pks_nom_3', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;