create or replace function common.constraint_naming_control_limiter()
RETURNS int
language plpgsql
as $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette FONCTION est de retourner le nombre de renommage encore à faire.
-- Origines : PostgreSQL v11 | 21/02/2019
-- Limitation : 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			21/02/2019		Création
--  JPI			11/04/2019		BUG : Si le nom de contrainte est déjà utilisé.
--	JPI			31/07/2019		Correction pour la propagation des contraintes (cf. constraint_naming_control.sql)
--
---------------------------------------------------------------------------------------------------------------
declare
	res int;
begin
	with cte_referential as
	(
		-- Inventorier les clés présentent
		SELECT
			rel.relname as table_name
			, ccu.table_name as ref_table_name
			, string_agg(ccu.column_name, ' ,') as ref_columns
			, con.conname		-- nom tel qu'il est
			, con.contype
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN information_schema.constraint_column_usage AS ccu
			  ON ccu.constraint_name = con.conname
			  AND ccu.table_schema = nsp.nspname
		WHERE nsp.nspname = 'master'
			AND rel.relname IN 
			(
				SELECT table_name
				FROM information_schema.tables
				WHERE table_schema = 'master'
			)
		group by rel.relname, ccu.table_name, con.conname, con.contype
		order by conname
	)
	, cte_query as
	(
		-- Bâti des requêtes
		select table_name
			, conname
			, contype
		from cte_referential
		where 
			(
				char_length(conname) <> 8
				or common.isnumeric(substring(conname, 4, 8)) is false
				or (substring(conname, 1 ,3) <> 'pk_' and substring(conname, 1 ,3) <> 'fk_')
			)
			and contype in ('f', 'p')
	)
	select count(*) into res
	from cte_query;
	
	RETURN res;
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
end;
$$