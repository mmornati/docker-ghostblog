#!/bin/sh
verbose='false'
start='true'
while getopts 'dv' flag; do
  case "${flag}" in
    d) start='false' ;;
    v) verbose='true' ;;
    *) start='true' ;;
  esac
done

CONFIG="$GHOST_INSTALL/config.production.json"

# Set Config
if [ -z "$WEB_URL" ]; then
	echo "WEB_URL is empty. Getting default: http://$(hostname -i):2368"
	WEB_URL=http://$(hostname -i):2368
fi

echo "=> Change config based on ENV parameters:"
echo "========================================================================"
echo "      WEB_URL:        $WEB_URL"
echo "========================================================================"

sed -i "s|http://localhost:2368/|$WEB_URL|g" config.production.json

if [[ $verbose == 'true' ]]; then
	cat $CONFIG
fi

if [ -z "$(ls -A "$GHOST_CONTENT")" ]; then
        echo "Missing content folder. Copying the default one..."
        cp -r $GHOST_INSTALL/content.bck/* $GHOST_CONTENT
fi

if [ ! -s "$(awk '/"filename": "(.*)"/ {print $2}' $CONFIG | sed -e s/\"//g)" ]; then
        echo "Empty database. Initializing..."
        knex-migrator-migrate --init --mgpath "$GHOST_INSTALL/current"
else
        echo "Database already exists. Executing migration (if needed)"
        knex-migrator migrate --mgpath "$GHOST_INSTALL/current"
fi

if [[ $start == 'true' ]]; then
	# Start Ghost with Ghost CLI
	# cd $GHOST_INSTALL && ghost run production
        # Start Ghost with NODE
        cd $GHOST_INSTALL && node current/index.js 
fi
