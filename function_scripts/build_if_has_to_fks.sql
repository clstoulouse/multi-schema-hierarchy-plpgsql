CREATE OR REPLACE PROCEDURE common.build_if_has_to_fks()
 LANGUAGE plpgsql
AS $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procÃ©dure est de propager les clÃ©s Ã©trangÃ¨res
-- Origines : PostgreSQL v11 | 15/02/2019
-- Limitation :
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/02/2019		CrÃ©ation
--  JPI			04/04/2019		Ajout de la discrimination du schÃ©ma de test unitaire
--  JPI			03/05/2019		Bug : les contraintes ne remontaient pas dans l'information schema. Appui sur 
--								le catalog Ã  la place.
--	JPI			31/07/2019		Correction pour la propagation des contraintes (cf. constraint_naming_control.sql)
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
			, pg_get_constraintdef(con.oid) as con_def						-- Contient la dÃ©fintion DDL de la contrainte. Need to add the alter table by and though.
			, con.conname													-- Le nom de la contrainte
			, case when pg_get_constraintdef(con.oid) not like '%master.%' then 0 else 1 end as replacer
		FROM pg_catalog.pg_constraint con									-- La table systÃ¨me renfermant les trÃ¨s saintes contraintes
			INNER JOIN pg_catalog.pg_class rel								-- Objet systÃ¨me reprÃ©sentant la table sur laquelle est posÃ©e la contrainte.
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp							-- Objet systÃ¨me reprÃ©sentant le schÃ©ma sur lequel est la table.
				ON nsp.oid = connamespace							
			INNER JOIN pg_class AS ccu	-- Table Ã  laquelle la contrainte fait rÃ©fÃ©rence
				ON con.confrelid = ccu.oid
		WHERE nsp.nspname = 'master'
			and con.contype = 'f'											-- Type de contrainte > clÃ© Ã©trangÃ¨re (Foreign key)
	)
	, cte_all_client_list as
	(
		-- Tous les clients
		select schema_name, cl.client_id
		from information_schema.schemata s
			left outer join common.dwh_dm_client cl
			on s.schema_name = cl.client_waste_nom
		where schema_name <> 'information_schema' 
			and schema_name <> 'common'
			and schema_name <> 'pg_catalog'
			and schema_name <> 'master'
			and schema_name <> 'unit_tests'
			and schema_name not like 'pg_toast%'
			and schema_name not like 'pg_temp%'
	)
	, cte_clients_fks as
	(
		-- Lister toutes les contraintes de clÃ©s Ã©trangÃ¨re des diffÃ©rents clients
		SELECT
			rel.relname as table_name
			, ccu.relname as ref_table_name
			, pg_get_constraintdef(con.oid) as con_def
			, conname
			, nsp.nspname as schema_name
		FROM pg_catalog.pg_constraint con
			INNER JOIN pg_catalog.pg_class rel
				ON rel.oid = con.conrelid
			INNER JOIN pg_catalog.pg_namespace nsp
				ON nsp.oid = connamespace
			INNER JOIN pg_class AS ccu	-- Table Ã  laquelle la contrainte fait rÃ©fÃ©rence
				ON con.confrelid = ccu.oid
		WHERE con.contype = 'f'
			and exists (select 1 from cte_all_client_list where schema_name = nsp.nspname)
	)
	select 
		-- Construction des contraintes manquantes et agrÃ©gation des scripts
		string_agg(
		'ALTER TABLE '||c.schema_name||'.'||m.table_name||' 
		ADD CONSTRAINT '||m.conname||'_'||LPAD(c.client_id::text, 5, '0')||' '||
			case when position('REFERENCES master.' in m.con_def) > 0 
				then replace (m.con_def, 'master', c.schema_name)
				else replace(m.con_def, 'REFERENCES ', 'REFERENCES ' || c.schema_name || '.')
			end
		||';'||chr(10)||
		'COMMENT ON CONSTRAINT '||m.conname||'_'||LPAD(c.client_id::text, 5, '0')||' ON '||c.schema_name||'.'||m.table_name||' IS '''||
			'Contrainte de type FOREIGN KEY de '||c.schema_name||'.'||m.table_name||' vers '||c.schema_name||'.'||m.ref_table_name
			||''';'
		, chr(13)) into query
	from cte_all_client_list c
		cross join cte_master_fks m
	where not exists 
		(
			select 1 
			from cte_clients_fks cf 
			where cf.schema_name = c.schema_name 
				and cf.table_name = m.table_name 
				and cf.conname like m.conname||'%'
		);
		
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('build_if_has_to_fks' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('build_if_has_to_fks' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			raise '%', chr(10)||'error in ''common.build_if_has_to_fks'' consequently to : '||sqlerrm;
END;
$procedure$
;