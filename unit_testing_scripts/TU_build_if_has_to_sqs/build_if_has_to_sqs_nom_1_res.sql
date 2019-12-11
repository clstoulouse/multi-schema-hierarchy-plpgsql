create or replace procedure unit_tests.build_if_has_to_sqs_nom_1_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 1 de la procédure 'build_if_has_to_sqs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Le système possède deux clients 'client_1' et 'client_2'
	
	Action :
	Création d'une table 'test' {test_id int primary key, value varchar(50)}
	
	Résultat attendu :
	Une séquence a été créée sur le schéma master et porte le nom 'sq_pk_test'.
	La colonne client_1.test.test_id suit la séquence 'sq_pk_test'.
	La colonne client_2.test.test_id suit la séquence 'sq_pk_test'.
*/
-- Partie results		
-- Quel que soit le résultat de ce test, le dit résultat sera présent dans la table unit_tests.detail_report_table
-- Origines : PostgreSQL v11 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			09/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
begin
	if not exists (
		select 1
		from
		(
		select
			string_agg(tc.table_schema, ', ' order by tc.table_schema) as all_sch
		from information_schema.columns c
			inner join information_schema.table_constraints tc
				on tc.table_name = c.table_name
				and c.table_schema = tc.table_schema
			inner join information_schema.key_column_usage kc
				on kc.constraint_name = tc.constraint_name
				and kc.table_name = tc.table_name
				and kc.table_schema = tc.table_schema
				and kc.column_name = c.column_name
			inner join information_schema.sequences s
				on c.column_default like '%'||s.sequence_name||'''::%'		
		where tc.constraint_type = 'PRIMARY KEY'
			and s.sequence_name = 'sq_pk_test'
		) t
		where all_sch = 'client_1, client_2, master'
	)
	then
		raise exception 'La séquence de clé primaire est manquante sur un ou plusieurs schéma.';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_sqs_nom_1_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_sqs_nom_1_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;