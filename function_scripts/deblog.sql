CREATE OR REPLACE PROCEDURE common.deblog(nom_appelant varchar, query text, resultat bit)
language plpgsql
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est de logger les différentes modification de structures effectuées 
--			automatiquements
-- TRACER
-- Le but est de suivre les modifications effectuées sur le schéma maître.
-- Les modifications prévues sont toutes dans les différentes fonctions du common.
-- Chaque exécution doit donc aussi être enregistrée
-- Si une exception intervient : alors cela doit être enregistrée de même.
-- Cet enregistrement doit être pourvu :
-- 		* de l'ip émettrice
--		* de la date de modification
--		* de la requête
--		* du nom de la procédure depuis laquelle la requête fut lancée
-- LIMITATION : il est impossible aujourd'hui d'avoir une transcription de la requête exécutée en entrée d'un event trigger (hormis en le codant 
-- 				en c). Donc seul les requêtes exécutées à l'intérieur des procédures et fonctions lancées dans les event triggers seront loggés.

-- Dans chaque fonction, pour chaque query, enregistrer la query exécutée
-- Si une procédure échoue : ne pas enregistrer de query mais le texte de l'erreur ainsi que le statut 0.

-- Origines : PostgreSQL v11 | 26/02/2019
-- Limitation :
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			26/02/2019		Création
--
---------------------------------------------------------------------------------------------------------------
BEGIN
	CREATE TABLE IF NOT EXISTS common.debugger
	(
		id serial primary key
		, change_date timestamp
		, change_client_addr varchar(20)
		, procedure_name varchar(40)
		, query varchar
		, change_status bit	-- '1' pour confirmé, '0' pour échoué. (la transaction complète est rollbackée)
	);
	
	INSERT INTO common.debugger
	(
		change_date
		, change_client_addr
		, procedure_name
		, query
		, change_status
	)
	VALUES
	(
		now()
		, ( SELECT client_addr as change_client_addr
			FROM pg_stat_activity
			WHERE pid = pg_backend_pid()
			LIMIT 1 )
		, nom_appelant
		, query
		, resultat
	);
END;
$$;