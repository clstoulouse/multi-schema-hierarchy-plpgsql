create or replace procedure common.constraint_naming_control_first()
language plpgsql
as $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est renommer les contraintes s'il y a lieu.
--			Cette procédure est appelée de manière RÉCURCIVE (mes excuses mais je n'ai pas le choix).
--			Elle est en effet placer dans un trigger sur les alter table, or elle en exerce un elle-même, appelant donc ce même trigger.
-- Origines : PostgreSQL v11 | 21/02/2019
-- Limitation : Clés étrangères et clés primaires uniquement pour le moment.
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			21/02/2019		Création
--  JPI			11/04/2019		BUG : Si le nom de contrainte est déjà utilisé.
--	JPI			31/07/2019		Correction pour la propagation des contraintes (cf. constraint_naming_control.sql)
--
---------------------------------------------------------------------------------------------------------------
declare
	query character varying;
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
			, ref_table_name
		from cte_referential
		where 
			(
				char_length(conname) <> 8
				or common.isnumeric(substring(conname, 4, 8)) is false
				or (substring(conname, 1 ,3) <> 'pk_' and substring(conname, 1 ,3) <> 'fk_')
			)
			and contype in ('f', 'p')
		limit 1
	)
	select 'COMMENT ON CONSTRAINT '||conname||' ON master.'||table_name||' IS '''||
			'Contrainte de type '||case when contype = 'p' then 'PRIMARY KEY sur la table master.'||table_name else 'FOREIGN KEY de master.'||table_name||' vers master.'||ref_table_name end
			||''';'||chr(10)||
			'ALTER TABLE master.'||table_name||' RENAME CONSTRAINT '||conname||' TO '||case 
				when contype = 'p'
					then 'pk_'||LPAD(nextval('master.sq_master_pks_id')::text, 5, '0')
				when contype = 'f'
					then 'fk_'||LPAD(nextval('master.sq_master_fks_id')::text, 5, '0')
			end||';' into query
	from cte_query;
	
	--RAISE NOTICE ' %', query;
    --INSERT INTO common.debbug (query_date, query) VALUES (now(), query);
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('constraint_naming_control_first' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('constraint_naming_control_first' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			raise '%', chr(10)||'error in ''common.constraint_naming_control_first'' consequently to : '||sqlerrm;
end;
$$