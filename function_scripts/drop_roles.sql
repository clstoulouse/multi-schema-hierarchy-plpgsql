CREATE OR REPLACE PROCEDURE common.drop_roles
(
	client_name character varying
) language plpgsql
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procedure est de supprimer les rôles d'un client si nécessaire
-- Origines : PostgreSQL v11 | 
--			Si plusieurs instance de base dans le cluster s'appuient sur un même rôle alors cela peu rendre
--			la suppression du rôle impossible.
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			04/04/2019		Création
--
---------------------------------------------------------------------------------------------------------------
DECLARE
	query character varying;
BEGIN	
	-- Supprimer le rôle de writer
	if exists (select 1 from information_schema.enabled_roles where role_name = 'writer_'||client_name)
	then
		-- Supprimer les possessions spécifiques du writer (normalement seulement les grants)
		query := 'drop owned by writer_'||client_name||';';
		EXECUTE query;
		CALL common.deblog(CAST('drop_client' as varchar), CAST(query as text), cast(1 as bit));
		
		-- Supprimer le rôle writer à proprement parler
		query := 'drop role writer_'||client_name||';';
		EXECUTE query;
		CALL common.deblog(CAST('drop_client' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	-- Supprimer le rôle de reader
	if exists (select 1 from information_schema.enabled_roles where role_name = 'reader_'||client_name)
	then
		-- Supprimer les possessions spécifiques du reader (normalement seulement les grants)
		query := 'drop owned by reader_'||client_name||';';
		EXECUTE query;
		CALL common.deblog(CAST('drop_client' as varchar), CAST(query as text), cast(1 as bit));
		
		-- Supprimer le rôle reader à proprement parler
		query := 'drop role reader_'||client_name||';';
		EXECUTE query;
		CALL common.deblog(CAST('drop_client' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	EXCEPTION
		WHEN sqlstate '2BP01' THEN
			CALL common.deblog(CAST('drop_client' as varchar), 'KnownError : '||CAST(SQLERRM as text), cast(0 as bit));
		WHEN others THEN
			CALL common.deblog(CAST('drop_roles' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			raise '%', chr(10)||'error in ''common.drop_roles'' consequently to : '||sqlerrm;
END;
$$;