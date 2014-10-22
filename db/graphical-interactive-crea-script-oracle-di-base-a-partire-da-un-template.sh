#!/bin/bash
# Thursday, 16. October 2014
#
# Script di creazione degli script oracle di BASE, a partire da un TEMPLATE comune.
# !!!! Applicazione con interfaccia grafica !!!!
#
# Link Utili:
# http://linuxaria.com/howto/introduction-zenity-bash-gu
# http://www.linux.org/threads/zenity-gui-for-shell-scripts.5567/
# http://jamesslocum.com/post/61904545275
# http://techpad.co.uk/content.php?sid=90
#
# @depends:  zenity


# Global variables with default values
NEW_INSTANCE_NAME='';
PASSWORD_AFM='AFM';
PASSWORD_AFM_SECURE='AFM';
NUM_TABLESPACE_DOC=1;

echo -n " Start... "

type zenity > /dev/null || { echo "[$0] Il pacchetto zenity non è installato"; exit 1; }

Usage() {
	MSG=$(cat <<SETVAR
Help:
` basename $0`  new_instance_name
SETVAR
	)
	case $1 in
		error)
			zenity --error --title "Errore" --text="$MSG"
		 	;;			
		help)
			zenity --info --title "Help" --text="$2"
			;;
		*) 
			zenity --info --title "Help" --text="$2"
	esac;
}

AskNomeIstanza(){
	NEW_INSTANCE_NAME=$( \
		zenity --entry \
		--title="Creazione script per la nuova istanza" \
		--text="Nome della nuova istanza" \
		--width=400 \
		--entry-text=""
	)

	if [ "$?" -eq "0" ] ; then
		return 1;
	else
		return 0;
	fi;
}

AskConfirm() {
	zenity --question --title="Conferma" --text "${1}"

	if [ "$?" -eq "0" ] ; then
		return 1;
	else
		return 0;
	fi;	
}

################ Main Function ################

AskNomeIstanza

if [ x"$NEW_INSTANCE_NAME" != x ] ; then

	AskConfirm "Stai creando gli script per la nuova istanza $NEW_INSTANCE_NAME.\nVuoi procedere?";

	if [ $? != 0 ]; then

		cp -a TEMPLATE $NEW_INSTANCE_NAME;

        # sed in place + rename
		(   echo "50"; \
			sleep 2; \
			find $NEW_INSTANCE_NAME -maxdepth 1 -type f -a \( -name '*.sql' -o -name '*.sh' \) | xargs sed -i "s/TEMPLATE/$NEW_INSTANCE_NAME/g"; \
			echo "50"; \
			sleep 2; \
			cd $NEW_INSTANCE_NAME && find . -type f -name "*TEMPLATE*"|while read f; do mv $f ${f/TEMPLATE/$NEW_INSTANCE_NAME} ; done;
		) | zenity --width=400  --progress --pulsate --text="Preparazione degli script in corso" --percentage=0 --no-cancel --auto-close

		Usage help Fine;

	fi;
fi;

echo " ...Leave";
exit 0;