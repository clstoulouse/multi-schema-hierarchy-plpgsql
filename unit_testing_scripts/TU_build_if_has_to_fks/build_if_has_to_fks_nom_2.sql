create or replace procedure unit_tests.build_if_has_to_fks_nom_2()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 2 de la procédure 'build_if_has_to_fks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 1 OK
	Une table est ajoutée dans le schéma 'master'.
	
	Action :
	La clé étrangère du cas nominal 1 est supprimée.
	Une nouvelle clé étrangère est créée entre la nouvelle table et une ancienne table.
	
	Résultats attendus :
	La clé étrangère fk_00001 n'existe plus sur le schéma master.
	La clé étrangère fk_00001_00001 n'existe plus.
	La clé étrangère fk_00002 a été créée sur master.test_3.
	La clé étrangère fk_00002_00001 a été créée sur client_1.test_3.
*/
-- PARTIE PREREQUIS	
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			04/04/2019		Création
--	JPI			06/08/2019		Prise en compte du renommage normalisé chiffré.
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisit 
	CREATE TABLE master.test_3 (id_test_3 int primary key, value varchar(50), id_test_2 int);

	-- Action
	ALTER TABLE master.test_2
	DROP CONSTRAINT fk_00001;
	
	ALTER TABLE master.test_3
	ADD CONSTRAINT fk_tttt
	FOREIGN KEY (id_test_2) REFERENCES master.test_2 (id_test_2);
			
	
	CALL unit_tests.deblog('build_if_has_to_fks_nom_2', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_fks_nom_2', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;