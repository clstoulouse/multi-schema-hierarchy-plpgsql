create or replace procedure unit_tests.sys_vacuum_diag_nom_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'sys_vacuum_diag'
--		Ce test a pour but de :
/*
	Pré-requis :
	Créer un nouveau client.
	Créer un nouvelle table test (id serial primary key, value varchar (100))
	Insérer des données aléatoires dans la colonne value jusqu'à hauteur de 260M de données
	Supprimer un tiers des données de la table
		
	Action :
	Appeler la procédure de vacuum sur le client_1
	
	Résultat attendu :	
	Une nouvelle ligne est présente dans common.vacuum_script_results et indique un VACUUM ANALYZE sur la table client_1.test
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
	-- Restult test script
	if not exists (
		select 1
		FROM common.vacuum_script_results
		where schema_name = 'client_1'
			and table_name = 'test'
			and vacuum_status = true
			and analyze_status = true)
	then 
		raise exception 'Aucune table n''a été vacuumé';
	end if;
	
	CALL unit_tests.deblog('sys_vacuum_diag_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('sys_vacuum_diag_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;