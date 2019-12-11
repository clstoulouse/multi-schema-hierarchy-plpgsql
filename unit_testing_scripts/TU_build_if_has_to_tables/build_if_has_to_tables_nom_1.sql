create or replace procedure unit_tests.build_if_has_to_tables_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_tables'
--		Ce test a pour but de :
/*
	Pré-requis :
	Créer un client 'client_1'
	
	Action :
	Créer une table 'test' {test_id varchar(5) primary key, value varchar (50)}
	
	Résultat attendu :	
	Une table a été créée dans le schéma 'client_1'
	Le rôle writer_client_1 a été créé.
	Le rôle reader_client_1 a été créé.
	Le rôle writer_client_1 dispose des droits SELECT sur la table client_1.test
	Le rôle reader_client_1 dispose des droits SELECT sur la table client_1.test
	Le rôle writer_client_1 dispose des droits DELETE sur la table client_1.test
	Le rôle writer_client_1 dispose des droits UPDATE et INSERT sur toutes les colonnes de la table client_1.test
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			10/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	CALL common.create_new_client('client_1');
	
	-- Action
	CREATE TABLE master.test (test_id varchar (5) primary key, value varchar (50));
	
	CALL unit_tests.deblog('build_if_has_to_tables_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_tables_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;