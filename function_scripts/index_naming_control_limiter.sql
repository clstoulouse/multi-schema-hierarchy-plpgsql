create or replace function common.index_naming_control_limiter()
RETURNS int
language plpgsql
as $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette FONCTION est de retourner le nombre de renommage encore Ã  faire.
-- Origines : PostgreSQL v11 | 01/08/2019
-- Limitation : 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			01/08/2019		CrÃ©ation
--
---------------------------------------------------------------------------------------------------------------
declare
	res int;
begin
	with cte_referential as
	(
		SELECT
			i.relname as idx_name
			, t.relname as table_name
		FROM pg_index AS idx
			INNER JOIN pg_class AS i
				ON i.oid = idx.indexrelid
			INNER JOIN pg_namespace AS ns
				ON ns.oid = i.relnamespace
			INNER JOIN pg_class AS t
				ON t.oid = idx.indrelid
				AND t.relkind = 'r'
		WHERE ns.nspname = 'master'
			AND t.relname IN 
			(
				SELECT table_name
				FROM information_schema.tables
				WHERE table_schema = 'master'
			)
			AND idx.indisprimary = false
	)
	select count(*) into res
	from cte_referential
	where (
			(substring(idx_name, 1, 4) <> 'idx_' or char_length(idx_name) <> 9 or common.isnumeric(substring(idx_name, 5, 9)) is false)
			and (substring(idx_name, 1, 5) <> 'idxu_' or char_length(idx_name) <> 10 or common.isnumeric(substring(idx_name, 6, 10)) is false)
		);
	
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	
	RETURN res;
end;
$$