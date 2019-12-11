create or replace procedure unit_tests.data_purge_err_2()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas erreur 2 de la procédure 'data_purge'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas erreur 1 : OK
	
	Action :
	Insérer une ligne dans common.purge_tool_conf.
	
	Résultat attendu :
	Erreur : contrainte de check non-respectée.
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
	-- Prerequisites
	-- NA
	
	-- Action
	INSERT INTO common.purge_tool_conf
	VALUES
	(
		'test'
		,'date_mesure'
		,'1 month'
	);
	
	CALL unit_tests.deblog('data_purge_err_2', cast(0 as bit));	
		
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('data_purge_err_2', cast(1 as bit), CAST(SQLERRM as text));
end;
$procedure$;