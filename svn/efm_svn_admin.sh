#!/bin/bash
#
# Friday, 21. November 2014
#

SVN_URL="svn://localhost"
SVN_ROOT="/var/svn"
NOME_REPOS=""
WEBCENTRAL_REPOS="/var/archibus"

ADMIN_USER="supporto"
ADMIN_PWD="07metallo"

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
	MESSAGGIO+=$(repos=(`ls -1 "$SVN_ROOT"/`) ; 

    printf "\t%-40s%-40s%-40s\n" "${repos[@]}")
	
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

		sudo -p "Inserisci la password per sudo > " svnadmin create "$SVN_ROOT/$NOME_REPOS"
		if [ "$?" -eq 0  ] ; then

			sudo  -p "Inserisci la password per sudo > " sh -c " sed -i \"s/# password-db = passwd/password-db = passwd/g\" \"$SVN_ROOT/$NOME_REPOS/conf/svnserve.conf\"  "

        	row=$(echo "$ADMIN_USER = $ADMIN_PWD")
            sudo  -p "Inserisci la password per sudo > " sh -c " echo $row >> $SVN_ROOT"/"$NOME_REPOS/conf/passwd "

			MESSAGGIO="SUCCESS:Repository $NOME_REPOS creato"
			return $CODE_SUCCESS
		else
			MESSAGGIO="ERROR:Errore in svnadmin create..."
			return $CODE_ERROR
		fi;


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

		MESSAGGIO+=$(printf  "  %-80s    \n " "[Layout]")
		MESSAGGIO+=$(for i in "`svn ls $SVN_URL/$NOME_REPOS`"; do printf "%-50s\n" "$i" ; done;)
		MESSAGGIO+=$(printf  "  %-80s    \n " "")

		MESSAGGIO+=$(printf  "  %-80s    \n " "[Users]")
		str=`cat "$SVN_ROOT"/"$NOME_REPOS"/conf/passwd |grep -v "^#"|grep -v "^$"|grep -v "\[users\]"|sed -n 's/^\(.*\)=.*$/\1/p' `
        MESSAGGIO+=$(printf  "  %-5s " `echo "$str"`)

		return $CODE_SUCCESS

	fi; 

}

svn_show_users() {
	unset MESSAGGIO

	MESSAGGIO="OUTPUT:"
	MESSAGGIO+=$(printf  "  \n %-80s    \n " "[Users]")
	str=`cat "$SVN_ROOT"/"$NOME_REPOS"/conf/passwd |grep -v "^#"|grep -v "^$"|grep -v "\[users\]"|sed -n 's/^\(.*\)=.*$/\1/p' `
    MESSAGGIO+=$(printf  "  %-5s\n " `echo "$str"`)

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

    sudo  -p "Inserisci la password per sudo > " sh -c " echo $row >> $SVN_ROOT"/"$NOME_REPOS/conf/passwd "

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

    sudo  -p "Inserisci la password per sudo > " sh -c " sed -i \"/^$username[ ]*=.*/d\" \"$SVN_ROOT/$NOME_REPOS/conf/passwd\" "

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

    sudo  -p "Inserisci la password per sudo > " sh -c " sed -i \"s/^$username[ ]*=.*/$row/g\" \"$SVN_ROOT/$NOME_REPOS/conf/passwd\" "

	if [ "$?" -eq 0  ] ; then
		MESSAGGIO="SUCCESS:Password cambiata"
		return $CODE_SUCCESS
	else
		MESSAGGIO="ERROR:Errore in modifica password ..."
		return $CODE_ERROR
	fi;
}

# Importa una specifica versione di Archibus WebCentral all' interno del trunk del repository
svn_import_archibus() {
	unset MESSAGGIO

	if [ ! -f "$WEBCENTRAL_REPOS/WebCv$1_WAR.zip" ] ; then
		MESSAGGIO="ERROR:Il file $WEBCENTRAL_REPOS/WebCv$1_WAR.zip non esiste..."
		return $CODE_ERROR
	else

		for folder in trunk tags branches; do
            svn --username "$ADMIN_USER" --password "$ADMIN_PWD"  mkdir "$SVN_URL"/"$NOME_REPOS"/$folder -m "Creating $folder folder" 
		done;

		pushd .
        tmpdir=`mktemp -d` && mkdir $tmpdir/archibus && \
		unzip "$WEBCENTRAL_REPOS/WebCv$1_WAR.zip" -d $tmpdir && \
		unzip $tmpdir/archibus.war -d $tmpdir/archibus && \
		cd $tmpdir && svn --username "$ADMIN_USER" --password "$ADMIN_PWD"  import -m "Initial import versione $WEBCENTRAL_REPOS/WebCv$1_WAR.zip " archibus "$SVN_URL"/"$NOME_REPOS"/trunk/archibus
		popd && rm -rf $tmpdir

		if [ "$?" -eq 0  ] ; then
			MESSAGGIO="SUCCESS:Versione $1 importata correttamente in $SVN_URL/$NOME_REPOS/trunk/archibus"
			return $CODE_SUCCESS
		else
			MESSAGGIO="ERROR:Errore in fase di importazione della versione $1..."
			return $CODE_ERROR
		fi;

	fi;

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
		"Crea repository standard                 "
		"Menu Amministrazione utenti              "
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

    local webcentral_array=(`ls -1 "$WEBCENTRAL_REPOS"/ `)

    # Versioni di archibus nel formato 
	webcentral_array=(${webcentral_array[@]/"WebCv"/})
	webcentral_array=(${webcentral_array[@]/"_WAR.zip"/})

	while true; do

		echo -en "\n### Menu per la gestione dei repository Subversion ###\n"

		PS3=$(decorate_prompt)

		select command in "${comandi[@]}" ; do

			case "$command" in

				"Elenca repository"*)
					svn_list_repositories
					clear
					break;;

				"Crea repository standard"*)
					svn_create_repository

					if [ $? -eq 0 ] ; then

						unset MESSAGGIO

						while true; do

							echo -en "\n Catalogo delle versioni di WebCentral disponibili in $WEBCENTRAL_REPOS \n"

							PS3="Scegli una versione di WebCentral>"

							select subadminopt in "${webcentral_array[@]}                         " "Quit" ; do

								case $subadminopt in

									"Quit")
										unset MESSAGGIO
										clear
										break 2
										;;

									*)
										unset MESSAGGIO
										svn_import_archibus "$subadminopt"
										echo "Import della versione $subadminopt"
										break 2
										;;

								esac;

							done;

						done;

					fi;

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

echo " Start... " && clear && show_main_menu && echo "...leave"

############################################
