create or replace procedure unit_tests.data_purge_err_5()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas erreur 5 de la procédure 'data_purge'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas erreur 4 : OK
	Créer un nouveau client : client_1
	Insérer une ligne dans la table common.purge_tool_conf telle que date_mesure soit la 'column_name' et retentionInterval '1 month'
	
	Action :
	Appeler la fonction de purge
	
	Résultat attendu :
	Erreur : Les indexes suivant sont manquants et obligatoire avant le lancement de la purge : + script de création de l'index.
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			12/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	-- Prerequisites
	CREATE TABLE master.test (test_id int primary key, value varchar(50), date_mesure timestamp);
	CALL common.create_new_client('client_1');
	INSERT INTO common.purge_tool_conf 	
	VALUES
	(
		'test'
		,'date_mesure'
		,'1 month'
	);
	
	-- Action
	CALL common.data_purge();
	
	CALL unit_tests.deblog('data_purge_err_5', cast(0 as bit));	
		
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('data_purge_err_5', cast(1 as bit), CAST(SQLERRM as text));
end;
$procedure$;