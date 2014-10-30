#!/bin/bash

CWD=$(dirname $(realpath $0))
choice="x";
NEW_INSTANCE_NAME="";
NEW_AFM_PASSWORD="";

finale(){
  # demo - shows zenity return value(s)
  zenity --info \
    --title="Zenity returned:" \
    --window-icon=/usr/share/icons/gnome/22x22/emotes/face-worried.png \
    --width=400 \
    --text="$@"
  [ $? -eq 1 ] && exit 0
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
		genera-script-base  "$CWD" "$NEW_INSTANCE_NAME"
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
			genera-script-cambio-password "$CWD" "$NEW_INSTANCE_NAME" "$NEW_AFM_PASSWORD"
		else 
			echo "Le password non coincidono";
            b;
		fi;
	fi;
}

# Aumenta la dimensione del tablespace AFM_P1
c() {
	: 
}

# Aumenta la dimensione del tablespace Documentale
d() {
	: 
}

showmenu() {

	SELECTION=$( \

        # Column 2 is function name and is hidden from list
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

# Main Loop
checkRequired;
while [ ! "$choice" == "d" ] ; do
  showmenu;
done;