#!/bin/sh
CONFIG="/ghost/blog/MigratorConfig.js"
GHOST_VERSION=`cat /ghost/version`
if [ -z "$DB_SQLITE_PATH" ]; then
        echo "DB_SQLITE_PATH is empty. Getting default: /ghost-override/content/data/ghost-local.db"
        DB_SQLITE_PATH=/ghost-override/content/data/ghost-local.db
fi

sed -i "s|__DB_SQLITE_PATH__|$DB_SQLITE_PATH|g" $CONFIG
sed -i "s|__DB_CURRENT_VERSION__|$DB_CURRENT_VERSION|g" $CONFIG
sed -i "s|__GHOST_NEW_VERSION__|$GHOST_VERSION|g" $CONFIG

echo "Executing using the following MigratorConfig.js file"
cat $CONFIG

/bin/sh /ghost/run-ghost.sh -d
cd /ghost/blog && knex-migrator migrate
