CREATE OR REPLACE PROCEDURE common.create_new_client
(
	client_name varchar (50)
)  language plpgsql
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procedure est de créer automatiquement un nouveau client en lui fournissant un nom 
-- 			et un mot de passe.
-- Origines : PostgreSQL v11 | 14/02/2019
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			14/02/2019		Création
--	JPI			04/04/2019		Bug : gestion d'erreur APRES le rollback
--	JPI			11/04/2019		Bug : Suppression de duplication de code inutile et causant des bugs.
--	JPI			12/04/2019		Bug : Changement de table de détection du schéma 'master'
--	JPI			01/04/2019		Bug : Gestion du nom de la base en majuscule
--
---------------------------------------------------------------------------------------------------------------
DECLARE
	query character varying;
	current_db_name varchar (250);
BEGIN
	-- Le nom de la base de données sera nécessaire lors de la définition du search_path du client.
	SELECT current_database() INTO current_db_name;
	
	-- Créer la table clients si elle n'existe pas.	
	CREATE TABLE IF NOT EXISTS common.dwh_dm_client (
		client_id serial NOT NULL,
		client_waste_id int4 NULL,
		client_waste_nom varchar(50) NULL,
		client_waste_mdp varchar(50) NULL,
		client_novacom_id int4 NULL,
		client_novacom_nom varchar(50) NULL,
		super_client_novacom_id int4 NULL,
		super_client_novacom_nom varchar(50) NULL,
		application_novacom_id int4 NULL,
		CONSTRAINT pk_dwh_dm_client PRIMARY KEY (client_id)
	);

	
	-- Gérer le cas où le nom précisé est déjà utilisé.
	IF EXISTS (SELECT 1 FROM common.dwh_dm_client WHERE client_waste_nom = client_name)
	THEN
		RAISE EXCEPTION 'This client already exist';
	END IF;
	
	-- Insérer le nouveau client dans la table commune des clients
	INSERT INTO common.dwh_dm_client (client_waste_nom) VALUES (client_name);
	
	-- Créer le nouveau schéma du client
	if not exists (select 1 from information_schema.schemata where schema_name = client_name)
	then
		query := 'CREATE SCHEMA '||client_name||';';
		EXECUTE query;
		CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
	end if;
	
	-- Créer toutes les tables du schéma 'Master' dans le nouveau schéma client.
	if exists (select 1 from information_schema.schemata where schema_name = 'master')
	then		
		-- Créer le rôle de reader pour ce nouveau client
		if not exists (select 1 from information_schema.enabled_roles where role_name = 'reader_'||client_name)
		then
			query := 'CREATE ROLE reader_'||client_name||' login password ''reader_'||client_name||''';';
			EXECUTE query;
			CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
		end if;
		
		-- Attribuer l'usage du schéma au reader du nouveau client
		query := 'grant usage on schema '||client_name||' to reader_'||client_name||';';
		EXECUTE query;
		CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
		
		-- Créer le rôle de writer sur le schéma du nouveau client
		if not exists (select 1 from information_schema.enabled_roles where role_name = 'writer_'||client_name)
		then
			query := 'CREATE ROLE writer_'||client_name||' login password ''writer_'||client_name||''';';
			EXECUTE query;
			CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
		end if;
				
		-- Attribuer l'usage du schéma au writer du nouveau client
		query := 'grant usage on schema '||client_name||' to writer_'||client_name||';';
		EXECUTE query;
		CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
		
		-- Attribuer au reader du nouveau client, lors de sa connection, le search_path par défaut (le schéma du nouveau client)
		query := 'alter role reader_'||client_name||' in database "'||current_db_name||'" set search_path to '||client_name||';';
		EXECUTE query;
		CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));

		-- Set the search path for the schema
		query := 'alter role writer_'||client_name||' in database "'||current_db_name||'" set search_path to '||client_name||';';
		EXECUTE query;
		CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
				
		-- Create elements on the schema
		call common.build_if_has_to_tables();	
		call common.build_if_has_to_sqs();		
		call common.constraint_naming_control();	
		call common.build_if_has_to_roles();
		call common.build_if_has_to_pks();
		call common.build_if_has_to_fks();
		call common.build_if_has_to_idxs();
		
		-- Attribuer l'usage du schéma aux rôles généraux
		query := 'GRANT USAGE ON SCHEMA '||client_name||' to reader_all;';
		EXECUTE query;
		CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
		query := 'GRANT SELECT ON ALL TABLES IN SCHEMA '||client_name||' TO reader_all;';
		EXECUTE query;
		CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
		query := 'GRANT USAGE ON SCHEMA '||client_name||' to writer_all;';
		EXECUTE query;
		CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
		query := 'GRANT SELECT ON ALL TABLES IN SCHEMA '||client_name||' TO writer_all;';
		EXECUTE query;
		CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
		query := 'GRANT USAGE ON SCHEMA '||client_name||' to dashboard;';
		EXECUTE query;
		CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
		query := 'GRANT SELECT ON ALL TABLES IN SCHEMA '||client_name||' TO dashboard;';
		EXECUTE query;
		CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
	end if;	
	
	CALL common.deblog(CAST('create_new_client' as varchar), CAST(query as text), cast(1 as bit));
	
	
	EXCEPTION
		WHEN others THEN
			CALL common.deblog(CAST('create_new_client' as varchar), CAST(SQLERRM as text), cast(0 as bit));
			raise '%', chr(10)||'error in ''common.create_new_client'' consequently to : '||sqlerrm;
END;
$$