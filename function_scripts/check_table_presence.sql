CREATE OR REPLACE FUNCTION common.check_table_presence(tablename varchar)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette fonction est de vérifier que le nom de la table passé à la table de purge existe bel et bien
-- Origines : PostgreSQL v11 | 06/03/2019
-- Limitation : 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			06/03/2019		Création
--
---------------------------------------------------------------------------------------------------------------
DECLARE 
BEGIN
	IF EXISTS
		(SELECT 1
		FROM information_schema.tables T
		WHERE T.table_type = 'BASE TABLE'
			AND T.table_schema = 'master'
			AND T.table_name = tablename)
	THEN
		RETURN true;
	ELSE
		RAISE EXCEPTION 'Le nom de la table n''existe pas dans le schéma ''master''';
	END IF;
END;
$$;