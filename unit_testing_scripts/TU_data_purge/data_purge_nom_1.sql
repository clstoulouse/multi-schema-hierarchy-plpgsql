create or replace procedure unit_tests.data_purge_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_fks'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas erreur 5 : ok	
	Insérer les données suivantes dans la table client_1.test :
	test_id		date_mesure					value
	1			'12/03/2019 12:00:00'		'test'
	2			'12/03/2019 12:10:00'		'test1'
	3			'12/01/2019 12:20:00'		'test2'
	4			'12/02/2019 12:40:00'		'test3'
	Créer l'index requis dans le cas erreur 5
	Créer un nouveau client : client_2
	Insérer les données suivantes dans la table client_2.test :
	test_id		date_mesure					value
	5			'12/01/2019 12:00:00'		'test'
	6			'12/04/2019 12:10:00'		'test1'
	7			'12/03/2019 12:20:00'		'test2'
	8			'12/02/2019 12:40:00'		'test3'
	
	Action :
	Appeler la fonction de purge.
	
	Résultat attendu :
	Il ne reste dans la table client_1.test que les lign id = 1 et id = 2.
	Il ne reste dans la table client_2.test que la ligne id = 6.
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
	-- Prerequisit 
	CREATE TABLE master.test (test_id int primary key, value varchar(50), date_mesure timestamp);
	CALL common.create_new_client('client_1');
	INSERT INTO common.purge_tool_conf 	
	VALUES
	(
		'test'
		,'date_mesure'
		,'1 month'
	);
	CREATE INDEX idx_test_date_mesure ON master.test USING BTREE (date_mesure);
	CALL common.create_new_client('client_2');
	INSERT INTO client_1.test (value, date_mesure) VALUES ('test', to_timestamp(cast(now() - interval '1 hour' as varchar), 'yyyy-mm-dd hh24:mi:ss'));
	INSERT INTO client_1.test (value, date_mesure) VALUES ('test1', to_timestamp(cast(now() - interval '10 day' as varchar), 'yyyy-mm-dd hh24:mi:ss'));
	INSERT INTO client_1.test (value, date_mesure) VALUES ('test2', to_timestamp(cast(now() - interval '2 month' as varchar), 'yyyy-mm-dd hh24:mi:ss'));
	INSERT INTO client_1.test (value, date_mesure) VALUES ('test3', to_timestamp(cast(now() - interval '4 month' as varchar), 'yyyy-mm-dd hh24:mi:ss'));
	INSERT INTO client_2.test (value, date_mesure) VALUES ('test', to_timestamp(cast(now() - interval '2 month' as varchar), 'yyyy-mm-dd hh24:mi:ss'));
	INSERT INTO client_2.test (value, date_mesure) VALUES ('test1', to_timestamp(cast(now() - interval '1 hour' as varchar), 'yyyy-mm-dd hh24:mi:ss'));
	INSERT INTO client_2.test (value, date_mesure) VALUES ('test2', to_timestamp(cast(now() - interval '6 month' as varchar), 'yyyy-mm-dd hh24:mi:ss'));
	INSERT INTO client_2.test (value, date_mesure) VALUES ('test3', to_timestamp(cast(now() - interval '1 year' as varchar), 'yyyy-mm-dd hh24:mi:ss'));
	
	-- Action
	CALL common.data_purge();
	
	CALL unit_tests.deblog('data_purge_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('data_purge_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;