create or replace procedure unit_tests.data_purge_nom_1_res()
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
	1			'12/04/2018 12:00:00'		'test'
	2			'12/04/2018 12:10:00'		'test1'
	3			'12/05/2018 12:20:00'		'test2'
	4			'12/06/2018 12:40:00'		'test3'
	Créer l'index requis dans le cas erreur 5
	Créer un nouveau client : client_2
	Insérer les données suivantes dans la table client_2.test :
	test_id		date_mesure					value
	5			'12/07/2018 12:00:00'		'test'
	6			'12/04/2018 12:10:00'		'test1'
	7			'12/05/2018 12:20:00'		'test2'
	8			'12/06/2018 12:40:00'		'test3'
	
	Action :
	Appeler la fonction de purge.
	
	Résultat attendu :
	Il ne reste dans la table client_1.test que les lign id = 1 et id = 2.
	Il ne reste dans la table client_2.test que la ligne id = 6.
*/
-- Partie results		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			12/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin	
	if exists (
		select 1
		from client_1.test
		where test_id = 3 or test_id = 4
	)
	then
		raise exception 'Des données n''ont pas été purgées (client_1).';
	end if;
	
	if exists (
		select 1
		from client_2.test
		where test_id = 5 or test_id = 7 or test_id = 8
	)
	then
		raise exception 'Des données n''ont pas été purgées (client_2).';
	end if;
	
	if not exists (
		select 1
		from client_1.test
		where test_id = 1
	)
	then
		raise exception 'Trop de données ont été purgées (client_1)';
	end if;
	
	if not exists (
		select 1
		from client_1.test
		where test_id = 2
	)
	then
		raise exception 'Trop de données ont été purgées (client_1)';
	end if;
	
	if not exists (
		select 1
		from client_2.test
		where test_id = 6
	)
	then
		raise exception 'Trop de données ont été purgées (client_2)';
	end if;
	
	CALL unit_tests.deblog('data_purge_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('data_purge_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;