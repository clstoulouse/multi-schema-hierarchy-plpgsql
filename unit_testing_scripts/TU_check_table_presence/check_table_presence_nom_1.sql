create or replace procedure unit_tests.check_table_presence_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'check_table_presence'
--		Ce test a pour but de :
/*
	Pré-requis :
	Une table test {test_id int primary key, value varchar (50)} doit être présente
	
	Action :
	Lancer la fonction avec pour paramètre 'test' et 'value'
	
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
	CREATE TABLE master.test (test_id int PRIMARY KEY, value varchar(50));
	
	-- Action
	if exists (
		SELECT 1
		FROM common.check_table_presence('test')
		where check_table_presence = true
	)
	then	
		CALL unit_tests.deblog('check_table_presence_nom_1', cast(1 as bit));	
	else
		raise exception 'function error';
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('check_table_presence_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;