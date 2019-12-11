CREATE OR REPLACE FUNCTION common.isnumeric(text) 
RETURNS BOOLEAN 
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette fonction est de statuer si une chaîne de caractères est convertissable en entier ou non
-- Origines : PostgreSQL v11 | 06/03/2019
-- Limitation : 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			06/03/2019		Création
--  JPI			04/04/2019		Ajout de la discrimination du schéma de test unitaire
--
---------------------------------------------------------------------------------------------------------------
DECLARE 
	x NUMERIC;
BEGIN
    x = $1::NUMERIC;
    RETURN TRUE;

	EXCEPTION 
		WHEN others 
		THEN RETURN FALSE;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;