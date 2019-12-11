CREATE OR REPLACE PROCEDURE common.drop_client
(
	client_name character varying
) language plpgsql
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procedure est de supprimer un client
-- Origines : PostgreSQL v11 | 15/02/2019
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			15/02/2019		Création
--	JPI			04/04/2019		Modification pour pouvoir laisser les droits en place s'il existe de multiples 
--								instances appuyées sur les même droits.
--  JPI			12/04/2019		BUG : il restait une valeur en dur à l'intérieur du code ('client_2' au lieu de client_name)
--
---------------------------------------------------------------------------------------------------------------
DECLARE
	query character varying;
BEGIN
	-- N'exécuter la suite que si le client existe.
	IF NOT EXISTS (SELECT 1 FROM common.dwh_dm_client WHERE client_waste_nom = client_name)
	THEN
		RAISE EXCEPTION 'The specified client does not exist';
	END IF;
	
	-- Supprimer le schéma du client
	if exists (select 1 from information_schema.schemata where schema_name = client_name)
	then 
		query := 'DROP SCHEMA '||client_name||' CASCADE;';
		EXECUTE query;
		CALL common.deblog(CAST('drop_client' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	-- delete data from common tables
	if exists (select 1 from common.dwh_dm_client where client_waste_nom = client_name)
	then 
		query := 'DELETE FROM common.dwh_dm_client WHERE client_waste_nom = '''||client_name||''';';
		EXECUTE query;
		CALL common.deblog(CAST('drop_client' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	call common.drop_roles(client_name);
	
	EXCEPTION
		WHEN others THEN
			ROLLBACK;
			CALL common.deblog(CAST('drop_client' as varchar), CAST(SQLERRM as text), cast(0 as bit));
END;
$$;