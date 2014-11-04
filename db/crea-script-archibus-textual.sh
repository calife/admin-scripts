#!/bin/bash
# Thursday, 16. October 2014
#
# Script di creazione degli script oracle, a partire da un TEMPLATE comune.
#
#

CWD=$(dirname $(realpath $0))
NEW_INSTANCE_NAME="";
NEW_AFM_PASSWORD="";

# Verifica ed esegue il caricamento delle funzioni di help e della libreria zenity, per creare gli script
checkRequired() {

	if [ ! -f ${CWD}/helper-func ] ; then # check helper-func
		echo "Missing helper-func";
		exit 1;
	else 
		. ${CWD}/helper-func
	fi;
}


Usage() {
	echo " "
	echo " Script 0.1 Thursday, 16. October 2014"
	echo " Utilizzo: "
	echo " "` basename $0` " new_instance_name "
	echo " "
}

AskConfirm() {
	echo -n ${1};
	while true ; do	
		read CONFIRM		
		case $CONFIRM in
			s|y|Y|S|YES|yes|Yes|Si|SI)
				return 1;
		 		break
		 		;;			
			n|N|no|NO|No)
				echo -n "Operazione annullata";
				return 0;
		 		break
				;;
			*) echo -n "Operazione non valida, digitare y o n :";;
		esac;
	done;
}

############################################ Main ##############################################

checkRequired

if [ $# -eq 1 ]; then
	case "$1" in
		"" ) Usage; exit 0;;
		--help|-h) Usage; exit 0;;
		*  )

			NEW_INSTANCE_NAME=$1;

			AskConfirm "Vuoi creare gli script  per la nuova istanza "$NEW_INSTANCE_NAME" ?[y/n] ";

			if [ $? != 0 ]; then

				echo " Start... "

				genera-script-base  "$NEW_INSTANCE_NAME"

				genera-script-cambio-password  "$NEW_INSTANCE_NAME"

				genera-script-tablespace-AFM_P1 "$NEW_INSTANCE_NAME"

				genera-script-tablespace-AFM_BLOB "$NEW_INSTANCE_NAME"

				echo " ...Script creati in /tmp/$NEW_INSTANCE_NAME"
			fi;

			exit 0;

			;;
	esac;
else
	echo "Il numero di parametri forniti non e' corretto"
	exit 1;
fi;

#####################################################################################################