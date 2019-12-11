create or replace procedure unit_tests.build_if_has_to_pks_nom_4()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 4 de la procédure 'build_if_has_to_pks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 3 OK
	Créer une nouvelle table 'test_3' avec deux colonnes 'test_id' et 'test_code' qui serviront au bâti de la clé primaire.
		
	Action :
	Ajouter la clé primaire 'pk_ttt' sur les deux colonnes de la nouvelle table.
	
	Résultat attendu :
	La clé primaire 'pk_00003' comporte bien les deux colonnes sur le schéma master
	La clé primaire 'pk_00003_00001' comporte bien les deux colonnes sur le schéma client_1
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
	CREATE TABLE master.test_3 (test_id int, test_code varchar (5));
	
	-- Action
	ALTER TABLE master.test_3 
	ADD CONSTRAINT pk_ttt PRIMARY KEY (test_id, test_code);
	
	CALL unit_tests.deblog('build_if_has_to_pks_nom_4', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_pks_nom_4', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;