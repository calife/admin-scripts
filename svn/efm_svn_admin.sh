#!/bin/bash
#
# Wednesday, 22. July 2015
#

SVN_URL="svn://localhost"
SVN_ROOT="/var/svn"
NOME_REPOS=""

WEBCENTRAL_REPOS="172.16.1.4"
WEBCENTRAL_USER="svnuser"
SVN_ADMIN_USER="supporto"
SVN_ADMIN_PWD="07metallo"

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

	read -p "Nome del repository da creare > " NOME_REPOS
	
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

        	row=$(echo "$SVN_ADMIN_USER = $SVN_ADMIN_PWD")
            sudo  -p "Inserisci la password per sudo > " sh -c " echo $row >> $SVN_ROOT"/"$NOME_REPOS/conf/passwd "

			MESSAGGIO="SUCCESS:Repository $NOME_REPOS creato"
			return $CODE_SUCCESS
		else
			MESSAGGIO="ERROR:Errore in svnadmin create..."
			return $CODE_ERROR
		fi;


	fi;

}

svn_create_empty_repository() {

	unset MESSAGGIO

	read -p "Nome del repository da creare > " NOME_REPOS
	
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

        	row=$(echo "$SVN_ADMIN_USER = $SVN_ADMIN_PWD")
            sudo  -p "Inserisci la password per sudo > " sh -c " echo $row >> $SVN_ROOT"/"$NOME_REPOS/conf/passwd "

			# Crea la struttura dei folder
			for folder in trunk tags branches; do
				svn --username "$SVN_ADMIN_USER" --password "$SVN_ADMIN_PWD"  mkdir "$SVN_URL"/"$NOME_REPOS"/$folder -m "Creating $folder folder"
			done;			

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

remoteFileExists() {

	ssh -q $WEBCENTRAL_USER@$WEBCENTRAL_REPOS [[ -f "$1" ]] && return $CODE_SUCCESS || return  $CODE_ERROR

}

svn_import_archibus() {

	unset MESSAGGIO

    remoteFileExists "$1"

	if [ "$?" -eq $CODE_ERROR  ] ; then
		MESSAGGIO="ERROR:Il file $1 non esiste..."
		return $CODE_ERROR
	else

        # Crea la struttura dei folder
		for folder in trunk tags branches; do
            svn --username "$SVN_ADMIN_USER" --password "$SVN_ADMIN_PWD"  mkdir "$SVN_URL"/"$NOME_REPOS"/$folder -m "Creating $folder folder"
		done;

		if [ "$?" -eq 0  ] ; then

            # Importa nel trunk
			pushd .
			tmpdir=`mktemp -d` && mkdir $tmpdir/archibus && \
				scp $WEBCENTRAL_USER@$WEBCENTRAL_REPOS:"$1" $tmpdir && \
				unzip $tmpdir/` basename "$1" ` -d $tmpdir && \
				unzip $tmpdir/archibus.war -d $tmpdir/archibus && \
				cd $tmpdir && svn --username "$SVN_ADMIN_USER" --password "$SVN_ADMIN_PWD"  import -m "Initial import versione $1 " archibus "$SVN_URL"/"$NOME_REPOS"/trunk/archibus
			popd && rm -rf $tmpdir

			if [ "$?" -eq 0  ] ; then
				MESSAGGIO="SUCCESS:Versione $1 importata correttamente in $SVN_URL/$NOME_REPOS/trunk/archibus"
				return $CODE_SUCCESS
			else
				MESSAGGIO="ERROR:Errore in fase di importazione della versione $1..."
				return $CODE_ERROR
			fi;

		else
			MESSAGGIO="ERROR:Impossibile stabilire una connessione con svn ..."
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
		"Elenca repository                          "
		"Crea repository vuoto (solo layout)        "
		"Crea repository standard archibus          "
		"Menu Amministrazione utenti del repository "
		"Visualizza informazioni repository         "
		"Quit                                       "
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

		echo $command

		select command in "${comandi[@]}" ; do

			case "$command" in

				"Elenca repository"*)
					svn_list_repositories
					clear
					break;;

				"Crea repository vuoto"*)
					unset MESSAGGIO					
					svn_create_empty_repository
					clear
					break;;

				"Crea repository standard archibus"*)
					
					unset MESSAGGIO

					OLDIFS=$IFS;
					IFS=$'\n'; 
					local webcentral_array=(` ssh  $WEBCENTRAL_USER@$WEBCENTRAL_REPOS " find /media/fileserver/Scambio_file/AFM* -type f -name 'WebCv*.zip' -print " | while read fname; do nome=$(echo "$fname"|sed 's/ /\\ /g'); echo "$nome"; done; `);
					IFS=$OLDIFS;

					while true; do

						echo -en "\nCatalogo WebCentral disponibili\n"

						PS3="Scegli una versione di WebCentral da caricare [1-${#webcentral_array[@]}] >"

						select subadminopt in "${webcentral_array[@]}                         " "Quit" ; do

							case $subadminopt in

								"Quit")
									unset MESSAGGIO
									clear
									break 2
									;;

								*)
									unset MESSAGGIO
									case $REPLY in
										''|*[!0-9]*)
 											echo "Opzione non valida"
											break 1
											;;
										*) 
											if [ "$REPLY" -le "${#webcentral_array[@]}" ] ; then

												remoteWarName=$(echo "${subadminopt}"|sed 's/ /\\ /g' | sed 's/[\\ ]*$//g')
                                                
												svn_create_repository && svn_import_archibus "${remoteWarName}"

											else 
 												echo "Opzione non valida"
												break 1
											fi
											break 2
											;;
									esac;
							esac;

						done;

					done;

					break;;

				"Menu Amministrazione utenti del repository"*)
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
