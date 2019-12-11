create or replace procedure unit_tests.build_if_has_to_fks_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_fks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Deux tables sont présentes dans le schéma 'master'.
	Un client est présent.
	
	Action :
	Une des tables est référencée par une clé étrangère dans l'autre table.
	
	Résultat attendu :
	La clé étrangère dans le schéma master porte le nom suivant : 'fk_00001'.
	Une clé étrangère est présente dans la table client_1.test_2. Cette clé étrangère porte le nom : 
	fk_00001_00001
*/
-- Partie initialisation		
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
	CALL common.create_new_client('client_1');
	CREATE TABLE master.test_1 (id_test_1 int primary key, value varchar(50));
	CREATE TABLE master.test_2 (id_test_2 int primary key, value varchar(50), id_test_1 int);

	-- Action
	ALTER TABLE master.test_2
	ADD CONSTRAINT fk_tttt
	FOREIGN KEY (id_test_1) REFERENCES master.test_1 (id_test_1);
	
	CALL unit_tests.deblog('build_if_has_to_fks_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_fks_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;