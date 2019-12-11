create or replace procedure unit_tests.build_if_has_to_sqs_nom_7_res()
language plpgsql
as $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--		Le but de cette procédure est de tester le cas nominal 7 de la procédure 'build_if_has_to_sqs'
--		Ce test a pour but de :
/*
	Pré-requis :
	Cas nominal 6 : OK
		
	Action :
	Créer une nouvelle table pourvue d'une clé primaire int 'test_3' {test_id int primary key, value varchar(50)}
	
	Résultat attendu :
	La nouvelle table est créée dans client_1 et client_2
	Les rôles writer_client_1 et writer_client_2 ont les droits USAGE sur la séquence 'sq_pk_test_3'
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
		from information_schema.tables
		where table_name = 'test_3'
			and table_schema = 'client_1'
	)
	or not exists (
		select 1
		from information_schema.tables
		where table_name = 'test_3'
			and table_schema = 'client_2'
	)
	then
		raise exception 'La table n''a pas été créée sur les schémas clients.';
	end if;
	
	if not exists (
		select 1
		from information_schema.sequences s				
		where s.sequence_name = 'sq_pk_test_3'
	)
	then 
		raise exception 'La séquence n''a pas été automatiquement crée.';
	end if;
	
	if not exists (
		select 1
		from
		(
		SELECT 
			n.nspname as schemaname,
			c.relname as objname,
			CASE c.relkind 
				WHEN 'r' 
					THEN 'table'
				WHEN 'v' 
					THEN 'view' 
				WHEN 'S' 
					THEN 'sequence' 
				END as objtype,
			regexp_split_to_table(array_to_string(c.relacl,','),',') as privileges,
			pg_catalog.pg_get_userbyid(c.relowner) as Owner
		FROM pg_catalog.pg_class c
			LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
		WHERE c.relkind IN ('r', 'v', 'S', 'f')
			AND n.nspname !~ '(pg_catalog|information_schema)'
		) t 
		where objname = 'sq_pk_test_3'
			and 
			(
				t.privileges like '%writer_client_1=U%'
				or t.privileges like '%writer_client_2=U%'
				or t.privileges like '%writer_all=U%'
			)
	)
	then 
		raise exception 'Le writer d''un des schéma client n''a pas les droits USAGE sur la séquence.';
	end if;
	
	CALL unit_tests.deblog('build_if_has_to_sqs_nom_7_res', cast(1 as bit));	
	
	EXCEPTION
		WHEN others THEN
			CALL unit_tests.deblog('build_if_has_to_sqs_nom_7_res', cast(0 as bit), CAST(SQLERRM as text));
end;
$procedure$;