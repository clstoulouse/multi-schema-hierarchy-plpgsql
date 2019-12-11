#!/bin/bash
##########################################################################################
##Generation automatisee de la base avec tests à l'appui.								##
##																						##
## Creer les schemas : master, common et unit_tests									    ##
## Creer les procedures et fonctions des schemas common et master						##
## Creer les procedures et fonctions du schemas unit_tests								##
## Inserer les donnees d'initialisation des tests										##	
## Lancer la procedure de tests generalisee?										    ##
## Verifier qu'aucun test n'a echoue												    ##		
## Creer les rôles dashboard, reader general et writer general							##		
##																						##	
##	Cette base doit pouvoir être creee sur n'importe quel cluster PostgreSQL			##
##	Les erreurs doivent être loggees dans le même dossier que celui de ce bash			##	
##																						##	
##########################################################################################
##  JPI	23/04/2019	Creation															##
##########################################################################################

# Variables globales
DEBUG=false 
base_creation="no" 
base_remplacement="no"
machine_name_default="localhost"
base_name_default="postgres"
user_name_default="postgres"
port_number_default="5432"
script=""

##TODO : mettre ces variables en param de script 
SCRIPTS_FOLDER="/data/novasys/dwh-waste-talend/init"

# Ajout dans le PATH les fonction postgres 
export PATH=${PATH}:/usr/pgsql-11/bin/ 

echo "Deplacement dans le dossier $SCRIPTS_FOLDER"
cd $SCRIPTS_FOLDER
echo ""

# Demander la la chaîne de connexion
read -p 'Entrer l'' adresse de la machine (localhost) : ' machine_name
machine_name="${machine_name:-$machine_name_default}"
read -p 'Entrer le port (5432) : ' port_number
port_number="${port_number:-$port_number_default}"
read -p 'Entrer le nom d''un profil sysadmin (postgres) : ' user_name
user_name="${user_name:-$user_name_default}"

while true; do
    read -p "La base doit-elle etre cree ? ([y]es|[n]o) : " yn
    case $yn in
        [Yy]* ) 
			base_creation="yes" 
			break;;
        [Nn]* ) 
			break;;
        * ) printf "\nMauvaise r?nse : 'y' ou 'n'.";;
    esac
done

if "$DEBUG";
then
	printf "\nDebug : base_creation: $base_creation \n"
fi	

read -p 'Entrer le nom de la base (postgres) : ' base_name
base_name="${base_name:-$base_name_default}"

if "$DEBUG";
then
	printf "\nDebug : \n machine_name: $machine_name \n port_number: $port_number \n user_name: $user_name \n base_creation: $base_creation \n base_name: $base_name \n"
fi	

# Connexion au serveur
script="pg_isready -h $machine_name -p $port_number -U $user_name"
if "$DEBUG";
then
	printf "\n$script\n"
fi

result=$($script)

if "$DEBUG";
then
    printf "\n$result\n"
fi

if [[ $result != *"acceptation"* ]];
then 
	 #ERREUR : Connexion au serveur impossible 
   printf "\n Connexion au serveur impossible. \n";
   exit;
fi

# Si la base n'existe pas: la creer
if [ $base_creation == "yes" ];
then
    # Si la base existe dejà
    if psql -lqt | cut -d \| -f 1 | grep -qw $base_name;
    then
      # La remplacer ?
      while true; do
          read -p "La base doit-elle être remplacee ? ([y]es|[n]o) : " yn
          case $yn in
              [Yy]* ) 
      			        base_remplacement="yes" 
      			        break;;
              [Nn]* ) 
      			        break;;
              * ) printf "\nMauvaise reponse : 'y' ou 'n'.";;
          esac
      done
      # Si oui
      if [ $base_remplacement == "yes" ];
      then
        # Supprimer la base
        SQL_COMMAND="DROP DATABASE $base_name ;"; 
        if "$DEBUG";
        then
            printf "\n Exec SQL: $SQL_COMMAND \n";
        fi
        psql -d 'postgres' -U $user_name -h $machine_name -p $port_number -c "$SQL_COMMAND";
      else
        # Sortir
        exit;
      fi
    fi
    
    # Detruire toutes les sessions
    SQL_COMMAND="SELECT pg_terminate_backend(pid) FROM pg_stat_get_activity(NULL::integer) WHERE datid=(SELECT oid from pg_database where datname = '$base_name');"; 
    if "$DEBUG";
    then
        printf "\n Exec SQL: $SQL_COMMAND \n";
    fi
    psql -d 'postgres' -U $user_name -h $machine_name -p $port_number -c "$SQL_COMMAND";    
    
    # Creer la base de donnees 
    SQL_COMMAND="CREATE DATABASE $base_name ;"; 
    if "$DEBUG";
    then
        printf "\n Exec SQL: $SQL_COMMAND \n";
    fi
    psql -d 'postgres' -U $user_name -h $machine_name -p $port_number -c "$SQL_COMMAND";
fi

# Connexion à la base
script="pg_isready -d $base_name -h $machine_name -p $port_number -U $user_name"
if "$DEBUG";
then
	printf "\n$script\n"
fi

printf "\n Base en construction \n"

# Securite : verifier que la connection à la nouvelle base est disponible.
result=$($script)
while [[ $result != *"acceptation"* ]];
do
  sleep 10
done

if "$DEBUG";
then
    printf "\n$result\n"
fi

printf "\n Base '$base_name' prête. \n"

# Creer les schemas
SQL_COMMAND="CREATE SCHEMA common; CREATE SCHEMA master; CREATE SCHEMA unit_tests;"; 
if "$DEBUG";
then
    printf "\n Exec SQL: $SQL_COMMAND \n";
fi
psql -d $base_name -U $user_name -h $machine_name -p $port_number -c "$SQL_COMMAND";

# Creer les rôles
psql -d $base_name -U $user_name -h $machine_name -p $port_number -f "$SCRIPTS_FOLDER/function_scripts/init_role.sql";

# Supprimer le schema public s'il existe
SQL_COMMAND="DROP SCHEMA IF EXISTS public CASCADE;"; 
if "$DEBUG";
then
    printf "\n Exec SQL: $SQL_COMMAND \n";
fi
psql -d $base_name -U $user_name -h $machine_name -p $port_number -c "$SQL_COMMAND";

# Creer le contenu des schemas 'common' et 'master'
printf "\n Creation du contenu des schemas 'common' et 'master' \n"
for PG_FILENAME in $SCRIPTS_FOLDER/function_scripts/*.sql; 
do	
	printf "\nExec file: $PG_FILENAME \n";
	psql -d $base_name -U $user_name -h $machine_name -p $port_number -f "$PG_FILENAME";
done

# Creer le contenu du schema 'unit_tests'
printf "\n Creation du contenu des schemas 'common' et 'master' \n"
for PG_FILENAME in $(find $SCRIPTS_FOLDER/unit_testing_scripts -name '*.sql' ! -name 'global_test_script.sql' ! -name '01_TU_initialisation.sql');
do	
	printf "\nExec file: $PG_FILENAME \n";
	psql -d $base_name -U $user_name -h $machine_name -p $port_number -f "$PG_FILENAME";
done

# Inserer les donnees concernant les tests unitaires automatises
printf "\nInitialisation des tables de test \n";
psql -d $base_name -U $user_name -h $machine_name -p $port_number -f "$SCRIPTS_FOLDER/unit_testing_scripts/TU_data_structure/01_TU_initialisation.sql";

# Lancer le script de TUA
printf "\nLancement de la campagne de test 01 \n";
psql -d $base_name -U $user_name -h $machine_name -p $port_number -f "$SCRIPTS_FOLDER/unit_testing_scripts/global_test_script.sql";

# Verifier que le contenu de tous les schemas est bien present et que tous les objets sont references comme testes
SQL_COMMAND="select * from unit_tests.presencer();"; 
if "$DEBUG";
then
    printf "\n Exec SQL: $SQL_COMMAND \n";
fi

var=$(psql -qtAX -d $base_name -U $user_name -h $machine_name -p $port_number -c "$SQL_COMMAND")
if [ $var -gt 0 ];
then
    printf "\n Des elements ne sont pas presents ou ne sont pas references comme testes. \n";
else
    printf "\n Tous les elements necessaires sont presents et references comme testes. \n";
fi

# Verifier qu'aucun test n'a echoue
SQL_COMMAND="SELECT DISTINCT 1 FROM unit_tests.detail_report_table WHERE status=cast(0 as bit);"; 
if "$DEBUG";
then
    printf "\n Exec SQL: $SQL_COMMAND \n";
fi

var=$(psql -qtAX -d $base_name -U $user_name -h $machine_name -p $port_number -c "$SQL_COMMAND")
if "$DEBUG";
then
    printf "\n Y a t il des erreurs : 1 pour oui : $var \n";
fi

if [ "$var" == 1 ];
then
    printf "\n Au moins un des tests unitaires en erreur. Voir le table ci-dessus pour le detail. \n";
else
    printf "\n Tous les tests sont bons \n";
		
	## Creation tables 
	echo "Creation des tables DM"
	for PG_FILENAME in ./tables/dm/*.sql; do
		
		echo "Exec file: $PG_FILENAME ";
		psql -d $base_name -U $user_name_default -h $machine_name_default -f "$SCRIPTS_FOLDER/$PG_FILENAME";
		echo "==========================================================="

	done

	echo "Creation des tables FT"
	for PG_FILENAME in ./tables/ft/*.sql; do
		
		echo "Exec file: $PG_FILENAME ";
		psql -d $base_name -U $user_name_default -h $machine_name_default -f "$SCRIPTS_FOLDER/$PG_FILENAME";
		echo "==========================================================="

	done

	echo "Creation des tables AG"
	for PG_FILENAME in ./tables/ag/*.sql; do
		
		echo "Exec file: $PG_FILENAME ";
		psql -d $base_name -U $user_name_default -h $machine_name_default -f "$SCRIPTS_FOLDER/$PG_FILENAME";
		echo "==========================================================="

	done
fi

# Conclusion
read -p "Press enter to continue"