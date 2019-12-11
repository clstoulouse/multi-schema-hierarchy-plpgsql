create or replace procedure unit_tests.build_if_has_to_sqs_nom_6_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 6 de la procédure 'build_if_has_to_sqs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 5 : OK
		
	Action :
	Supprimer la contrainte de clé primaire pk_test sur master.test
	
	Résultat attendu :
	La clé primaire a été supprimée sur les tables :
	- master.test
	- client_1.test
	- client_2.test
	La séquence sq_pk_test a été supprimée
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
	if exists (
		select 1
		from information_schema.tables
		where table_name = 'test_2'
	)
	then
		raise exception 'Il existe toujours une table test_2 sur un des schémas.';
	end if;
	
	if exists (
		select 1
		from information_schema.sequences s				
		where s.sequence_name = 'sq_pk_test_2'
	)
	then 
		raise exception 'La séquence n''a pas été automatiquement supprimée.';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_sqs_nom_6_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_sqs_nom_6_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;