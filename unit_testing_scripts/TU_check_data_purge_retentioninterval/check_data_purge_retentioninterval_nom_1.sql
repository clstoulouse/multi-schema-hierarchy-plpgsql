create or replace procedure unit_tests.check_data_purge_retentioninterval_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'check_data_purge_retentioninterval'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 1 : OK
	
	Action :
	Lancer la fonction avec pour paramètre '1 month'
	
	Résultat attendu :	
	Erreur : 'Le champs n'est pas valide.'
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
	-- NA
	
	-- Action
	if exists (
		SELECT 1 
		FROM common.check_data_purge_retentioninterval('1 month') 
		WHERE check_data_purge_retentioninterval = true
	)
	then	
		CALL unit_tests.deblog('check_data_purge_retentioninterval_nom_1', cast(1 as bit));	
	else
		raise exception 'function error';
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('check_data_purge_retentioninterval_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;