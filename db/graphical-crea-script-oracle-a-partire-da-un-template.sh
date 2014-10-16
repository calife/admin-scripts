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

echo -n " Start... "

type zenity > /dev/null || { echo "[$0] Il pacchetto zenity non è installato"; exit 1; }

Usage() {
	echo " "
	echo " Script 0.1 Thursday, 16. October 2014"
	echo " Utilizzo: "
	echo " "` basename $0` " new_instance_name "
	echo " "
}

AskConfirm() {

	while true ; do	
		zenity --question --title="Conferma" --text "${1}"

		if [ "$?" -eq "0" ] ; then
			return 1;
		else
			return 0;
		fi;	
	done;

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

			    find $NEW_INSTANCE_NAME -type f -a \( -name '*.sql' -o -name '*.sh' \) | xargs sed -i "s/TEMPLATE/$NEW_INSTANCE_NAME/g";

			    cd $NEW_INSTANCE_NAME && find . -type f -name "*TEMPLATE*"|while read f; do mv $f ${f/TEMPLATE/$NEW_INSTANCE_NAME} ; done;

			fi;

			echo " ...Leave";

			exit 0;

			;;
	esac;
else
	echo "Il numero di parametri forniti non e' corretto"
	exit 1;
fi;