#!/bin/bash
#
# Wizard grafico di creazione degli script Archibus
# @author Pucci
# @date Monday, 03. November 2014
#

CWD=$(dirname $(realpath $0))
choice="x";
NEW_INSTANCE_NAME="";
NEW_AFM_PASSWORD="";

finale(){
  zenity --info \
    --title="Creazione script completata" \
    --text="Creazione script completata $NEW_INSTANCE_NAME"
}

# Verifica ed esegue il caricamento delle funzioni di help, per creare gli script
checkRequired() {
	if [ ! -f ${CWD}/helper-func ] ; then
		echo "Missing helper-func";
		exit 1;
	else 
		. ${CWD}/helper-func
	fi;
}

# Crea gli script di base per l' istanza
a() {
	NEW_INSTANCE_NAME=$( \
		zenity --entry \
		--title="Creazione script per la nuova istanza $NEW_INSTANCE_NAME" \
		--text="Nome della nuova istanza" \
		--width=400 \
		--entry-text=""
	)

	if [ $? -eq 1 ] ; then
		exit 0;
	else 
		genera-script-base  "$NEW_INSTANCE_NAME"
	fi;

}

# Crea gli script per il cambio password degli utenti AFM e AFM_SECURE
b() {
	cfgpass=$( \
        zenity --forms \
		--title="Cambio password per gli utenti AFM e AFM_SECURE , istanza $NEW_INSTANCE_NAME" \
		--add-password="Password AFM/AFM_SECURE" \
		--add-password="Conferma Password AFM/AFM_SECURE" \
		--separator="|" \
        --width=400 \
		)

	pwd1=`echo "$cfgpass" | cut -d "|" -f1`
	pwd2=`echo "$cfgpass" | cut -d "|" -f2`

	if [ $? -eq 1 ] ; then
		exit 0;
	else
		if [ "$pwd1" == "$pwd2" ] ; then
            NEW_AFM_PASSWORD=$pwd1;
			genera-script-cambio-password "$NEW_INSTANCE_NAME" "$NEW_AFM_PASSWORD"
		else
			echo "Le password non coincidono";
            b;
		fi;
	fi;
}

#  Definisci il numero di datafile per il tablespace AFM_P1 e la dimensione di ciascuno di essi
c() {

num_afm_p1_datafiles=$(zenity )

    num_afm_p1_datafile=$(zenity --scale --text "Num. datafiles AFM_P1" --value="1" --min-value="1" --max-value="4" --step="1")

    datafile_afm_p1_size=$(zenity --scale --text "Dimensione datafiles AFM_P1" --value="1024" --min-value="1024" --max-value="32768" --step="500")

	genera-script-tablespace-AFM_P1 "$NEW_INSTANCE_NAME" "$num_afm_p1_datafiles" "$datafile_afm_p1_size"M
}

#  Definisci il numero di datafile per il tablespace documentale e la dimensione di ciascuno di essi
d() {

    num_afm_blob_datafile=$(zenity --scale --text "Num. datafiles AFM_DOCMGMT" --value="1" --min-value="1" --max-value="16" --step="1")

    datafile_afm_blob_size=$(zenity --scale --text "Dimensione datafiles AFM_DOCMGMT" --value="1024" --min-value="1024" --max-value="32768" --step="500")

	genera-script-tablespace-AFM_BLOB "$NEW_INSTANCE_NAME" 16 "$datafile_afm_blob_size"M
}

showmenu() {

	SELECTION=$( \

		zenity --list \
			--radiolist \
			--title="Wizard di creazione script per istanza $NEW_INSTANCE_NAME" \
			--width=800 --height=600 \
			--text="Menu" \
			--column="Select" \
			--column="Funzione" \
			--column="Option" \
			--column="Descrizione" \
			--hide-column=2 \
			$( [ x$choice == xx ] && echo TRUE || echo FALSE )  a "Script di base" "Genera gli script di base"\
	        $( [  $choice == a  ] && echo TRUE || echo FALSE )  b "Cambia password" "Cambia password agli utenti AFM e AFM_SECURE"\
	        $( [  $choice == b  ] && echo TRUE || echo FALSE )  c "Modifica Tablespace AFM_P1" "Modifica Tablespace Dati" \
	        $( [  $choice == c  ] && echo TRUE || echo FALSE )  d "Modifica Tablespace AFMDOCMGMT_BLOB" "Modifica Tablespace Documentale" \

	)

  [ $? -eq 0 ] || exit 0
  choice=${SELECTION,,}	# lowercase all
  ${choice// }		# eliminate all spaces

}

############################################ Main Loop ############################################

checkRequired;
while [ ! "$choice" == "d" ] ; do
  showmenu;
done;
finale && exit 0;

###################################################################################################