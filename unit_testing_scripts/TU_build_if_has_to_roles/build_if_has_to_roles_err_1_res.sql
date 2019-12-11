create or replace procedure unit_tests.build_if_has_to_roles_err_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas d'erreur 1 de la procédure 'build_if_has_to_roles'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 3 : OK
	Créer un nouveau client 'client_2'
	Avoir en base les données suivantes sur la table client_2.test :
	test_id		value
	1			'test'
	2			'test'
	3			'test'
	
	Action :
	Définir le rôle de session comme étant celui de writer_client_1.
	Modifier la ligne ayant pour client_2.test.test_id 3.
	
	Résultat attendu : 
	Échec de la modification par manque de droits.
*/
-- PARTIE Result	
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			05/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	if exists (
		select 1
		FROM client_2.test
		WHERE test_id = 3 
			AND value = 'test_zzz'
	)
	then
		raise exception 'la valeur a été modifiée.';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_roles_err_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_roles_err_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;