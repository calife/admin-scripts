#!/bin/bash
#
# Friday, 21. November 2014
#

# SVN_URL="svn://svn01.efm.srl"
SVN_URL="svn://localhost"
SVN_ROOT="/var/svn"
NOME_REPOS=""

CODE_SUCCESS=0;
CODE_ERROR=1;



# °
# °
# °

repository_exists() {

	unset MESSAGGIO

	read -p "Repository> " NOME_REPOS

	if [  -z "$NOME_REPOS" ] ; then
		repository_exists
	fi;

	if [ ! -d "$SVN_ROOT"/"$NOME_REPOS" ] ; then
		MESSAGGIO="ERROR:Il repository $NOME_REPOS non esiste..."
		return $CODE_ERROR
	else
		return $CODE_SUCCESS
	fi; 
}

svn_list_repositories() {

	unset MESSAGGIO

	MESSAGGIO="OUTPUT:"
	MESSAGGIO+=$(printf  "  %-80s    \n " "   ")
	MESSAGGIO+=$(printf  "  %-80s    \n\n\n " "Elenco dei repository in data $(date --iso)  ")
	MESSAGGIO+=$(for i in "$SVN_ROOT"/*; do  printf " %-40s %-40s \n " $(basename $i) $SVN_URL/$(basename $i) ; done;)

	return $CODE_SUCCESS

}

svn_create_repository() {

	unset MESSAGGIO

	read -p "Repository da creare > " NOME_REPOS
	
	if [  -z "$NOME_REPOS" ] ; then

		svn_create_repository

	else

		if [ -d "$SVN_ROOT"/"$NOME_REPOS" ] ; then 
			MESSAGGIO="ERROR:Repository $NOME_REPOS già esistente..."
			return $CODE_ERROR
		fi;

		sudo svnadmin create "$SVN_ROOT/$NOME_REPOS"  >/dev/null 2>&1
		if [ "$?" -eq 0  ] ; then
			MESSAGGIO="SUCCESS:Repository $NOME_REPOS creato"
			return $CODE_SUCCESS
		else
			MESSAGGIO="ERROR:Errore in svnadmin create..."
			return $CODE_ERROR
		fi;

		sudo sh -c " sed -i \"s/# password-db = passwd/password-db = passwd/g\" \"$SVN_ROOT/$NOME_REPOS/conf/svnserve.conf\"  "

	fi;

}

svn_show_repository() {

	unset MESSAGGIO

	read -p "Repository> " NOME_REPOS

	if [  -z "$NOME_REPOS" ] ; then
		svn_show_repository
	fi;

	if [ ! -d "$SVN_ROOT"/"$NOME_REPOS" ] ; then
		MESSAGGIO="ERROR:Il repository $NOME_REPOS non esiste..."
		return $CODE_ERROR
	else
		MESSAGGIO="OUTPUT:"
		MESSAGGIO+=$(printf  "  %-80s    \n " "   ")
		MESSAGGIO+=$(printf  " %-80s \n\n " "Informazioni repository $SVN_URL/$NOME_REPOS in data $(date --iso)  ")
		MESSAGGIO+=$(cat "$SVN_ROOT"/"$NOME_REPOS"/conf/passwd |grep -v "^#"|grep -v "^$")

		return $CODE_SUCCESS

	fi; 

}

svn_show_users() {
	unset MESSAGGIO

	MESSAGGIO="OUTPUT:"
	MESSAGGIO+=$(cat "$SVN_ROOT"/"$NOME_REPOS"/conf/passwd |grep -v "^#"|grep -v "^$")
}

svn_add_user() {
	unset MESSAGGIO

	local username
	local password

	read -p "Username> " username
	if [  -z "$username" ] ; then
		svn_add_user;
	fi;

    grep -e "^$username[ ]*=.*$" "$SVN_ROOT/$NOME_REPOS/conf/passwd" > /dev/null  2>&1;
	if [ "$?" -eq 0  ] ; then
		MESSAGGIO="ERROR:L' utenza specificata è gia esistente  ..."
		return $CODE_ERROR
	fi;

	read -p "Password> " password
	if [  -z "$password" ] ; then
		svn_add_user;
	fi;

	row=$(echo "$username = $password")

    sudo sh -c " echo $row >> $SVN_ROOT"/"$NOME_REPOS/conf/passwd "

	if [ "$?" -eq 0  ] ; then
		MESSAGGIO="SUCCESS:Utenza $username creata"
		return $CODE_SUCCESS
	else
		MESSAGGIO="ERROR:Errore in fase di creazione dell' utenza ..."
		return $CODE_ERROR
	fi;

}

svn_rm_user() {
	unset MESSAGGIO

	local username

	read -p "Username> " username
	if [  -z "$username" ] ; then
		svn_rm_user;
	fi;

    grep -e "^$username[ ]*=.*$" "$SVN_ROOT/$NOME_REPOS/conf/passwd" > /dev/null  2>&1;
	if [ "$?" -eq 1  ] ; then
		MESSAGGIO="ERROR:L' utenza specificata non esiste  ..."
		return $CODE_ERROR
	fi;

    sudo sh -c " sed -i \"/^$username[ ]*=.*/d\" \"$SVN_ROOT/$NOME_REPOS/conf/passwd\" "

	if [ "$?" -eq 0  ] ; then
		MESSAGGIO="SUCCESS:Utenza $username rimossa"
		return $CODE_SUCCESS
	else
		MESSAGGIO="ERROR:Errore in fase di cancellazione dell' utenza ..."
		return $CODE_ERROR
	fi;

}

svn_change_pwd() {
	unset MESSAGGIO

	local username

	read -p "Username> " username
	if [  -z "$username" ] ; then
		svn_change_pwd
	fi;

    grep -e "^$username[ ]*=.*$" "$SVN_ROOT/$NOME_REPOS/conf/passwd" > /dev/null  2>&1;
	if [ "$?" -eq 1  ] ; then
		MESSAGGIO="ERROR:L' utenza specificata non esiste  ..."
		return $CODE_ERROR
	fi;

	read -p "Password> " password
	if [  -z "$password" ] ; then
		svn_change_pwd
	fi;

	row=$(echo "$username = $password")

    sudo sh -c " sed -i \"s/^$username[ ]*=.*/$row/g\" \"$SVN_ROOT/$NOME_REPOS/conf/passwd\" "

	if [ "$?" -eq 0  ] ; then
		MESSAGGIO="SUCCESS:Password cambiata"
		return $CODE_SUCCESS
	else
		MESSAGGIO="ERROR:Errore in modifica password ..."
		return $CODE_ERROR
	fi;
}


# Scarica la versione di Archibus WebCentral in formato war
download_archibus() {
	::::
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


decorate_prompt() {

	red='\033[0;41;30m'
	reset_color='\033[0;0;39m'
	lred=$'\033[38;5;9m'
	lgreen=$'\033[38;5;46m'
	reset_ps3_color=$'\033[m'
	underline=$'\033[4m'
	reset_underline=$'\033[24m'
	bold=$'\033[1m'
	reset_bold=$'\033[21m'

	case "$MESSAGGIO" in

		"OUTPUT"*)
			MESSAGGIO=$"${bold}"$MESSAGGIO"${reset_bold}"
			;;
		"ERROR"*)
			MESSAGGIO=$"${lred}"$MESSAGGIO"${reset_ps3_color}"
			;;
		"SUCCESS"*)
			MESSAGGIO=$"${lgreen}"$MESSAGGIO"${reset_ps3_color}"
			;;
		*)
			MESSAGGIO=$"${bold}"$MESSAGGIO"${reset_bold}"
			;;

	esac;

	MESSAGGIO+=$'\n'"Scegli un' azione _$ "
	echo "$MESSAGGIO"
}

# °
# °
# °
show_main_menu() {

	local comandi=(
		"Elenca repository                        "
		"Crea repository                          "
		"Menu Amministrazione utenti              "
		"Caricamento di Archibus Webcentral       "
		"Visualizza informazioni repository       "
		"Quit                                     "
	);

	local comandi_admin_users=(
		"Elenca utenti"
		"Crea utente"
		"Elimina utente"
		"Cambia password"
        "Quit"
    );

	while true; do

		echo -en "\n### Menu per la gestione dei repository Subversion ###\n"

		PS3=$(decorate_prompt)

		select command in "${comandi[@]}" ; do

			case "$command" in

				"Elenca repository"*)
					svn_list_repositories
					clear
					break;;

				"Crea repository"*)
					svn_create_repository
					clear
					break;;

				"Menu Amministrazione utenti"*)

					repository_exists

					if [ $? -eq 0 ] ; then
						
						while true; do

							echo -en "\n### Menu per la gestione del repository  $SVN_URL/$NOME_REPOS  ###\n"

							PS3=$(decorate_prompt)

							select subadminopt in "${comandi_admin_users[@]}" ; do

								case $subadminopt in

									"Elenca utenti")
										svn_show_users
										break;
										;;
									"Crea utente")
										svn_add_user
										break;
										;;
									"Elimina utente")
										svn_rm_user
										break;
										;;
									"Cambia password")
										svn_change_pwd
										break;
										;;
									"Quit")
										unset MESSAGGIO
										clear
										break 2
										;;

								esac;

							done;

						done;

					fi;

					break;

					;;
				"Caricamento di Archibus Webcentral"*)
					svn_import_archibus
					clear
					break;;
				"Visualizza informazioni repository"*)
					svn_show_repository
					clear
					break;;
				"Quit"*)
					unset MESSAGGIO
					echo "Quit";
					exit;;
				*) 
					unset MESSAGGIO			
					clear	
                    break;;
			esac

		done;

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
