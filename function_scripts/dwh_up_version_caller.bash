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