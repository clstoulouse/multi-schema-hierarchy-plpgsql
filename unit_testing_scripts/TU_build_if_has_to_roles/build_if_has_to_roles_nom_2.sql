create or replace procedure unit_tests.build_if_has_to_roles_nom_2()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 2 de la procédure 'build_if_has_to_roles'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 1 : OK
	Ajouter une colonne 'test_id' de type int
		
	Action :
	Ajouter une contrainte de clé primaire sur la colonne master.test.test_id
	
	Résultat attendu :
	Seuls existes le droit de SELECT pour le profil writer_client_1 pour la colonne test_id.
	Seuls existes le droit de SELECT pour le profil reader_client_1 pour la colonne test_id.
	Le profil writer_client_1 bénéficie des droits SELECT, INSERT et UPDATE sur la colonne client_1.
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			08/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	ALTER TABLE master.test
	ADD test_id int;
		
	-- Action
	ALTER TABLE master.test
	ADD CONSTRAINT pk_t PRIMARY KEY (test_id);
	
	CALL unit_tests.deblog('build_if_has_to_roles_nom_2', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_roles_nom_2', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;