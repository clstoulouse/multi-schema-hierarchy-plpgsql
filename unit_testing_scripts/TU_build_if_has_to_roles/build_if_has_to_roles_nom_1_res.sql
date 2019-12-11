create or replace procedure unit_tests.build_if_has_to_roles_nom_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_roles'
--		Ce test a pour but de :
/*
	Pré-requis :
	Une table dans le schéma master
	
	Action :
	Créer un nouveau client 'client_1'
	
	Résultat attendu :
	Deux nouveau rôles sont créés : reader_client_1 et writer_client_1
*/
-- Partie results		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			08/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	if not exists (
		select 1
		from pg_roles
		where rolname = 'writer_client_1'
	)
	then
		raise exception 'Le rôle writer n''a pas été créé.';
	end if;
	
	if not exists (
		select 1
		from pg_roles
		where rolname = 'reader_client_1'
	)
	then
		raise exception 'Le rôle reader n''a pas été créé.';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_roles_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_roles_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;