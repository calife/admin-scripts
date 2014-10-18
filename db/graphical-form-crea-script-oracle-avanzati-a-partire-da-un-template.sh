#!/bin/bash
# Thursday, 16. October 2014
#
# Script di creazione degli script oracle AVANZATI, a partire da un  comune.
# !!!! Applicazione con interfaccia grafica !!!!
#
# Link Utili:
# http://linuxaria.com/howto/introduction-zenity-bash-gu
# http://www.linux.org/threads/zenity-gui-for-shell-scripts.5567/
# http://jamesslocum.com/post/61904545275
# http://techpad.co.uk/content.php?sid=90
#
# @depends:  zenity

# @TODO implementare gli step per la definizione avanzata dei datafile di ciascun tablespace (lo script va eseguito prima dell' import).
# @TODO fornita una lista di banche dati, estrarre la definizione dei datafile per la banca dati selezionata e richiamare la funzionalità di cui sopra.

echo -n " Start... "

type zenity > /dev/null || { echo "[$0] Il pacchetto zenity non è installato"; exit 1; }

cfgpass=`zenity --forms \
    --title="Exemple qui tue la mort" \
    --text="Définir un nouveau mot de passe" \
    --add-entry="Nom de l'utilisateur" \
    --add-password="Ancien mot de passe" \
    --add-password="Nouveau mot de passe" \
    --add-password="Confirmer le nouveau mot de passe" \
    --separator="|"`

#Si on clique sur le bouton Annuler
if [ "$?" -eq 1 ]; then
    #On quitte le script
    exit
fi
#Sinon on continue
#On peut récupérer les valeurs des différents champs de cette façon :
echo "$cfgpass" | cut -d "|" -f1 #Nom de l'utilisateur
echo "$cfgpass" | cut -d "|" -f2 | md5sum #Ancien Mot de passe
echo "$cfgpass" | cut -d "|" -f3 | md5sum #Nouveau Mot de passe
echo "$cfgpass" | cut -d "|" -f4 | md5sum #Confirmation du nouveau mot de passe

echo "Franchement la classe cette nouvelle fonction Zenity :P"










# Global variables with default values
NEW_INSTANCE_NAME='';


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