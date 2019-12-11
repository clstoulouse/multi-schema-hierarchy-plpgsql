create or replace procedure unit_tests.check_data_purge_retentioninterval_err_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas erreur 1 de la procédure 'check_data_purge_retentioninterva'
--		Ce test a pour but de :
/*
	Pré-requis :
	NA
	
	Action :
	Lancer la fonction avec pour paramètre '01/01/2019'
	
	Résultat attendu :	
	Le résultat est true.
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
		FROM common.check_data_purge_retentioninterval('01/01/2019') 
		WHERE check_data_purge_retentioninterval = true
	)
	then	
		CALL unit_tests.deblog('check_data_purge_retentioninterval_err_1', cast(0 as bit));	
	else
		raise exception 'function error';
	end if;
		
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('check_data_purge_retentioninterval_err_1', cast(1 as bit), CAST(SQLERRM as text));
end;
$procedure$;