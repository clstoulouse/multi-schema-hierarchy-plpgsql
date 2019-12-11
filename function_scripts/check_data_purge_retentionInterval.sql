CREATE OR REPLACE FUNCTION common.check_data_purge_retentionInterval(retentionInterval varchar)
RETURNS BOOLEAN 
LANGUAGE plpgsql
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette fonction est de vérifier que le format entré dans la colonne d'interval de la table de
--			purge est bien éligible au modèle suivant : '[nombre] {day|month|year}'
-- Origines : PostgreSQL v11 | 06/03/2019
-- Limitation : 
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			06/03/2019		Création
--
---------------------------------------------------------------------------------------------------------------
DECLARE 
	remainingInterval varchar;
BEGIN
	SELECT
		CASE 
			-- Vérifie que le champs d'entrée comprends bien day, month ou year
			WHEN position('day' in retentionInterval) <> 0
			THEN btrim(substring(retentionInterval for position('day' in retentionInterval)-1), ' ')
			WHEN position('month' in retentionInterval) <> 0
			THEN btrim(substring(retentionInterval for position('month' in retentionInterval)-1), ' ')
			WHEN position('year' in retentionInterval) <> 0
			THEN btrim(substring(retentionInterval for position('year' in retentionInterval)-1), ' ')
		END INTO remainingInterval;
	
	-- Vérifie que ce qui reste en dehors du mot day month ou interval est bien un chiffre
	IF (SELECT common.isnumeric(remainingInterval))
	THEN
		RAISE NOTICE 'success : %', remainingInterval;
		RETURN true;
	ELSE
		RAISE NOTICE 'failure : %', remainingInterval;
		RAISE EXCEPTION 'Error:  Le champs n''est pas valide. L''interval doit être de la forme suivante : ''[nombre] [day||month||year]';
	END IF;
	
	EXCEPTION 
		WHEN others 
		THEN RETURN FALSE;
END;
$$;