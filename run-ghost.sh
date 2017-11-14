#!/bin/sh

CONFIG="$GHOST_INSTALL/config.production.json"

if [ -f $GHOST_INSTALL/config.override.json ]; then
        echo "Ghost override provided. Override the internal configuration"
        cp $GHOST_INSTALL/config.override.json $GHOST_INSTALL/config.production.json
fi

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

if [ -z "$(ls -A "$GHOST_CONTENT")" ]; then
        echo "Missing content folder. Copying the default one..."
        cp -r $GHOST_INSTALL/content.bck/* $GHOST_CONTENT
fi

if [[ "$*" == "init" ]]; then 
        echo "Empty database. Initializing..."
        knex-migrator init --mgpath "$GHOST_INSTALL/current"
        exit 0
fi

if [[ "$*" == "init start" ]]; then 
        echo "Empty database. Initializing..."
        knex-migrator init --mgpath "$GHOST_INSTALL/current"
        node current/index.js
fi

if [[ "$*" == "migrate" ]]; then 
        echo "Database already exists. Executing migration (if needed)"
        knex-migrator migrate --mgpath "$GHOST_INSTALL/current"
        exit 0
fi

exec $@
