create or replace procedure unit_tests.drop_cascade_roles_nom_1_res()
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
-- PARTIE RESULTAT
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	if not exists (
		select 1
		from information_schema.sequences
		where sequence_schema = 'master'
			and sequence_name = 'sq_pk_test'
	)
	then
		raise exception 'La séquence n''a pas été créée pour cette clé primaire.';
	end if;
	
	if exists (			
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'writer_client_1')
			and (privilege_type = 'UPDATE' OR privilege_type = 'INSERT')
			and table_name = 'test'
			and column_name = 'test_id'
	)
	then 
		raise exception 'Le writer_client_1 a des droits INSERT ou UPDATE sur client_1.test.test_id. Ce ne devrait pas être le cas.';
	end if;
	
	if exists (			
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_1'
			and (grantee = 'reader_client_1')
			and (privilege_type = 'UPDATE' OR privilege_type = 'INSERT')
			and table_name = 'test'
			and column_name = 'test_id'
	)
	then 
		raise exception 'Le reader_client_1 a des droits INSERT ou UPDATE sur client_1.test.test_id. Ce ne devrait pas être le cas.';
	end if;
	
	if exists (			
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_2'
			and (grantee = 'writer_client_2')
			and (privilege_type = 'UPDATE' OR privilege_type = 'INSERT')
			and table_name = 'test'
			and column_name = 'test_id'
	)
	then 
		raise exception 'Le writer_client_2 a des droits INSERT ou UPDATE sur client_2.test.test_id. Ce ne devrait pas être le cas.';
	end if;
	
	if exists (			
		select 
			grantee
			, table_schema as schema_name
			, table_name
			, column_name
			, privilege_type
		from information_schema.role_column_grants r
		where table_schema = 'client_2'
			and (grantee = 'reader_client_2')
			and (privilege_type = 'UPDATE' OR privilege_type = 'INSERT')
			and table_name = 'test'
			and column_name = 'test_id'
	)
	then 
		raise exception 'Le reader_client_2 a des droits INSERT ou UPDATE sur client_2.test.test_id. Ce ne devrait pas être le cas.';
	end if;
	
	CALL unit_tests.deblog('drop_cascade_roles_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('drop_cascade_roles_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;