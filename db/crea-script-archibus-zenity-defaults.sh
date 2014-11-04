#!/bin/bash
# Thursday, 16. October 2014
#
# Script di creazione degli script oracle di BASE, a partire da un TEMPLATE comune.
#
# @depends:  zenity

CWD=$(dirname $(realpath $0))
NEW_INSTANCE_NAME="";
NEW_AFM_PASSWORD="";

finale() {
  zenity --info \
    --title="Creazione script completata" \
    --text="Script generati in /tmp/$NEW_INSTANCE_NAME"
}

# Verifica ed esegue il caricamento delle funzioni di help e della libreria zenity, per creare gli script
checkRequired() {

	type zenity > /dev/null || { echo "[$0] Il pacchetto zenity non è installato"; exit 1; } # check zenity

	if [ ! -f ${CWD}/helper-func ] ; then # check helper-func
		echo "Missing helper-func";
		exit 1;
	else 
		. ${CWD}/helper-func
	fi;
}

Usage() {
	case $1 in
		error)
			zenity --error --title "Errore" --text="$2"
		 	;;			
		help)
			zenity --info --title "Help" --text="$2"
			;;
		*) 
			zenity --info --title "Help" --text="$2"
	esac;
}

askNomeIstanza(){
	NEW_INSTANCE_NAME=$( \
		zenity --entry \
		--title="Creazione script per la nuova istanza" \
		--text="Nome della nuova istanza" \
		--width=400
	)
	if [ "$?" -eq "0" ] ; then
		return 1;
	else
		exit 0;
	fi;
}

askConfirm() {

	zenity --question --title="Conferma" --text "${1}"

	if [ "$?" -eq "0" ] ; then
		return 1;
	else
		exit 0;
	fi;	
}

############################################ Main Loop ##############################################

checkRequired

askNomeIstanza

if [ x"$NEW_INSTANCE_NAME" != x ] ; then

	askConfirm "Stai creando gli script per la nuova istanza $NEW_INSTANCE_NAME.\nVuoi procedere?";

	if [ $? == 1 ]; then
	 	(

			echo "25"
			sleep 1
			genera-script-base  "$NEW_INSTANCE_NAME"
			echo "25"
			sleep 1
			genera-script-cambio-password  "$NEW_INSTANCE_NAME"
			echo "25"
			sleep 1
			genera-script-tablespace-AFM_P1 "$NEW_INSTANCE_NAME"
			echo "25"
			sleep 1
			genera-script-tablespace-AFM_BLOB "$NEW_INSTANCE_NAME"
			echo "25"
			sleep 1

		) | zenity --width=400  --progress --pulsate --text="Preparazione degli script in corso per istanza $NEW_INSTANCE_NAME    " --percentage=0 --no-cancel --auto-close

		finale

	fi;

else 

	Usage error "Specificare il nome dell' istanza da creare"

fi;

exit 0;

#####################################################################################################