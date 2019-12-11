CREATE OR REPLACE PROCEDURE unit_tests.deblog(testing_method_name_in varchar (250), status bit, commentary text default null)
 LANGUAGE plpgsql
AS $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de logger les résultats des tests unitaires
--
-- Dans chaque procédure de test, pour chaque query, enregistrer la query exécutée
-- Si une procédure échoue : ne pas enregistrer de query mais le texte de l'erreur ainsi que le statut 0.

-- Origines : PostgreSQL v11
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			04/04/2019		Création
--	JPI			05/04/2019		Automatisation
--
---------------------------------------------------------------------------------------------------------------
DECLARE
	in_test_part_id int;
	in_test_id int;
BEGIN
	CREATE TABLE IF NOT EXISTS unit_tests.detail_report_table
	(
		id serial primary key
		, execution_timestamp timestamp
		, test_part_id int references unit_tests.test_part (id)	
		, status bit
		, commentary text
	);
		
	select 
		test_id into in_test_id
	from unit_tests.test_part 
	where testing_method_name = testing_method_name_in;
	
	select 
		tp_id INTO in_test_part_id
	from 
	(
		select
			rank() over (partition by t.id order by tp.id) as tp_id
			, tp.testing_method_name
		from unit_tests.test t
			inner join unit_tests.test_part tp
			on t.id = tp.test_id
	) as T1
	where testing_method_name = testing_method_name_in;
	
	INSERT INTO unit_tests.detail_report_table
	(
		execution_timestamp
		, test_part_id
		, status
		, commentary
	)
	VALUES
	(
		now()
		, in_test_part_id
		, status
		, case
			when status = cast(1 as bit)
				then 
					'Test '
					||CAST(in_test_id as varchar)
					||'.'
					||CAST(in_test_part_id as varchar)
					||' : done. '
					||COALESCE(commentary, '')
				else 
					'Test '
					||CAST(in_test_id as varchar)
					||'.'
					||CAST(in_test_part_id as varchar)
					||' : failure. '
					||COALESCE(commentary, '')
		end
	);
END;
$procedure$
;