create or replace procedure common.reset_fks()
language plpgsql
as $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de reseter les clés étrangères. Il est arrivé d'avoir toutes les clés étrangères mal initialisées.
-- Origines : PostgreSQL v11 | 23/08/2019
-- Limitation :
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			23/08/2019		Création
--
---------------------------------------------------------------------------------------------------------------
declare
	query character varying;
begin
	with cte_master_fks as
	(
		SELECT
			rel.relname as table_name
			, ccu.relname as ref_table_name
			, pg_get_constraintdef(con.oid) as con_def						-- Contient la défintion DDL de la contrainte. Need to add the alter table by and though.
			, con.conname													-- Le nom de la contrainte
			, case when pg_get_constraintdef(con.oid) not like '%master.%' then 0 else 1 end as replacer
		FROM pg_catalog.pg_constraint con									-- La table système renfermant les très saintes contraintes
			INNER JOIN pg_catalog.pg_class rel								-- Objet système représentant la table sur laquelle est posée la contrainte.
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp							-- Objet système représentant le schéma sur lequel est la table.
				ON nsp.oid = connamespace							
			INNER JOIN pg_class AS ccu	-- Table à laquelle la contrainte fait référence
				ON con.confrelid = ccu.oid
		WHERE nsp.nspname = 'master'
			and con.contype = 'f'											-- Type de contrainte > clé étrangère (Foreign key)
	)
	select 
		-- Construction des contraintes manquantes et agrégation des scripts
		string_agg('ALTER TABLE master.'||m.table_name||' DROP CONSTRAINT '||m.conname||';'||chr(13)||
		'ALTER TABLE master.'||m.table_name||' 
		ADD CONSTRAINT '||m.conname||' '||m.con_def||';'
		, chr(13)) into query
	from cte_master_fks m;
	
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('reset_fks' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('reset_fks' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			raise '%', chr(10)||'error in ''common.reset_fks'' consequently to : '||sqlerrm;
END;
$$;