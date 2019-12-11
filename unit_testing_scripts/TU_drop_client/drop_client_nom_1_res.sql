create or replace procedure unit_tests.drop_client_nom_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'drop_client'
--		Ce test a pour but de :
/*
	Pré-requis :
	Créer un schéma client : 'client_66'
		
	Action :
	Supprimer le client_66
	
	Résultat attendu :	
	Le schéma client_66 n'existe plus
	Le client n'est plus dans la table common.dwh_dm_client
	Le rôle writer_client_66 n'existe plus
	Le rôle reader_client_66 n'existe plus
*/
-- PARTIE RESULTAT
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			16/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	if exists (
		select 1
		FROM information_schema.schemata
		where schema_name = 'client_66'
	)
	then 
		raise exception 'Le schéma existe toujours.';
	end if;
		
	if exists (
		SELECT 1
		FROM common.dwh_dm_client
		WHERE client_waste_nom = 'client_66'
	)
	then 
		raise exception 'Le client est toujours dans la table common.dwh_dm_client.';
	end if;
		
	if exists (
		select 1
		from pg_roles
		where rolname = 'writer_client_66'
	)
	then 
		raise exception 'Le rôle writer_client_66 existe toujours.';
	end if;
		
	if exists (
		select 1
		from pg_roles
		where rolname = 'reader_client_66'
	)
	then 
		raise exception 'Le rôle reader_client_66 existe toujours.';
	end if;
	
	CALL unit_tests.deblog('drop_client_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_client_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;