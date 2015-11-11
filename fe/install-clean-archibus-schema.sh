#!/bin/bash

SCRIPT_NAME='clean-archibus-schema.sh'
SCRIPT_INSTALLATION_FOLDER='/usr/local/sbin'


SCRIPT_CONTENT=`cat <<'EOF'
#/bin/bash
#
# I file con estensione: pdf, doc, docx, xls, xlsx, msg creati da oltre 1 settimana.
#
# Sono file che vengono generati da everymail e che non vengono eliminati nel caso in cui l'invio della mail non va a buon fine.

# author Marcello
# date 2015-11-11
#

INSTANCE_NAME=$1
ARCHIBUS_SCHEMA_DIR="/usr/local/$INSTANCE_NAME/webapps/archibus/schema"

if [ -d $ARCHIBUS_SCHEMA_DIR ] ; then
        su nobody -c " find $ARCHIBUS_SCHEMA_DIR  -maxdepth 1 -type f -iregex '.*\(pdf\|doc\|docx\|xls\|xlsx\msg\)' -mtime +7 -exec ls -lh '{}' \; "
        su nobody -c " find $ARCHIBUS_SCHEMA_DIR  -maxdepth 1 -type f -iregex '.*\(pdf\|doc\|docx\|xls\|xlsx\msg\)' -mtime +7 -exec rm -f '{}' \; "
        exit 0
else
        echo "Folder $ARCHIBUS_SCHEMA_DIR does not exists" ; 
        exit 1
fi

EOF
`

echo  "$SCRIPT_CONTENT" > "$SCRIPT_INSTALLATION_FOLDER/$SCRIPT_NAME"
chmod 755 "$SCRIPT_INSTALLATION_FOLDER/$SCRIPT_NAME"
chown nobody.nogroup "$SCRIPT_INSTALLATION_FOLDER/$SCRIPT_NAME"

echo "Script installed into $SCRIPT_INSTALLATION_FOLDER/$SCRIPT_NAME"

exit 0
