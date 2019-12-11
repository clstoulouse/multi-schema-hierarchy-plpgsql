create or replace procedure unit_tests.build_if_has_to_pks_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Une table est présente dans le schéma 'master' sans clé primaire.
	
	Action :
	Ajout d'une colonne de type 'int' ayant pour nom 'id_test'.
	Ajout d'une clé primaire sur la colonne créée portant pour nom : 'pk_ttt'
	
	Résultat attendu :
	Une clé primaire est bien référencée sur la colonne crée.
	Cette clé primaire porte le nom 'pk_00001'.
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
	CREATE TABLE master.test (value varchar(25));
	
	-- Action
	ALTER TABLE master.test
	ADD id_test int;
	
	ALTER TABLE master.test
	ADD CONSTRAINT pk_ttt PRIMARY KEY (id_test);
	
	CALL unit_tests.deblog('build_if_has_to_pks_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_pks_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;