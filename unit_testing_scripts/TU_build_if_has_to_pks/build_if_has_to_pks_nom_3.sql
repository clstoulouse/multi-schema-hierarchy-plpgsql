create or replace procedure unit_tests.build_if_has_to_pks_nom_3()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 3 de la procédure 'build_if_has_to_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 2 OK
	Créer une nouvelle table 'test_2' pourvu d'une colonne 'test_id' de type int.
	
	Action :
	Ajouter une clé primaire nommée 'pk_ttt' a la table master.test_2
	
	Résultat attendu :
	La clé sur la table master.test_2 porte le nom de pk_00002
	Une nouvelle clé nommée 'pk_00002_00001' est présente sur la table client_1.test_2
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			08/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	CREATE TABLE master.test_2 (test_id int);
	
	-- Action
	ALTER TABLE master.test_2 
	ADD CONSTRAINT pk_ttt PRIMARY KEY (test_id);
	
	CALL unit_tests.deblog('build_if_has_to_pks_nom_3', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_pks_nom_3', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;