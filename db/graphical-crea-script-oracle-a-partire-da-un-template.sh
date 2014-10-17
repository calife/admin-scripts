#!/bin/bash
# Thursday, 16. October 2014
#
# Script di creazione degli script oracle, a partire da un TEMPLATE comune.
# !!!! Applicazione con interfaccia grafica !!!!
#
# Link Utili:
# http://linuxaria.com/howto/introduction-zenity-bash-gu
# http://www.linux.org/threads/zenity-gui-for-shell-scripts.5567/
# http://jamesslocum.com/post/61904545275
#
# @depends:  zenity

# @TODO implementare gli step per la definizione avanzata dei datafile di ciascun tablespace (lo script va eseguito prima dell' import).
# @TODO fornita una lista di banche dati, estrarre la definizione dei datafile per la banca dati selezionata e richiamare la funzionalità di cui sopra.

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
			break;
		 	;;			
		help)
			zenity --info --title "Help" --text="$MSG"
			break
			;;
		*) 
			zenity --info --title "Help" --text="$MSG"
	esac;
}

AskConfirm() {
	zenity --question --title="Conferma" --text "${1}"

	if [ "$?" -eq "0" ] ; then
		return 1;
	else
		return 0;
	fi;	
}

if [ $# -eq 1 ]; then
	case "$1" in
		"" ) Usage; exit 0;;
		--help|-h) Usage; exit 0;;
		*  )

			NEW_INSTANCE_NAME=$1;

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
				) | zenity --progress --pulsate --text="Preparazione degli script in corso" --percentage=0 --auto-close

			fi;

			echo " ...Leave";

			exit 0;

			;;
	esac;
else
	Usage error
	exit 1;
fi;