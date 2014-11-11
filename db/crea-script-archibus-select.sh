#!/bin/bash
# Tuesday, 11. November 2014
#
# Script di creazione degli script oracle, a partire da un TEMPLATE comune.
#
# Utilizza il builtin select per la presentazione dei menu
#

CWD=$(dirname $(realpath $0))
NEW_INSTANCE_NAME="";
NEW_AFM_PASSWORD="";

RED='\033[0;41;30m'
STD='\033[0;0;39m'

# Verifica ed esegue il caricamento delle funzioni di help per creare gli script
checkRequired() {

	type realpath > /dev/null || { echo "[$0] Il pacchetto realpath non è installato"; exit 1; } # check realpath

	if [ ! -f ${CWD}/helper-func ] ; then # check helper-func
		echo "Missing helper-func";
		exit 1;
	else 
		. ${CWD}/helper-func
	fi;
}

Usage() {
	echo " "
	echo " Script 0.1 Tuesday, 11. November 2014"
	echo " Utilizzo: "
	echo " "` basename $0` " new_instance_name "
	echo " "
}

showmenu() {

    PS3="Scegli un' azione _$ ";


	local array=("Script_di_base" "Cambio_password" "Modifica_tablespace_AFM_P1" "Modifica_tablespace_AFMDOCMGMT_BLOB");

	echo -en "\n### Wizard di creazione script per istanza $NEW_INSTANCE_NAME ###\n"

    select command in "${array[@]}" "Quit" ; do

		# sleep 1;

		case $REPLY in
			1)
				if [ $PREVIOUS_CHOICE -eq 0 -o $PREVIOUS_CHOICE -eq 1 ] ; then
					PREVIOUS_CHOICE=1;
					genera-script-base  "$NEW_INSTANCE_NAME"
				else
					echo  -e "${RED}Invalid Option${STD}"
				fi;
				break;;
			2)
				if [ $PREVIOUS_CHOICE -eq 1 -o $PREVIOUS_CHOICE -eq 2 ] ; then
					PREVIOUS_CHOICE=2;
					genera-script-cambio-password  "$NEW_INSTANCE_NAME"
				else
					echo  -e "${RED}Invalid Option, choose 1 required${STD}"
				fi;
				break;;
			3)
				if [ $PREVIOUS_CHOICE -eq 2 -o $PREVIOUS_CHOICE -eq 3 ] ; then
					PREVIOUS_CHOICE=3;
					genera-script-tablespace-AFM_P1 "$NEW_INSTANCE_NAME"
				else
					echo  -e "${RED}Invalid Option, choose 2 required${STD}"
				fi;
				break;;
			4)
				if [ $PREVIOUS_CHOICE -eq 3 -o $PREVIOUS_CHOICE -eq 4 ] ; then
					PREVIOUS_CHOICE=4;
					genera-script-tablespace-AFM_BLOB "$NEW_INSTANCE_NAME"
				else
					echo  -e "${RED}Invalid Option, choose 3 required${STD}"
				fi;
				break;;
			5|quit)
				echo "Quit";
				exit;;
			*) echo -e "${RED}Opzione non valida${STD}";;
		esac

	done;

}

############################################ Main Loop ############################################

declare -i PREVIOUS_CHOICE=0;

if [ $# -eq 1 ]; then
	case "$1" in
		"" ) Usage; exit 0;;
		--help|-h) Usage; exit 0;;
		*  )

			echo " Start... "

			checkRequired;

			NEW_INSTANCE_NAME=$1;

			while [ ! "$choice" == "tblspace_doc" ] ; do
				showmenu;
			done;

			echo " ...Script creati in /tmp/$NEW_INSTANCE_NAME"

			finale && exit 0;

	esac;
else
	echo "Il numero di parametri forniti non e' corretto"
	exit 1;
fi;


###################################################################################################