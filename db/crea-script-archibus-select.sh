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
	echo " "` basename $0`
	echo " "

}

base() {

	if [ -z "$NEW_INSTANCE_NAME" ] ; then
		read -p "Nome della nuova istanza > " NEW_INSTANCE_NAME
	fi;
	
	if [  -z "$NEW_INSTANCE_NAME" ] ; then
		base
	else 
		genera-script-base  "$NEW_INSTANCE_NAME"
	fi;

}

password() {

	local pwd1='';
	local pwd2='';

	if [ -z "$NEW_AFM_PASSWORD" ] ; then

		echo -n "Password:";
		stty -echo; 
		read pwd1;
		stty echo; 
		echo 
		echo -n "Retype password:";
		stty -echo;
		read pwd2;
		stty echo;
		echo 
		
		if [ ! -z "$pwd1" -a ! -z "$pwd2"  ] ; then # verifica che almeno una delle password non sia vuota
			if [ "$pwd1" == "$pwd2" ] ; then
				NEW_AFM_PASSWORD=$pwd1;
				genera-script-cambio-password "$NEW_INSTANCE_NAME" "$NEW_AFM_PASSWORD"
			else
				echo "Le password non coincidono";
				password;
			fi;
		else 
			echo "Le password non sono valide";
			password;
		fi;

	fi;

}

tblspace_p() {

	if [ -z "$num_afm_p1_datafiles" -a -z "$datafile_afm_p1_size"  ] ; then

 		read -p "Numero di datafiles per AFM (default $DEFAULT_AFM_P1_NUM_DATAFILES) > " num_afm_p1_datafiles
		read -p "Dimensione del singolo datafile per AFM ( $DEFAULT_SIZE) > " datafile_afm_p1_size

		num_afm_p1_datafiles=${num_afm_p1_datafiles:-"$DEFAULT_AFM_P1_NUM_DATAFILES"}
		datafile_afm_p1_size=${datafile_afm_p1_size:-"${DEFAULT_SIZE/M/}"}

		genera-script-tablespace-AFM_P1 "$NEW_INSTANCE_NAME" "$num_afm_p1_datafiles" "$datafile_afm_p1_size"M

	fi;

}

tblspace_doc() {

	if [ -z "$num_afm_blob_datafiles" -a -z "$datafile_afm_blob_size"  ] ; then

 		read -p "Numero di datafiles per AFM_DOCMGMT (default $DEFAULT_AFM_DOCMGMT_NUM_DATAFILES) > " num_afm_blob_datafiles
		read -p "Dimensione del singolo datafile per AFM_DOCMGMT ( $DEFAULT_SIZE) > " datafile_afm_blob_size

		num_afm_blob_datafiles=${num_afm_blob_datafiles:-"$DEFAULT_AFM_DOCMGMT_NUM_DATAFILES"}
		datafile_afm_blob_size=${datafile_afm_blob_size:-"${DEFAULT_SIZE/M/}"}

		genera-script-tablespace-AFM_BLOB "$NEW_INSTANCE_NAME" "$num_afm_blob_datafiles" "$datafile_afm_blob_size"M

	fi;

}


#
# Visualizza il menu generale e verifica che gli step siano richiamati nell' ordine specificato 1->2->3->4
#
showmenu() {

	comandi=(
		"Script_di_base                          "
		"Cambio_password                         " 
		"Modifica_tablespace_AFM_P1              " 
		"Modifica_tablespace_AFMDOCMGMT_BLOB     "
	);

    PS3="Scegli un' azione _$ ";
	COMPLETED_STR=" [COMPLETED] "

	while true; do

		echo -en "\n### Wizard di creazione script per istanza ${RED}$NEW_INSTANCE_NAME${STD} ###\n"

		select command in "${comandi[@]}" "Quit" ; do

			case $REPLY in

				1|2|3|4)

					if [ $PREVIOUS_CHOICE -eq $(($REPLY-1)) -o $PREVIOUS_CHOICE -eq $REPLY ] ; then # il check permette la chiamata ordinata dei comandi

						PREVIOUS_CHOICE=$REPLY;

						comandi[$(($REPLY-1))]=${comandi[$(($REPLY-1))]/"$COMPLETED_STR"/}"$COMPLETED_STR"

						if [ $REPLY -eq 1 ] ; then base  "$NEW_INSTANCE_NAME" ; fi;

						if [ $REPLY -eq 2 ] ; then password  "$NEW_INSTANCE_NAME"; fi;

						if [ $REPLY -eq 3 ] ; then tblspace_p "$NEW_INSTANCE_NAME"; fi;

						if [ $REPLY -eq 4 ] ; then tblspace_doc "$NEW_INSTANCE_NAME"; fi;

						if [ $REPLY -eq ${#comandi[@]} ] ; then # condizione di uscita dal menu
							return; 
						fi;

					fi;

					break;;

				5|quit)
					echo "Quit";
					exit;;
				*) echo -e "${RED}Opzione non valida${STD}";;
			esac

		done;

clear

	done;

}

############################################ Main Loop ############################################

declare -i PREVIOUS_CHOICE=0;

if [ $# -eq 1 ]; then
	case "$1" in
		--help|-h) Usage; exit 0;;
	esac;
fi;

echo " Start... " && checkRequired && clear && showmenu && echo " ...Script creati in /tmp/$NEW_INSTANCE_NAME"

###################################################################################################