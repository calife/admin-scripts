#!/bin/bash
#
# Tuesday, 18. November 2014
#

SVN_URL="svn://svn01.efm.srl"
SVN_ROOT="/var/svn"
NOME_REPOS=""

RED='\033[0;41;30m'
STD='\033[0;0;39m'

# Crea un bare repository
svn_create_repository() {

return;

	if [ -z "$NOME_REPOS" ] ; then
		read -p "Nome del repository da creare > " NOME_REPOS
	fi;
	
	if [  -z "$NOME_REPOS" ] ; then
		svn_create_repository
	else 

		test -d "$SVN_ROOT"/"$NOME_REPOS" && ( echo "Repository $NOME_REPOS gia esistente...exit" ; exit 0; )

		sudo svnadmin create "$NOME_REPOS"

	fi;

}

# Permette l' amministrazione di base degli utenti
svn_admin_user() {

return;

	test -z "$NOME_REPOS" && (echo "Nome del repository non specificato...exit"; exit 0)
	test -d "$SVN_ROOT"/"$NOME_REPOS" || ( echo "Repository $NOME_REPOS inesistente ...exit" ; exit 0; )

    # Replace in file svnserve.conf , append user to passwd (files)

}

# Importa una specifica versione di archibus all' interno del repository
svn_import_archibus() {

return;

	test -z "$NOME_REPOS" && (echo "Nome del repository non specificato...exit"; exit 0)
	test -d "$SVN_ROOT"/"$NOME_REPOS" || ( echo "Repository $NOME_REPOS inesistente ...exit" ; exit 0; )

	svn import -m "Initial import" archibus "$SVN_URL"/"$NOME_REPOS"/trunk/archibus

	for i in tags branches; do
		svn mkdir "$SVN_URL"/"$NOME_REPOS"/$i -m "Creating $i folder"
		svn mkdir "$SVN_URL"/"$NOME_REPOS"/$i -m "Creating $i folder"
	done;

}

svn_show_repository() {
	return;
}

# Scarica la versione di archibus in formato war fornita come parametro
download_archibus() {
 ::::
}

showmenu() {

	comandi=(
		"Creazione repository                     "
		"Amministrazione utenti                   "
		"Caricamento di Archibus Webcentral       "
		"Visualizza informazioni repository       "
	);

    PS3="Scegli un' azione _$ ";
	COMPLETED_STR=" [COMPLETED] "

	while true; do

		echo -en "\n### Menu di gestione repository Subversion ${RED}$NOME_REPOS${STD} ###\n"

		select command in "${comandi[@]}" "Quit" ; do

			case $REPLY in

				1|2|3|4)

					comandi[$(($REPLY-1))]=${comandi[$(($REPLY-1))]/"$COMPLETED_STR"/}"$COMPLETED_STR"

					if [ $REPLY -eq 1 ] ; then svn_create_repository ; fi;

					if [ $REPLY -eq 2 ] ; then svn_admin_user  "$NOME_REPOS"; fi;

					if [ $REPLY -eq 3 ] ; then svn_import_archibus "$NOME_REPOS"; fi;

					if [ $REPLY -eq 4 ] ; then svn_show_repository "$NOME_REPOS"; fi;

					break;;

				5|quit)
					echo "Quit";
					exit;;
				*) echo -e "${RED}Opzione non valida${STD}";;
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

echo " Start... " && clear && showmenu && echo " ...Repository creato, URL: $SVN_URL/$NOME_REPOS"

############################################
