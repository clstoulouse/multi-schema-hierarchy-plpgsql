create or replace procedure unit_tests.drop_cascade_roles_nom_1()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'drop_cascade_roles'
--		Ce test a pour but de :
/*	
	Pré-requis :
	Créer deux nouveau client : client_1 et client_2
	Créer une table test (test_id int, value varchar(50));
		
	Action :
	Ajouter une contrainte de clé primaire sur la colonne master.test.test_id
	
	Résultat attendu :
	Il existe une séquence sur la colonne master.test.test_id
	Les seuls droits accessibles pour le writer et le reader de client_1 sont ceux de consultation sur client_1.test.test_id
	Les seuls droits accessibles pour le writer et le reader de client_2 sont ceux de consultation sur client_2.test.test_id	
*/
-- Partie initialisation		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin	
	-- Script pré-requis :	
	CALL common.create_new_client('client_1');
	CALL common.create_new_client('client_2');
	CREATE TABLE master.test (test_id int, value varchar(50));
	
	-- Script action :
	ALTER TABLE master.test
	ADD CONSTRAINT pk_ttt PRIMARY KEY (test_id);
	
	CALL unit_tests.deblog('drop_cascade_roles_nom_1', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_cascade_roles_nom_1', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;