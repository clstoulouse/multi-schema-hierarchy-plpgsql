create or replace procedure unit_tests.deblog_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'deblog'
--		Ce test a pour but de :
/*
	Pré-requis :
	NA
	
	Action :
	Appeler la procédure common.deblog
	
	Résultat attendu :
	Une ligne comme spécifiée a été insérée dans la table common.debugger
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
	-- Prerequisit 
	-- NA

	-- Action
	CALL common.deblog
	(
		'test'
		, 'test_query'
		, cast(1 as bit)
	);
	
	CALL unit_tests.deblog('deblog_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('deblog_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;