#!/bin/bash

GHOST="/ghost"
OVERRIDE="/ghost-override"

CONFIG="config.js"
DATA="content/data"
IMAGES="content/images"
THEMES="content/themes"

# Set Config
if [ -z "$WEB_URL" ]; then
	echo "WEB_URL is empty. Getting default: blog.mornati.net"
	WEB_URL=http://blog.mornati.net
fi
if [ -z "$DB_CLIENT" ]; then
        echo "DB_CLIENT is empty. Getting default: sqlite3"
        DB_CLIENT=sqlite3
fi
if [ -z "$DB_SQLITE_PATH" ]; then
        echo "DB_SQLITE_PATH is empty. Getting default: /content/data/ghost.db"
        DB_SQLITE_PATH=/content/data/ghost.db
fi
if [ -z "$SERVER_HOST" ]; then
        echo "SERVER_HOST is empty. Getting default: 0.0.0.0"
        SERVER_HOST=0.0.0.0
fi
if [ -z "$SERVER_PORT" ]; then
        echo "SERVER_PORT is empty. Getting default: 80"
        SERVER_PORT=2368
fi

echo "=> Change config based on ENV parameters:"
echo "========================================================================"
echo "      WEB_URL:        $WEB_URL"
echo "      DB_CLIENT:      $DB_CLIENT"
echo "      DB_SQLITE_PATH: $DB_SQLITE_PATH"
echo "      SERVER_HOST:    $SERVER_HOST"
echo "      SERVER_PORT:    $SERVER_PORT"
echo "========================================================================"

sed -i "s|__WEB_URL__|$WEB_URL|g" $CONFIG
sed -i "s|__DB_CLIENT__|$DB_CLIENT|g" $CONFIG
sed -i "s|__DB_SQLITE_PATH__|$DB_SQLITE_PATH|g" $CONFIG
sed -i "s|__SERVER_HOST__|$SERVER_HOST|g" $CONFIG
sed -i "s|__SERVER_PORT__|$SERVER_PORT|g" $CONFIG


cat $CONFIG

# Start Ghost
NODE_ENV=${NODE_ENV:-production} npm start
