#!/bin/bash
#
# Tuesday, 18. November 2014
#

# SVN_URL="svn://svn01.efm.srl"
SVN_URL="svn://localhost"
SVN_ROOT="/var/svn"
NOME_REPOS=""

RED='\033[0;41;30m'
RESET_COLOR='\033[0;0;39m'
LRED=$'\033[38;5;9m'
RESET_PS3_COLOR=$'\033[m'
UNDERLINE=$'\033[4m'
RESET_UNDERLINE=$'\033[24m'

CODE_SUCCESS=0;
CODE_ERROR=1;

# Elenca i repository
svn_list_repositories() {

	unset MESSAGGIO

	MESSAGGIO=$(printf  " | %-80s | \n\n\n " "Elenco dei repository in data $(date --iso)  ")
	MESSAGGIO="$MESSAGGIO"$(for i in "$SVN_ROOT"/*; do  printf " | %-40s | %-40s | \n " $(basename $i) $SVN_URL/$(basename $i) ; done;)

	return $CODE_SUCCESS

}

# Crea un bare repository
svn_create_repository() {

	unset MESSAGGIO

	read -p "Repository da creare > " NOME_REPOS
	
	if [  -z "$NOME_REPOS" ] ; then

		svn_create_repository

	else

        # command test returns 1 on error, 0 on ok
		if [ -d "$SVN_ROOT"/"$NOME_REPOS" ] ; then 
			MESSAGGIO="Repository $NOME_REPOS già esistente..."
			return $CODE_ERROR
		fi;

        # command svnadmin returns 1 on error, 0 on ok
		sudo svnadmin create "$SVN_ROOT/$NOME_REPOS"  >/dev/null 2>&1
		if [ "$?" -eq 0  ] ; then
			MESSAGGIO="Repository $NOME_REPOS creato"
			return $CODE_SUCCESS
		else
			MESSAGGIO="Errore in svnadmin create..."
			return $CODE_ERROR
		fi;

	fi;

}

# Permette l' amministrazione di base degli utenti
# Aggiunta/Rimozione/Modifica password
svn_admin_user() {

	unset MESSAGGIO

	read -p "Repository da amministrare > " NOME_REPOS

	if [  -z "$NOME_REPOS" ] ; then
		svn_admin_user;
	fi;

	if [ ! -d "$SVN_ROOT"/"$NOME_REPOS" ] ; then
		MESSAGGIO="Il repository $NOME_REPOS non esiste..."
		return $CODE_ERROR
	else

		echo " Start... " && clear && showadminmenu
		
        # TODO Replace in file svnserve.conf , append user to passwd (files)
		return $CODE_SUCCESS

	fi; 

    
}

# Importa una specifica versione di Archibus WebCentral all' interno del trunk del repository
svn_import_archibus() {

	return;

	test -z "$NOME_REPOS" && (echo "Repository non specificato...exit"; exit 0)
	test -d "$SVN_ROOT"/"$NOME_REPOS" || ( echo "Repository $NOME_REPOS inesistente ...exit" ; exit 0; )

	svn import -m "Initial import" archibus "$SVN_URL"/"$NOME_REPOS"/trunk/archibus

	for i in tags branches; do
		svn mkdir "$SVN_URL"/"$NOME_REPOS"/$i -m "Creating $i folder"
		svn mkdir "$SVN_URL"/"$NOME_REPOS"/$i -m "Creating $i folder"
	done;

}

# Elenca le versioni di Archibus WebCentral disponibili
svn_show_repository() {
	return;
}

# Scarica la versione di Archibus WebCentral in formato war
download_archibus() {
	::::
}

# Mostra il menu di amministrazione degli utenti
showadminmenu() {

	echo " Replace in file svnserve.conf , append user to passwd (files)"

	# comandi_amministrazione=(
	# 	"Creazione utente      "
	# 	"Elimina utente        "
	# 	"Elenca utenti         "
	# 	"Cambia password       "
    # );

	# while true; do

	# 	echo -en "\n### Menu per la gestione degli utenti  ###\n"

	# 	PS3="${LRED}$MESSAGGIO${RESET_PS3_COLOR} Scegli un' azione _$ "

	# 	select command in "${comandi_amministrazione[@]}" "Quit" ; do

	# 		case $REPLY in
	# 			5|quit)
	# 				return $CODE_SUCCESS
	# 				break;;
	# 			*) 
	# 				unset MESSAGGIO
	# 				MESSAGGIO="Opzione $REPLY non valida"
    #                 break;;
	# 		esac;

	# 	done;

	# done;

}


show_main_menu() {

	comandi=(
		"Elenca repository                        "
		"Crea repository                          "
		"Amministrazione utenti                   "
		"Caricamento di Archibus Webcentral       "
		"Visualizza informazioni repository       "
		"Quit                                     "
	);

	while true; do

		echo -en "\n### Menu per la gestione dei repository Subversion ###\n"

		PS3="${LRED}$MESSAGGIO${RESET_PS3_COLOR}"$'\n'"Scegli un' azione _$ "

		select command in "${comandi[@]}" ; do

			case "$command" in

				"Elenca repository"*)
					svn_list_repositories
					break
					;;
				"Crea repository"*)
					svn_create_repository
					break
					;;
				"Amministrazione utenti"*)
					svn_admin_user
					break
					;;
				"Caricamento di Archibus Webcentral"*)
					svn_import_archibus
					break
					;;
				"Visualizza informazioni repository"*)
					svn_show_repository
					break
					;;
				"Quit"*)
					echo "Quit";
					exit
					;;
				*) 
					unset MESSAGGIO			
					clear	
                    break;;
			esac



		done;

clear

	done;

}

################### Main ###################

if [ $# -eq 1 ]; then
	case "$1" in
		--help|-h) Usage; exit 0;;
	esac;
fi;

echo " Start... " && clear && show_main_menu

############################################
