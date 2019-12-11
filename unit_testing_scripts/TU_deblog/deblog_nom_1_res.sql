create or replace procedure unit_tests.deblog_nom_1_res()
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
-- PARTIE RESULTAT
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			12/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	if not exists (
		select *
		from 
		(
			select *
			from common.debugger
			order by id desc
			limit 1
		) T
		where procedure_name = 'test'
			and query = 'test_query'
			and change_status = cast(1 as bit)
	)
	then 
		raise exception 'Le débuggeur n''a pas enregistré les données voulue.';
	end if;
	
	CALL unit_tests.deblog('deblog_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('deblog_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;