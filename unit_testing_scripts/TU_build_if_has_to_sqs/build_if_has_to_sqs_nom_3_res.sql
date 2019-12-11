create or replace procedure unit_tests.build_if_has_to_sqs_nom_3_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 3 de la procédure 'build_if_has_to_sqs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 2 : ok
	
	Action :
	Insérer une donnée dans client_1.test
	Insérer une donnée dans client_2.test
	Insérer une donnée dans client_2.test
	Insérer une donnée dans client_1.test
	
	Résultat attendu :
	client_1.test
	test_id		value
	1			'test'
	4			'test'
	
	client_2.test
	test_id		value
	2			'test'
	3			'test'
*/
-- Partie results		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			09/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	if not exists (
		select 1
		from client_1.test
		where test_id IN (1,4)
	)
	and not exists (
		select 1
		from client_2.test
		where test_id IN (2,3)
	)
	then
		raise exception 'Le fait d''avoir une seule séquence pour tous les clients n''est pas respecté.';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_sqs_nom_3_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_sqs_nom_3_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;