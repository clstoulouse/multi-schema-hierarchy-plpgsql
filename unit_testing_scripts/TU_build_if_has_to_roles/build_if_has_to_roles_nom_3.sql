create or replace procedure unit_tests.build_if_has_to_roles_nom_3()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 3 de la procédure 'build_if_has_to_roles'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 2 : OK
		
	Action :
	Créer une table test_2 avec deux champs {test_id int; value varchar(50)}
	
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
--	JPI			09/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	-- For err_1
	CALL common.create_new_client('client_2');
	INSERT INTO client_2.test (value) VALUES ('test'), ('test'), ('test');
	
	-- Action
	CREATE TABLE master.test_2 (test_id int primary key, value varchar (50));
	
	CALL unit_tests.deblog('build_if_has_to_roles_nom_3', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_roles_nom_3', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;