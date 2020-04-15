CREATE OR REPLACE PROCEDURE common.shielder()
 LANGUAGE plpgsql
AS $procedure$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procÃ©dure eest de supprimer le schéma public si cela n'est pas le cas et de renseigner 
--			tous les schémas métiers dans la table dwh_dm_client s'il y a lieu.
-- Origines : PostgreSQL v11 | 15/02/2019
-- Limitation :
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			08/04/2020		CrÃ©ation
--
---------------------------------------------------------------------------------------------------------------
declare
	query character varying;
begin	
	-- supprimer le schéma public s'il existe
	drop schema if exists public;
	
	-- ajouter dans la table client les schémas métier manquants
	with cte_all_client_list as
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
	select 
		'INSERT INTO common.dwh_dm_client (client_waste_nom) VALUES '||chr(10)||
		string_agg('('''||c.schema_name||''')', chr(10)||',')||chr(10)||';' into query
	from cte_all_client_list c	
	where c.client_id is null;
	
	if query is not null 
	then 
		EXECUTE query;
		CALL common.deblog(CAST('shielder' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('shielder' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			raise '%', chr(10)||'error in ''common.shielder'' consequently to : '||sqlerrm;
END;
$procedure$
;