CREATE OR REPLACE FUNCTION common.check_column_presence(tablename varchar, columnname varchar)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette fonction est de vérifier que le nom de la colonne passé à la table de purge existe bel et bien
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
			INNER JOIN information_schema.columns C
				ON T.table_name = C.table_name
				AND T.table_schema = C.table_schema
		WHERE T.table_type = 'BASE TABLE'
			AND T.table_schema = 'master'
			AND T.table_name = tablename
			AND C.column_name = columnname)
	THEN
		RETURN true;
	ELSE
		RAISE EXCEPTION 'La colonne précisée n''existe pas dans la table précisée.';
	END IF;
END;
$$;