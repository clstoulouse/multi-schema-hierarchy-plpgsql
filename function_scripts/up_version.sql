CREATE OR REPLACE PROCEDURE common.up_version(creation_script varchar, client_addr varchar(20))
language plpgsql
AS $$
---------------------------------------------------------------------------------------------------------------
-- Objet : 
--			Le but de cette procédure est d'upgrader la version. Cette fonction est accédée par un script bash.
-- 			Ce script devra être lancé après chaque MIP.
/* BASH SCRIPT pour récupérer les dumps
#!/bin/bash

#demander les elements de connexion a l'utilisateur
read -p 'Entrer l'' adresse de la machine : ' machine_name
read -p 'Entrer le nom du profil : ' user_name

#le nom de la base est force par defaut
nom_base='novacom_dwh_waste'
requete="pg_dump -C -F p -s -h $machine_name -p 5432 -n master -U $user_name -W $nom_base > `pwd`/dump.sql"

#lancer la requete
eval $requete

#inserer le resultat du script en variable et le pousser dans une variable
script=$(<"`pwd`/dump.sql")
master_def=`echo "$script" | sed -b s/\'/\'\'/g `

#prendre l'identifiant de l'appelant
client=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')

#appeler la fonction d'insertion de nouvelle version
query="call common.up_version('$master_def', '$client');"
echo "$query"
psql -qtAX -U postgres -d novacom_dwh_waste -c "$query" >logger_error.log 2>logger.log
echo "done"
*/

-- Origines : PostgreSQL v11 | 26/02/2019
-- Limitation :
---------------------------------------------------------------------------------------------------------------
--	User		Date			Motives
--	JPI			26/02/2019		Création
--
---------------------------------------------------------------------------------------------------------------
BEGIN
	CREATE TABLE IF NOT EXISTS common.versionning
	(
		id serial primary key
		, client_addr varchar (25)
		, change_date timestamp DEFAULT now()
		, creation_script_version varchar
	);
	
	INSERT INTO common.versionning
	(
		client_addr
		, creation_script_version
	)
	VALUES
	(
		client_addr
		, creation_script
	);
END;
$$;