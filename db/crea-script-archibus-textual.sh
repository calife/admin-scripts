#!/bin/bash
# Thursday, 16. October 2014
#
# Script di creazione degli script oracle, a partire da un TEMPLATE comune.
#
#

echo -n " Start... "

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

if [ $# -eq 1 ]; then
	case "$1" in
		"" ) Usage; exit 0;;
		--help|-h) Usage; exit 0;;
		*  )

			NEW_INSTANCE_NAME=$1;

			AskConfirm "Vuoi rinominare gli script  per la nuova istanza "$NEW_INSTANCE_NAME" ?[y/n] ";

			if [ $? != 0 ]; then

				cp -a TEMPLATE $NEW_INSTANCE_NAME;

   			    find $NEW_INSTANCE_NAME -maxdepth 1 -type f -a \( -name '*.sql' -o -name '*.sh' \) | xargs sed -i "s/TEMPLATE/$NEW_INSTANCE_NAME/g"; \

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